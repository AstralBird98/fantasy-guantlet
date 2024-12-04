extends CharacterBody2D

var is_KOed
var max_HP: int = 0
var curr_HP: int = 0
var ATK: int = 0
var DEF: int = 0
var curr_stagger: int = 20
var max_stagger: int = 20
var curr_style
var curr_interact
var curr_attack: int = 0
var d_counter: int = 3
var s_counter: int = 1
var battle_count: int = 0
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
var isDefended = false
var isBuffed = false
var isDebuffed = false
var isProtected = false
var isStaggered = false
var lost_HP = false
var enraged_check = false
@onready var def_icon = $"Defensive Icon"
@onready var off_icon = $"Offensive  Icon" 
@onready var trick_icon = $"Tricky Icon"
@onready var sup_icon = $"Supportive Icon"
@onready var HP_Bar = $HP
@onready var animation = $AnimationPlayer
@onready var debuff_icon = $"Debuffed Icon"
@onready var stagger_bar = $Stagger
@onready var stagger_icon = $"Staggered Icon"
@onready var stagger_num = $Stagger/Label

signal enemy_stagger
signal send_e_style
signal enemy_turn
signal enemy_dealt_damage
signal won
signal e_attack_anim
signal e_star_beam_anim
signal e_black_hole_anim
signal e_shred_anim
signal e_burst_anim

func _ready():
	curr_interact = Interaction.NORMAL
	battle_count = Tech.get_count()
	if(battle_count == 1):
		curr_style = Playstyle.OFFENSIVE
		max_HP = 500
		curr_HP = 500
		ATK = 75
		DEF = 50
	elif(battle_count == 2):
		curr_style = Playstyle.TRICKY
		max_HP = 550
		curr_HP = 550
		ATK = 85
		DEF = 45
	elif(battle_count == 3):
		curr_style = Playstyle.SUPPORTIVE  
		max_HP = 615
		curr_HP = 615
		ATK = 90
		DEF = 50
	elif(battle_count == 4):
		curr_style = Playstyle.DEFENSIVE 
		max_HP = 685
		curr_HP = 685
		ATK = 100
		DEF = 60
	HP_Bar.max_value = curr_HP
	HP_Bar.value = curr_HP
	send_e_style.emit(curr_style)

func ko_check():
	if(battle_count == 1):
		if(curr_HP <= 0):
			is_KOed = true
			won.emit()
	else:
		if(curr_HP <= 0 && !lost_HP):
			lost_HP = true
			#print(max_HP)
			curr_HP = max_HP * .55
			HP_Bar.max_value = curr_HP
			HP_Bar.value = curr_HP
			#print(curr_HP)
			#print(HP_Bar.value)
			enraged()
		elif(curr_HP <= 0):
			is_KOed = true
			won.emit()

func enraged():
	ATK += 25
	DEF += 20
	enraged_check = true

func get_style():
	return curr_style;

func def_switch():
	curr_style = Playstyle.DEFENSIVE
	if(battle_count == 1):
		off_icon.hide()
		def_icon.show()
	else:
		sup_icon.hide()
		def_icon.show()

func off_switch():
	curr_style = Playstyle.OFFENSIVE
	def_icon.hide()
	off_icon.show()

func trick_switch():
	curr_style = Playstyle.TRICKY
	if(battle_count == 2):
		sup_icon.hide()
		trick_icon.show()
	else:
		off_icon.hide()
		trick_icon.show()

func support_switch():
	curr_style = Playstyle.SUPPORTIVE
	trick_icon.hide()
	sup_icon.show()
	
func _debuffed():
	if(isDebuffed):
		d_counter = 3
	else:
		isDebuffed = true
		ATK -= 10
		DEF -= 10
		debuff_icon.show()
		d_counter = 3

func debuff_check():
	if(isDebuffed):
		d_counter -= 1
		if(d_counter == 0):
			isDebuffed = false
			ATK += 10
			DEF += 10
			debuff_icon.hide()

func defend_check():
	if(isDefended):
		isDefended = false

func _check_stagger():
	if(curr_stagger <= 0 && !isStaggered):
		isStaggered = true
		enemy_stagger.emit(true)
		stagger_icon.show()
		
func _stagger_dam(shred, enchance, ult):
	var stag_dam
	if(curr_interact == Interaction.STRONG):
		stag_dam = 4
	elif(curr_interact == Interaction.WEAK):
		stag_dam = 6
	else:
		stag_dam = 5

	if(shred):
		stag_dam += 2

	if(enchance):
		stag_dam += 2

	if(ult || isStaggered):
		stag_dam = 0
		
	curr_stagger -= stag_dam
	if(curr_stagger < 0):
		curr_stagger = 0
	stagger_bar.value -= stag_dam
	var placeholder = "{num}"
	var actual = placeholder.format({"num": str(stagger_bar.value)})
	stagger_num.text = actual
	
func _check_interaction(pStyle):
	var eStyle = curr_style
	if((pStyle == Playstyle.DEFENSIVE && eStyle == Playstyle.TRICKY) || 
	(pStyle == Playstyle.OFFENSIVE && eStyle == Playstyle.DEFENSIVE) ||
	(pStyle == Playstyle.TRICKY && eStyle == Playstyle.OFFENSIVE)):
		curr_interact = Interaction.STRONG
	elif((pStyle == Playstyle.DEFENSIVE && eStyle == Playstyle.OFFENSIVE) || 
	(pStyle == Playstyle.OFFENSIVE && eStyle == Playstyle.TRICKY) ||
	(pStyle == Playstyle.TRICKY && eStyle == Playstyle.DEFENSIVE)):
		curr_interact = Interaction.WEAK
	else:
		curr_interact = Interaction.NORMAL
	
	
	
func _on_player_dealt_damage(damage, style, is_shred, is_enhanced, is_ult):
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
	curr_HP -= true_dam
	HP_Bar.value -= true_dam	
	animation.play("Hurt")
	#"enemy_hurt.emit(true_dam)"
	_stagger_dam(is_shred, is_enhanced, is_ult)
	_check_stagger()
	ko_check()
	#print(curr_HP)

	
func _on_player_debuffed_enemy():
	if(!isDebuffed):
		_debuffed()

func enemy_attack():
	defend_check()
	curr_attack = Tech.take_damage(ATK, "Attack")
	enemy_dealt_damage.emit(curr_attack, curr_style)
	debuff_check()
	e_attack_anim.emit()

func enemy_spell():
	defend_check()
	if(curr_style == Playstyle.DEFENSIVE):
		curr_attack = Tech.take_damage(ATK, "Star_Beam")
		enemy_dealt_damage.emit(curr_attack, curr_style)
		e_star_beam_anim.emit()
	elif(curr_style == Playstyle.OFFENSIVE):
		curr_attack = Tech.take_damage(ATK, "Black_Hole")
		enemy_dealt_damage.emit(curr_attack, curr_style)
		e_black_hole_anim.emit()
	elif(curr_style == Playstyle.TRICKY):
		curr_attack = Tech.take_damage(ATK, "Shredder")
		enemy_dealt_damage.emit(curr_attack, curr_style)
		e_shred_anim.emit()
	elif(curr_style == Playstyle.SUPPORTIVE):
		curr_attack = Tech.take_damage(ATK, "Burst")
		enemy_dealt_damage.emit(curr_attack, curr_style)
		e_burst_anim.emit()
	debuff_check()


func enemy_switch():
	defend_check()
	if(battle_count == 1):
		if(curr_style == Playstyle.DEFENSIVE):
			off_switch()
		else:
			def_switch()
	elif(battle_count == 2):
		if(curr_style == Playstyle.TRICKY):
			support_switch()
		else:
			trick_switch()
	else:
		if(curr_style == Playstyle.DEFENSIVE):
			off_switch()
		elif(curr_style == Playstyle.OFFENSIVE):
			trick_switch()
		elif(curr_style == Playstyle.TRICKY):
			support_switch()
		elif(curr_style == Playstyle.SUPPORTIVE):
			def_switch()
	debuff_check()

func enemy_defend():
	if(!isDefended):
		isDefended = true
	debuff_check()

func stag_check():
	if(s_counter == 0):
		isStaggered = false
		stagger_icon.hide()
		curr_stagger = max_stagger
		stagger_bar.value = curr_stagger
		var placeholder = "{num}"
		var actual = placeholder.format({"num": str(stagger_bar.value)})
		stagger_num.text = actual
		s_counter = 1
		

func _on_player_trigger_e_turn():
	stag_check()
	if(lost_HP && enraged_check):
		enraged_check = false
		enemy_turn.emit("Enraged")
	elif(!isStaggered):
		var rng = randi() % 100
		if(battle_count == 1):
			if(rng > 75 && rng <= 100):
				enemy_attack()
				enemy_turn.emit("Attack")
			elif(rng > 50 && rng <= 75):
				enemy_spell()
				enemy_turn.emit("Spell")
			elif(rng > 25 && rng <= 50):
				enemy_switch()
				enemy_turn.emit("Switch")
			else:
				enemy_defend()
				enemy_turn.emit("Defend")
		elif(battle_count == 2):
			if(rng > 90 && rng <= 100):
				enemy_attack()
				enemy_turn.emit("Attack")
			elif(rng > 45 && rng <= 90):
				enemy_spell()
				enemy_turn.emit("Spell")
			elif(rng > 15 && rng <= 45):
				enemy_switch()
				enemy_turn.emit("Switch")
			else:
				enemy_defend()
				enemy_turn.emit("Defend")
		elif(battle_count == 3):
			if(rng > 85 && rng <= 100):
				enemy_attack()
				enemy_turn.emit("Attack")
			elif(rng > 50 && rng <= 85):
				enemy_spell()
				enemy_turn.emit("Spell")
			elif(rng > 20 && rng <= 50):
				enemy_switch()
				enemy_turn.emit("Switch")
			else:
				enemy_defend()
				enemy_turn.emit("Defend")
		elif(battle_count == 4):
			if(rng > 80 && rng <= 100):
				enemy_attack()
				enemy_turn.emit("Attack")
			elif(rng > 35 && rng <= 80):
				enemy_spell()
				enemy_turn.emit("Spell")
			elif(rng > 10 && rng <= 35):
				enemy_switch()
				enemy_turn.emit("Switch")
			else:
				enemy_defend()
				enemy_turn.emit("Defend")
	else:
		s_counter -= 1
		enemy_turn.emit("Stagger")
