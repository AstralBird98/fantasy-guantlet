extends Node2D

@onready var norm = $Commands
@onready var ult_button = $Commands/Selection/Ultimate
@onready var def_spell = $"Defensive Spells"
@onready var off_spell = $"Offensive Spells"
@onready var tri_spell=  $"Tricky Spells"
@onready var sup_spell = $"Supportive Spells"
@onready var def_switch = $"Defensive Switch"
@onready var off_switch = $"Offensive Switch"
@onready var tri_switch = $"Tricky Switch"
@onready var sup_switch = $"Supportive Switch"
@onready var burst_switch = $"Burst Switch"
@onready var item = $Items
@onready var def_icon = $"Player_Party/Player/Defensive Icon"
@onready var off_icon = $"Player_Party/Player/Offensive  Icon"
@onready var trick_icon = $"Player_Party/Player/Tricky Icon"
@onready var support_icon = $"Player_Party/Player/Supportive Icon"
#@onready var ult_check = $"Player_Party/Player".ult_ready
@onready var timer = $Timer
@onready var tips = $TextureRect2
var curr_index: int = 0
var curr_size: int = 0
var E_Stock: int = 3;
var BS_Stock: int = 2;
var DD_Stock: int = 2;
var BB_Stock: int = 1;
var MP_Check: int = 150;
var Special_Check: int = 0;

var in_stock_e = true
var in_stock_bs = true
var in_stock_dd = true
var in_stock_bb = true

var ult_ready = false
var normal_select = false
var spell_select = false
var switch_select = false
var item_select = false

var isDef = true
var isOff = false
var isTrick = false
var isSup = false

var burst = false

var show_damage
var rem = 0

var curr_state
var curr_prompt
var active_timer = false

var count;

signal select_attack
signal select_def_spell
signal select_enhanced_def
signal select_off_spell
signal select_enhanced_off
signal select_trick_spell
signal select_enhanced_trick
signal select_support_spell
signal select_enhanced_support
signal select_defend
signal switch_to_def
signal switch_to_off
signal switch_to_trick
signal switch_to_support
signal select_elixir
signal select_BS
signal select_DD
signal select_BB
signal switch_burst
signal select_ult

signal normal_menu
signal def_spell_menu
signal off_spell_menu
signal trick_spell_menu
signal support_spell_menu
signal def_switch_menu
signal off_switch_menu
signal trick_switch_menu
signal support_switch_menu
signal item_menu


enum State{
	PLAYER_TURN,
	ENEMY_TURN,
	WIN,
	LOSS,
	TIPS
}

enum Prompt{
	ATTACK,
	DEFEND,
	SPELL,
	SWITCH,
	STAGGER,
	ENRAGED
}
# Called when the node enters the scene tree for the first time.
func _ready():
	$Panel.hide()
	count = Tech.get_count()
	if(count == 1):
		display_text("The Electric Rat appears!")
	elif(count == 2):
		display_text("The Sacred Phoenix appears!")
	elif(count == 3):
		display_text("The Emerald Dragon appears!")
	elif(count == 4):
		display_text("The Otherworldly Harbinger appears!")
	normal_select = true
	curr_size = 5
	isDef = true
	normal_menu.emit()
	curr_state = State.PLAYER_TURN
	curr_prompt = Prompt.ATTACK
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func display_text(text):
	$Panel.show()
	$Panel/Label.text = text

func check_stock():
	if(E_Stock == 0):
		in_stock_e = false
	if(BS_Stock == 0):
		in_stock_bs = false
	if(DD_Stock == 0):
		in_stock_dd = false
	if(BB_Stock == 0):
		in_stock_bb = false

func _input(event):
	if(Input.is_action_just_pressed("ui_up") && curr_index != 0):
		curr_index -= 1
	elif(Input.is_action_just_pressed("ui_down") && curr_index != curr_size-1):
		curr_index += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(Input.is_action_pressed("ui_quit")):
		get_tree().quit()
	if(curr_state == State.WIN):
		if(count == 4):
			display_text("You've beaten the game! Thank you for playing! Press Tab to quit.")
			if(Input.is_action_pressed("ui_focus_next")):
				get_tree().quit()
		else:
			display_text("You Won! Press Space to continue or Tab to quit.")
			if(Input.is_action_pressed("ui_select")):
				Tech.won_battle()
				count = Tech.get_count()
				if(count == 2):
					get_tree().change_scene_to_file("res://Battle_2.tscn")
				elif(count == 3):
					get_tree().change_scene_to_file("res://Battle_3.tscn")
				elif(count == 4):
					get_tree().change_scene_to_file("res://Battle_4.tscn")
			elif(Input.is_action_pressed("ui_focus_next")):
				get_tree().quit()
	elif(curr_state == State.LOSS):
		display_text("You Lost... Press Space to quit.")
		if(Input.is_action_pressed("ui_select")):
			get_tree().quit()
	elif(curr_state == State.ENEMY_TURN):
		if(curr_prompt == Prompt.ATTACK):
			display_text("The enemy attacks!")
		elif(curr_prompt == Prompt.SPELL):
			display_text("The enemy casts a spell!")
		elif(curr_prompt == Prompt.SWITCH):
			display_text("The enemy switch playstyles!")
		elif(curr_prompt == Prompt.DEFEND):
			display_text("The enemy defends!")
		elif(curr_prompt == Prompt.STAGGER):
			display_text("The enemy is unable to move!")
		elif(curr_prompt == Prompt.ENRAGED):
			display_text("The enemy's mad!")
		if(!active_timer):
			timer.start()
			active_timer = true
	elif(curr_state == State.TIPS):
		if(Input.is_action_just_pressed("ui_T")):
			tips.hide()
			curr_state = State.PLAYER_TURN
	elif(curr_state == State.PLAYER_TURN):
		if(ult_ready && normal_select && curr_index == 0 && Input.is_action_just_pressed("ui_accept")):
			ult_button.hide()
			rem = 0
			curr_size = 5
			curr_index = 0
			ult_ready = false
			curr_state = State.ENEMY_TURN
			select_ult.emit()
			normal_menu.emit()
		elif(Input.is_action_just_pressed("ui_accept") && curr_index == 1 + rem && normal_select):
			norm.hide()
			if(isDef):
				def_spell.show()
				def_spell_menu.emit()
			elif(isOff):
				off_spell.show()
				off_spell_menu.emit()
			elif(isSup):
				sup_spell.show()
				support_spell_menu.emit()
			elif(isTrick):
				tri_spell.show()
				trick_spell_menu.emit()
			normal_select = false
			spell_select = true
			curr_index = 1
			curr_size = 3
		elif(Input.is_action_just_pressed("ui_accept") && curr_index == 0 && spell_select && isDef):
			norm.show()
			def_spell.hide()
			normal_select = true
			spell_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			normal_menu.emit()
		elif(Input.is_action_just_pressed("ui_accept") && curr_index == 0 && spell_select && isOff):
			norm.show()
			off_spell.hide()
			normal_select = true
			spell_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			normal_menu.emit()
		elif(Input.is_action_just_pressed("ui_accept") && curr_index == 0 && spell_select && isTrick):
			norm.show()
			tri_spell.hide()
			normal_select = true
			spell_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			normal_menu.emit()
		elif(Input.is_action_just_pressed("ui_accept") && curr_index == 0 && spell_select && isSup):
			norm.show()
			sup_spell.hide()
			normal_select = true
			spell_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			normal_menu.emit()
		elif(Input.is_action_just_pressed("ui_accept") && curr_index == 4 + rem && normal_select):
			norm.hide()
			item.show()
			normal_select = false
			item_select = true
			curr_index = 1
			curr_size = 5
			item_menu.emit()
		elif(Input.is_action_just_pressed("ui_accept") && curr_index == 0 && item_select):
			norm.show()
			item.hide()
			normal_select = true
			item_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			normal_menu.emit()
		elif(Input.is_action_just_pressed("ui_accept") && curr_index == 2 + rem && isDef && normal_select):
			norm.hide()
			def_switch.show()
			normal_select = false
			switch_select = true
			curr_index = 1
			curr_size = 4
			def_switch_menu.emit()
		elif(Input.is_action_just_pressed("ui_accept") && curr_index == 2 + rem && isOff && normal_select):
			norm.hide()
			off_switch.show()
			normal_select = false
			switch_select = true
			curr_index = 1
			curr_size = 4
			off_switch_menu.emit()
		elif(Input.is_action_just_pressed("ui_accept") && curr_index == 2 + rem && isTrick && normal_select):
			norm.hide()
			tri_switch.show()
			normal_select = false
			switch_select = true
			curr_index = 1
			curr_size = 4
			trick_switch_menu.emit()
		elif(Input.is_action_just_pressed("ui_accept") && curr_index == 2 + rem && isSup && normal_select):
			norm.hide()
			sup_switch.show()
			normal_select = false
			switch_select = true
			curr_index = 1
			curr_size = 4
			support_switch_menu.emit()
		elif(Input.is_action_just_pressed("ui_accept") && curr_index == 0 && switch_select && isDef):
			norm.show()
			def_switch.hide()
			normal_select = true
			switch_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			normal_menu.emit()
		elif(Input.is_action_just_pressed("ui_accept") && curr_index == 0 && switch_select && isOff):
			norm.show()
			off_switch.hide()
			normal_select = true
			switch_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			normal_menu.emit()
		elif(Input.is_action_just_pressed("ui_accept") && curr_index == 0 && switch_select && isTrick):
			norm.show()
			tri_switch.hide()
			normal_select = true
			switch_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			normal_menu.emit()
		elif(Input.is_action_just_pressed("ui_accept") && curr_index == 0 && switch_select && isSup):
			norm.show()
			sup_switch.hide()
			normal_select = true
			switch_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			normal_menu.emit()
		elif(Input.is_action_just_pressed("ui_accept") && curr_index == 1 && switch_select && isDef):
			norm.show()
			def_switch.hide()
			isDef = false
			isOff = true
			def_icon.hide()
			off_icon.show()
			normal_select = true
			switch_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			curr_state = State.ENEMY_TURN
			normal_menu.emit()
			switch_to_off.emit()
		elif(Input.is_action_just_pressed("ui_accept") && curr_index == 2 && switch_select && isDef):
			norm.show()
			def_switch.hide()
			isDef = false
			isTrick = true
			def_icon.hide()
			trick_icon.show()
			normal_select = true
			switch_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			curr_state = State.ENEMY_TURN
			normal_menu.emit()
			switch_to_trick.emit()
		elif(Input.is_action_just_pressed("ui_accept") && curr_index == 3 && switch_select && isDef):
			norm.show()
			def_switch.hide()
			isDef = false
			isSup = true
			def_icon.hide()
			support_icon.show()
			normal_select = true
			switch_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			curr_state = State.ENEMY_TURN
			normal_menu.emit()
			switch_to_support.emit()
		elif(Input.is_action_just_pressed("ui_accept") && curr_index == 1 && switch_select && isOff):
			norm.show()
			off_switch.hide()
			isOff = false
			isDef = true
			off_icon.hide()
			def_icon.show()
			normal_select = true
			switch_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			curr_state = State.ENEMY_TURN
			normal_menu.emit()
			switch_to_def.emit()
		elif(Input.is_action_just_pressed("ui_accept") && curr_index == 2 && switch_select && isOff):
			norm.show()
			off_switch.hide()
			isOff = false
			isTrick = true
			off_icon.hide()
			trick_icon.show()
			normal_select = true
			switch_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			curr_state = State.ENEMY_TURN
			normal_menu.emit()
			switch_to_trick.emit()
		elif(Input.is_action_just_pressed("ui_accept") && curr_index == 3 && switch_select && isOff):
			norm.show()
			off_switch.hide()
			isOff = false
			isSup = true
			off_icon.hide()
			support_icon.show()
			normal_select = true
			switch_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			curr_state = State.ENEMY_TURN
			normal_menu.emit()
			switch_to_support.emit()
		elif(Input.is_action_just_pressed("ui_accept") && curr_index == 1 && switch_select && isTrick):
			norm.show()
			tri_switch.hide()
			isTrick = false
			isDef = true
			trick_icon.hide()
			def_icon.show()
			normal_select = true
			switch_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			curr_state = State.ENEMY_TURN
			normal_menu.emit()
			switch_to_def.emit()
		elif(Input.is_action_just_pressed("ui_accept") && curr_index == 2 && switch_select && isTrick):
			norm.show()
			tri_switch.hide()
			isTrick = false
			isOff = true
			trick_icon.hide()
			off_icon.show()
			normal_select = true
			switch_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			curr_state = State.ENEMY_TURN
			normal_menu.emit()
			switch_to_off.emit()
		elif(Input.is_action_just_pressed("ui_accept") && curr_index == 3 && switch_select && isTrick):
			norm.show()
			tri_switch.hide()
			isTrick = false
			isSup = true
			trick_icon.hide()
			support_icon.show()
			normal_select = true
			switch_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			curr_state = State.ENEMY_TURN
			normal_menu.emit()
			switch_to_support.emit()
		elif(Input.is_action_just_pressed("ui_accept") && curr_index == 1 && switch_select && isSup):
			norm.show()
			sup_switch.hide()
			isSup = false
			isDef = true
			support_icon.hide()
			def_icon.show()
			normal_select = true
			switch_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			curr_state = State.ENEMY_TURN
			normal_menu.emit()
			switch_to_def.emit()
		elif(Input.is_action_just_pressed("ui_accept") && curr_index == 2 && switch_select && isSup):
			norm.show()
			sup_switch.hide()
			isSup = false
			isOff = true
			support_icon.hide()
			off_icon.show()
			normal_select = true
			switch_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			curr_state = State.ENEMY_TURN
			normal_menu.emit()
			switch_to_off.emit()
		elif(Input.is_action_just_pressed("ui_accept") && curr_index == 3 && switch_select && isSup):
			norm.show()
			sup_switch.hide()
			isSup = false
			isTrick = true
			support_icon.hide()
			trick_icon.show()
			normal_select = true
			switch_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			curr_state = State.ENEMY_TURN
			normal_menu.emit()
			switch_to_trick.emit()
		elif (Input.is_action_just_pressed("ui_accept") && curr_index == 0 + rem && normal_select):
			curr_index = 0
			curr_size = 5 + rem
			curr_state = State.ENEMY_TURN
			select_attack.emit()
		elif (Input.is_action_just_pressed("ui_accept") && curr_index == 1 && spell_select && isDef && MP_Check >= 30):
			norm.show()
			def_spell.hide()
			normal_select = true
			spell_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			curr_state = State.ENEMY_TURN
			select_def_spell.emit()
			normal_menu.emit()
		elif (Input.is_action_just_pressed("ui_accept") && curr_index == 2 && spell_select && isDef && MP_Check >= 30 && Special_Check >= 25):
			norm.show()
			def_spell.hide()
			normal_select = true
			spell_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			curr_state = State.ENEMY_TURN
			select_enhanced_def.emit()
			normal_menu.emit()
		elif (Input.is_action_just_pressed("ui_accept") && curr_index == 1 && spell_select && isOff && MP_Check >= 45):
			norm.show()
			off_spell.hide()
			normal_select = true
			spell_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			curr_state = State.ENEMY_TURN
			select_off_spell.emit()
			normal_menu.emit()
		elif (Input.is_action_just_pressed("ui_accept") && curr_index == 2 && spell_select && isOff && MP_Check >= 45 && Special_Check >= 25):
			norm.show()
			off_spell.hide()
			normal_select = true
			spell_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			curr_state = State.ENEMY_TURN
			select_enhanced_off.emit()
			normal_menu.emit()
		elif (Input.is_action_just_pressed("ui_accept") && curr_index == 1 && spell_select && isTrick && MP_Check >= 35):
			norm.show()
			tri_spell.hide()
			normal_select = true
			spell_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			curr_state = State.ENEMY_TURN
			select_trick_spell.emit()
			normal_menu.emit()
		elif (Input.is_action_just_pressed("ui_accept") && curr_index == 2 && spell_select && isTrick && MP_Check >= 35 && Special_Check >= 25):
			norm.show()
			tri_spell.hide()
			normal_select = true
			spell_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			curr_state = State.ENEMY_TURN
			select_enhanced_trick.emit()
			normal_menu.emit()
		elif (Input.is_action_just_pressed("ui_accept") && curr_index == 1 && spell_select && isSup && MP_Check >= 20):
			burst_switch.show()
			sup_spell.hide()
			burst = true
			spell_select = false
			select_support_spell.emit()
			switch_burst.emit()
			curr_index = 1
			curr_size = 4
		elif (Input.is_action_just_pressed("ui_accept") && curr_index == 2 && spell_select && isSup && MP_Check >= 20 && Special_Check >= 25):
			burst_switch.show()
			sup_spell.hide()
			burst = true
			spell_select = false
			select_enhanced_support.emit()
			switch_burst.emit()
			curr_index = 1
			curr_size = 4
		elif (Input.is_action_just_pressed("ui_accept") && curr_index == 1 && item_select && in_stock_e):
			norm.show()
			item.hide()
			normal_select = true
			item_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			curr_state = State.ENEMY_TURN
			select_elixir.emit()
			normal_menu.emit()
			E_Stock -= 1
			check_stock()
			MP_Check = 150
		elif (Input.is_action_just_pressed("ui_accept") && curr_index == 2 && item_select && in_stock_bs):
			norm.show()
			item.hide()
			normal_select = true
			item_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			curr_state = State.ENEMY_TURN
			select_BS.emit()
			normal_menu.emit()
			BS_Stock -= 1
			check_stock()
		elif (Input.is_action_just_pressed("ui_accept") && curr_index == 3 && item_select && in_stock_dd):
			norm.show()
			item.hide()
			normal_select = true
			item_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			curr_state = State.ENEMY_TURN
			select_DD.emit()
			normal_menu.emit()
			DD_Stock -= 1
			check_stock()
		elif (Input.is_action_just_pressed("ui_accept") && curr_index == 4 && item_select && in_stock_bb):
			norm.show()
			item.hide()
			normal_select = true
			item_select = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			curr_state = State.ENEMY_TURN
			select_BB.emit()
			normal_menu.emit()
			BB_Stock -= 1
			check_stock()
		elif (Input.is_action_just_pressed("ui_accept") && curr_index == 0 && burst):
			norm.show()
			burst_switch.hide()
			normal_select = true
			burst = false
			curr_index = 0 + rem
			curr_size = 5 + rem
			curr_state = State.ENEMY_TURN
			normal_menu.emit()
			switch_to_support.emit()
		elif (Input.is_action_just_pressed("ui_accept") && curr_index == 1 && burst):
			norm.show()
			burst_switch.hide()
			normal_select = true
			burst = false
			isSup = false
			isDef = true
			support_icon.hide()
			def_icon.show()
			curr_index = 0 + rem
			curr_size = 5 + rem
			curr_state = State.ENEMY_TURN
			normal_menu.emit()
			switch_to_def.emit()
		elif (Input.is_action_just_pressed("ui_accept") && curr_index == 2 && burst):
			norm.show()
			burst_switch.hide()
			normal_select = true
			burst = false
			isSup = false
			isOff = true
			support_icon.hide()
			off_icon.show()
			curr_index = 0 + rem
			curr_size = 5 + rem
			curr_state = State.ENEMY_TURN
			normal_menu.emit()
			switch_to_off.emit()
		elif (Input.is_action_just_pressed("ui_accept") && curr_index == 3 && burst):
			norm.show()
			burst_switch.hide()
			normal_select = true
			burst = false
			isSup = false
			isTrick = true
			support_icon.hide()
			trick_icon.show()
			curr_index = 0 + rem
			curr_size = 5 + rem
			curr_state = State.ENEMY_TURN
			normal_menu.emit()
			switch_to_trick.emit()
		elif (Input.is_action_just_pressed("ui_accept") && curr_index == 3 + rem && normal_select):
			curr_state = State.ENEMY_TURN
			select_defend.emit()
		elif(Input.is_action_just_pressed("ui_T")):
			tips.show()
			curr_state = State.TIPS
		if(spell_select && isDef):
			if(curr_index == 0 && Input.is_anything_pressed()):
				display_text("Return to command menu")
			elif(curr_index == 1 && Input.is_anything_pressed()):
				display_text("Cost 20% MP. Concentrated beam of astral energy. Grants more special gain.")
			elif(curr_index == 2 && Input.is_anything_pressed()):
				display_text("Cost 20% MP and 25% Special. Enhanced verison of Star Beam. Grants Protection to self.")
		elif(switch_select && isDef):
			if(curr_index == 0 && Input.is_anything_pressed()):
				display_text("Return to command menu")
			elif(curr_index == 1 && Input.is_anything_pressed()):
				display_text("Switch to Offensive playstyle. Good against Tricky foe and weak aganist Defensive foe.")
			elif(curr_index == 2 && Input.is_anything_pressed()):
				display_text("Switch to Tricky playstyle. Good against Defensive foe and weak aganist Offensive foe.")
			elif(curr_index == 3 && Input.is_anything_pressed()):
				display_text("Switch to Supportive playstyle. Neutral aganist all foe.")
		elif(spell_select && isOff):
			if(curr_index == 0 && Input.is_anything_pressed()):
				display_text("Return to command menu")
			elif(curr_index == 1 && Input.is_anything_pressed()):
				display_text("Cost 30% MP. Summon all-encompassing destroyer of reality. Does massive damage.")
			elif(curr_index == 2 && Input.is_anything_pressed()):
				display_text("Cost 30% MP and 25% of Special. Enhanced verison of Black Hole. Buffs self.")
		elif(switch_select && isOff):
			if(curr_index == 0 && Input.is_anything_pressed()):
				display_text("Return to command menu")
			elif(curr_index == 1 && Input.is_anything_pressed()):
				display_text("Switch to Defensive playstyle. Good against Offensive foe and weak aganist Tricky foe.")
			elif(curr_index == 2 && Input.is_anything_pressed()):
				display_text("Switch to Tricky playstyle. Good against Defensive foe and weak aganist Offensive foe.")
			elif(curr_index == 3 && Input.is_anything_pressed()):
				display_text("Switch to Supportive playstyle. Neutral aganist all foe.")
		if(spell_select && isTrick):
			if(curr_index == 0 && Input.is_anything_pressed()):
				display_text("Return to command menu")
			elif(curr_index == 1 && Input.is_anything_pressed()):
				display_text("Cost 23% MP. Tear through enemy's defenses. Greatly reduces target's stagger")
			elif(curr_index == 2 && Input.is_anything_pressed()):
				display_text("Cost 23% MP and 25% of Special. Enhanced verison of Shredder. Debuffs targeted foe.")
		elif(switch_select && isTrick):
			if(curr_index == 0 && Input.is_anything_pressed()):
				display_text("Return to command menu")
			elif(curr_index == 1 && Input.is_anything_pressed()):
				display_text("Switch to Defensive playstyle. Good against Offensive foe and weak aganist Tricky foe.")
			elif(curr_index == 2 && Input.is_anything_pressed()):
				display_text("Switch to Offensive playstyle. Good against Tricky foe and weak aganist Defensive foe.")
			elif(curr_index == 3 && Input.is_anything_pressed()):
				display_text("Switch to Supportive playstyle. Neutral aganist all foe.")
		if(spell_select && isSup):
			if(curr_index == 0 && Input.is_anything_pressed()):
				display_text("Return to command menu")
			elif(curr_index == 1 && Input.is_anything_pressed()):
				display_text("Cost 13% MP. Send ripples of space to assult enemy. Able to switch after attack.")
			elif(curr_index == 2 && Input.is_anything_pressed()):
				display_text("Cost 13% MP and 25% of Special. Enhanced verison of Burst. Heals self.")
		elif(switch_select && isSup):
			if(curr_index == 0 && Input.is_anything_pressed()):
				display_text("Return to command menu")
			elif(curr_index == 1 && Input.is_anything_pressed()):
				display_text("Switch to Defensive playstyle. Good against Offensive foe and weak aganist Tricky foe.")
			elif(curr_index == 2 && Input.is_anything_pressed()):
				display_text("Switch to Offensive playstyle. Good against Tricky foe and weak aganist Defensive foe.")
			elif(curr_index == 3 && Input.is_anything_pressed()):
				display_text("Switch to Tricky playstyle. Good against Defensive foe and weak aganist Offensive foe.")
		elif(item_select):
			var before_e = "Fully restore HP & MP. Uses: {stock}"
			var actual_e = before_e.format({"stock": str(E_Stock)})
			var before_bs = "Buff own stats. Uses: {stock}"
			var actual_bs = before_bs.format({"stock": str(BS_Stock)})
			var before_dd = "Debuff enemies' stats. Uses: {stock}"
			var actual_dd = before_dd.format({"stock": str(DD_Stock)})
			var before_bb = "Reduce oncoming attacks by half. Uses: {stock}"
			var actual_bb = before_bb.format({"stock": str(BB_Stock)})
			if(curr_index == 0 && Input.is_anything_pressed()):
				display_text("Return to command menu")
			elif(curr_index == 1 && Input.is_anything_pressed() && in_stock_e):
				display_text(actual_e)
			elif(curr_index == 1 && Input.is_anything_pressed() && !in_stock_e):
				display_text("Elixir is out of stock")
			elif(curr_index == 2 && Input.is_anything_pressed() && in_stock_bs):
				display_text(actual_bs)
			elif(curr_index == 2 && Input.is_anything_pressed() && !in_stock_bs):
				display_text("Buff Spice is out of stock")
			elif(curr_index == 3 && Input.is_anything_pressed() && in_stock_dd):
				display_text(actual_dd)
			elif(curr_index == 3 && Input.is_anything_pressed() && !in_stock_dd):
				display_text("Debuff Dust is out of stock")
			elif(curr_index == 4 && Input.is_anything_pressed() && in_stock_bb):
				display_text(actual_bb)
			elif(curr_index == 4 && Input.is_anything_pressed() && !in_stock_bb):
				display_text("Barrier Berries are out of stock")
		elif(normal_select && !ult_ready):
			if(curr_index == 0 && Input.is_anything_pressed()):
				display_text("Basic attack. Recovers a bit of MP.")
			elif(curr_index == 1 && Input.is_anything_pressed()):
				display_text("Arcane arts. Can be enhanced for special effects.")
			elif(curr_index == 2 && Input.is_anything_pressed()):
				display_text("Switch between playstyles for new spells and modified interactions.")
			elif(curr_index == 3 && Input.is_anything_pressed()):
				display_text("Defend against oncoming attacks. Reduce damage by half.")
			elif(curr_index == 4 && Input.is_anything_pressed()):
				display_text("Limited stock. Use for a varity of helpful effects.")
		elif(normal_select && ult_ready):
			if(curr_index == 0 && Input.is_anything_pressed()):
				display_text("Unleashed the ultimate upon foe. Deal extreme amount of damage and fully restore MP.")
			elif(curr_index == 1 && Input.is_anything_pressed()):
				display_text("Basic attack. Recovers a bit of MP.")
			elif(curr_index == 2 && Input.is_anything_pressed()):
				display_text("Arcane arts. Can be enhanced for special effects.")
			elif(curr_index == 3 && Input.is_anything_pressed()):
				display_text("Switch between playstyles for new spells and modified interactions.")
			elif(curr_index == 4 && Input.is_anything_pressed()):
				display_text("Defend against oncoming attacks. Reduce damage by half.")
			elif(curr_index == 5 && Input.is_anything_pressed()):
				display_text("Limited stock. Use for a varity of helpful effects.")
		elif(burst):
			if(curr_index == 0 && Input.is_anything_pressed()):
				display_text("Stay within current playstyle")
			elif(curr_index == 1 && Input.is_anything_pressed()):
				display_text("Switch to Defensive playstyle. Good against Offensive foe and weak aganist Tricky foe.")
			elif(curr_index == 2 && Input.is_anything_pressed()):
				display_text("Switch to Offensive playstyle. Good against Tricky foe and weak aganist Defensive foe.")
			elif(curr_index == 3 && Input.is_anything_pressed()):
				display_text("Switch to Tricky playstyle. Good against Defensive foe and weak aganist Offensive foe.")


func _on_player_mp_depletion(mp):
	MP_Check -= mp


func _on_player_usable_ult():
	ult_button.show()
	ult_ready = true
	curr_index = 1
	rem = 1
	curr_size = 6


func _on_player_mp_restore(mp):
	MP_Check += mp
	if(MP_Check > 150):
		MP_Check = 150


func _on_player_special_gain(sp):
	Special_Check += sp
	if(Special_Check > 100):
		Special_Check = 100
	#print(Special_Check, " Gain-Battle")


func _on_player_special_depletion(sp):
	if(Special_Check == 100):
		ult_button.hide()
		ult_ready = false
		curr_index = 0
		rem = 0
		curr_size = 5
	Special_Check -= sp
	if(Special_Check < 0):
		Special_Check = 0
	#print(Special_Check, " Deplete-Battle")



func _on_enemy_enemy_turn(text):
	if(text == "Attack"):
		curr_prompt = Prompt.ATTACK
	elif(text == "Spell"):
		curr_prompt = Prompt.SPELL
	elif(text == "Switch"):
		curr_prompt = Prompt.SWITCH
	elif(text == "Defend"):
		curr_prompt = Prompt.DEFEND
	elif(text == "Stagger"):
		curr_prompt = Prompt.STAGGER
	elif(text == "Enraged"):
		curr_prompt = Prompt.ENRAGED



func _on_player_defeated():
	curr_state = State.LOSS

func _on_enemy_won():
	curr_state = State.WIN

func _on_timer_timeout():
	curr_state = State.PLAYER_TURN
	active_timer = false
