extends CharacterBody2D

@onready var buff_icon = $"Buffed Icon"
@onready var protect_icon = $"Proctected Icon"
@onready var HP_Bar = $HP
@onready var MP_Bar = $MP
@onready var Special_Bar = $Special
@onready var Special_Bar_Num = $Special/Label
@onready var animation = $AnimationPlayer

var is_KOed;
var max_HP: int = 600
var curr_HP: int = 600
var max_MP: int = 150
var curr_MP: int = 150
var ATK: int = 50
var DEF: int = 50
var curr_special: int = 0
var curr_ememy_style;

enum Playstyle{
	DEFENSIVE,
	OFFENSIVE,
	TRICKY,
	SUPPORTIVE
}
enum Interaction{
	WEAK, 
	NORMAL,
	STRONG
}
var isDefended = false;
var isBuffed = false;
var isDebuffed = false;
var isProtected = false;
var Elixir_Stock: int = 3;
var BSpice_Stock: int = 2;
var DDust_Stock: int = 2;
var BBerries_Stock: int = 1;
var ult_ready = false;
var curr_style;
var curr_interact;
var curr_attack: int = 0;
var turn_count: int = 3;
var is_shred = false;
var is_enchanced = false;
var is_def_spell = false;
var spec_gain: int = 0;
var is_ult = false;
var b_counter: int = 2;
var p_counter: int = 1;

signal dealt_damage
signal usable_ult
signal debuffed_enemy
signal MP_Depletion
signal MP_Restore 
signal Special_Depletion
signal Special_Gain
signal trigger_e_turn
signal defeated
signal p_attack_anim
signal p_star_beam_anim
signal p_enhance_star_beam_anim
signal p_black_hole_anim
signal p_enhance_black_hole_anim
signal p_shred_anim
signal p_enhance_shred_anim
signal p_burst_anim
signal p_enhance_burst_anim
signal ult_anim


func _ready():
	curr_style = Playstyle.DEFENSIVE
	curr_interact = Interaction.NORMAL

	
func _check_interaction(eStyle):
	var pStyle = curr_style
	if((pStyle == Playstyle.DEFENSIVE && eStyle == Playstyle.TRICKY) || 
	(pStyle == Playstyle.OFFENSIVE && eStyle == Playstyle.DEFENSIVE) ||
	(pStyle == Playstyle.TRICKY && eStyle == Playstyle.OFFENSIVE)):
		curr_interact = Interaction.WEAK
	elif((pStyle == Playstyle.DEFENSIVE && eStyle == Playstyle.OFFENSIVE) || 
	(pStyle == Playstyle.OFFENSIVE && eStyle == Playstyle.TRICKY) ||
	(pStyle == Playstyle.TRICKY && eStyle == Playstyle.DEFENSIVE)):
		curr_interact = Interaction.STRONG
	else:
		curr_interact = Interaction.NORMAL

func get_style():
	return curr_style;
	
func _buffed():
	if(isBuffed):
		b_counter = 2
	else:
		isBuffed = true
		ATK += 10
		DEF += 10
		buff_icon.show()
		b_counter = 2

func buff_check():
	if(isBuffed):
		b_counter -= 1
		if(b_counter == 0):
			isBuffed = false
			ATK -= 10
			DEF -= 10
			buff_icon.hide()

func _protected():
	if(isProtected):
		p_counter = 1
	else:
		isProtected = true
		protect_icon.show()
		p_counter = 1

func protect_check():
	if(isProtected):
		p_counter -= 1
		if(p_counter == 0):
			isProtected = false
			protect_icon.hide()

func defend_check():
	if(isDefended):
		isDefended = false

func _heal(restore):
	curr_HP += restore
	if(curr_HP > 600):
		curr_HP = 600
	HP_Bar.value += restore

func mp_heal(amount):
	curr_MP += amount
	if(curr_MP > 150):
		curr_MP = 150
	MP_Bar.value += amount
	
func ult_gain(def_spell, stag):
	var meter_gain: int = 0
	if(curr_interact == Interaction.STRONG):
		meter_gain = 35
	elif(curr_interact == Interaction.WEAK):
		meter_gain = 15
	else:
		meter_gain = 20
	if(def_spell):
		meter_gain += 10
	if(stag):
		meter_gain += 20
		#print("Stagger!!!")
	curr_special += meter_gain
	if(curr_special > 100):
		curr_special = 100
	Special_Bar.value = curr_special
	spec_gain = meter_gain
	#print(Special_Bar.value, " Player-Gain")
	#print(curr_special, " Player-Gain")

func ult_check():
	if(curr_special == 100):
		usable_ult.emit()

func enchance_cost():
	curr_special -= 25
	Special_Bar.value -= 25
	Special_Depletion.emit(25)
	#print(Special_Bar.value, " Player-Cost")
	#print(curr_special, " Player-Cost")

func ko_check():
	if(curr_HP <= 0):
		is_KOed = true
		defeated.emit()

func _on_battle_1_select_attack():
	defend_check()
	curr_attack = Tech.take_damage(ATK, "Attack")
	dealt_damage.emit(curr_attack, curr_style, is_shred, is_enchanced, is_ult)
	_check_interaction(curr_ememy_style)
	ult_gain(is_def_spell, false)
	if(curr_interact == Interaction.STRONG):
		mp_heal(25)
		MP_Restore.emit(25)
	elif(curr_interact == Interaction.WEAK):
		mp_heal(15)
		MP_Restore.emit(15)
	else:
		mp_heal(20)
		MP_Restore.emit(20)
	Special_Gain.emit(spec_gain)
	ult_check()
	buff_check()
	protect_check()
	p_attack_anim.emit()
	trigger_e_turn.emit()


func _on_battle_1_select_def_spell():
	defend_check()
	is_def_spell = true
	curr_attack = Tech.take_damage(ATK, "Star_Beam")
	dealt_damage.emit(curr_attack, curr_style, is_shred, is_enchanced, is_ult)
	curr_MP -= 30
	MP_Bar.value -= 30
	MP_Depletion.emit(30)
	_check_interaction(curr_ememy_style)
	ult_gain(is_def_spell, false)
	is_def_spell = false
	Special_Gain.emit(spec_gain)
	ult_check()
	buff_check()
	protect_check()
	p_star_beam_anim.emit()
	trigger_e_turn.emit()


func _on_battle_1_select_enhanced_def():
	defend_check()
	is_enchanced = true
	curr_attack = Tech.take_damage(ATK, "Star_Beam +")
	dealt_damage.emit(curr_attack, curr_style, is_shred, is_enchanced, is_ult)
	_protected()
	curr_MP -= 30
	MP_Bar.value -= 30
	MP_Depletion.emit(30)
	is_enchanced = false
	enchance_cost()
	ult_check()
	buff_check()
	p_enhance_star_beam_anim.emit()
	trigger_e_turn.emit()


func _on_battle_1_select_off_spell():
	defend_check()
	curr_attack = Tech.take_damage(ATK, "Black_Hole")
	dealt_damage.emit(curr_attack, curr_style, is_shred, is_enchanced, is_ult)
	curr_MP -= 45
	MP_Bar.value -= 45
	MP_Depletion.emit(45)
	_check_interaction(curr_ememy_style)
	ult_gain(is_def_spell, false)
	Special_Gain.emit(spec_gain)
	ult_check()
	buff_check()
	protect_check()
	p_black_hole_anim.emit()
	trigger_e_turn.emit()


func _on_battle_1_select_enhanced_off():
	defend_check()
	is_enchanced = true
	if(!isBuffed):
		_buffed()
	curr_attack = Tech.take_damage(ATK, "Black_Hole +")
	dealt_damage.emit(curr_attack, curr_style, is_shred, is_enchanced, is_ult)
	curr_MP -= 45
	MP_Bar.value -= 45
	MP_Depletion.emit(45)
	is_enchanced = false
	enchance_cost()
	ult_check()
	protect_check()
	p_enhance_black_hole_anim.emit()
	trigger_e_turn.emit()

func _on_battle_1_select_trick_spell():
	defend_check()
	is_shred = true
	curr_attack = Tech.take_damage(ATK, "Shredder")
	dealt_damage.emit(curr_attack, curr_style, is_shred, is_enchanced, is_ult)
	curr_MP -= 35
	MP_Bar.value -= 35
	MP_Depletion.emit(35)
	_check_interaction(curr_ememy_style)
	ult_gain(is_def_spell, false)
	is_shred = false
	Special_Gain.emit(spec_gain)
	ult_check()
	buff_check()
	protect_check()
	p_shred_anim.emit()
	trigger_e_turn.emit()


func _on_battle_1_select_enhanced_trick():
	defend_check()
	is_enchanced = true
	is_shred = true
	curr_attack = Tech.take_damage(ATK, "Shredder +")
	dealt_damage.emit(curr_attack, curr_style, is_shred, is_enchanced, is_ult)
	debuffed_enemy.emit()
	curr_MP -= 35
	MP_Bar.value -= 35
	MP_Depletion.emit(35)
	is_shred = false
	is_enchanced = false
	enchance_cost()
	ult_check()
	buff_check()
	protect_check()
	p_enhance_shred_anim.emit()
	trigger_e_turn.emit()


func _on_battle_1_select_support_spell():
	defend_check()
	curr_attack = Tech.take_damage(ATK, "Burst")
	dealt_damage.emit(curr_attack, curr_style, is_shred, is_enchanced, is_ult)
	curr_MP -= 20
	MP_Bar.value -= 20
	MP_Depletion.emit(20)
	_check_interaction(curr_ememy_style)
	ult_gain(is_def_spell, false)
	Special_Gain.emit(spec_gain)
	ult_check()
	buff_check()
	p_burst_anim.emit()
	protect_check()


func _on_battle_1_select_enhanced_support():
	defend_check()
	is_enchanced = true
	curr_attack = Tech.take_damage(ATK, "Burst +")
	dealt_damage.emit(curr_attack, curr_style, is_shred, is_enchanced, is_ult)
	_heal(200)
	curr_MP -= 20
	MP_Bar.value -= 20
	MP_Depletion.emit(20)
	is_enchanced = false
	enchance_cost()
	ult_check()
	buff_check()
	p_enhance_burst_anim.emit()
	protect_check()


func _on_battle_1_switch_to_def():
	defend_check()
	curr_style = Playstyle.DEFENSIVE
	buff_check()
	protect_check()
	trigger_e_turn.emit()


func _on_battle_1_switch_to_off():
	defend_check()
	curr_style = Playstyle.OFFENSIVE
	buff_check()
	protect_check()
	trigger_e_turn.emit()



func _on_battle_1_switch_to_support():
	defend_check()
	curr_style = Playstyle.SUPPORTIVE
	buff_check()
	protect_check()
	trigger_e_turn.emit()


func _on_battle_1_switch_to_trick():
	defend_check()
	curr_style = Playstyle.TRICKY
	buff_check()
	protect_check()
	trigger_e_turn.emit()


func _on_battle_1_select_elixir():
	defend_check()
	curr_HP = max_HP
	curr_MP = max_MP
	HP_Bar.value = max_HP
	MP_Bar.value = max_MP
	MP_Restore.emit(150)
	buff_check()
	protect_check()
	trigger_e_turn.emit()


func _on_battle_1_select_bb():
	defend_check()
	if(!isProtected):
		_protected()
	buff_check()
	trigger_e_turn.emit()


func _on_battle_1_select_dd():
	defend_check()
	debuffed_enemy.emit()
	buff_check()
	protect_check()
	trigger_e_turn.emit()


func _on_battle_1_select_bs():
	defend_check()
	if(!isBuffed):
		_buffed()
	protect_check()
	trigger_e_turn.emit()


func _on_enemy_send_e_style(enemy_style):
	curr_ememy_style = enemy_style
	_check_interaction(curr_ememy_style)


func _on_enemy_enemy_stagger(staggered):
	ult_gain(is_def_spell, staggered)
	Special_Gain.emit(spec_gain)


	
func _on_battle_1_select_ult():
	defend_check()
	is_ult = true
	curr_attack = Tech.take_damage(ATK, "Ultimate")
	dealt_damage.emit(curr_attack, curr_style, is_shred, is_enchanced, is_ult)
	curr_MP = 150
	MP_Bar.value = 150
	curr_special = 0
	Special_Bar.value = 0
	MP_Restore.emit(150)
	Special_Depletion.emit(100)
	#print(Special_Bar.value, " Player-Cost")
	#print(curr_special, " Player-Cost")
	is_ult = false
	buff_check()
	protect_check()
	ult_anim.emit()
	trigger_e_turn.emit()


func _on_enemy_enemy_dealt_damage(damage, style):
	var true_dam = damage - DEF
	_check_interaction(style)
	if(curr_interact == Interaction.STRONG):
		true_dam -= 15
	elif(curr_interact == Interaction.WEAK):
		true_dam += 15
	else:
		true_dam += 0
	if(isDefended):
		true_dam = true_dam/2
	if(isProtected):
		true_dam = true_dam/2
	curr_HP -= true_dam
	HP_Bar.value -= true_dam	
	animation.play("Hurt")
	ko_check()


func _on_battle_1_select_defend():
	isDefended = true
	trigger_e_turn.emit()
