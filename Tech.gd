extends Node2D

#@onready var player = $Player
var battle_count: int = 1;
var curr_interact;

enum Interact{
	WEAK,
	NORMAL,
	STRONG
}
var pow_dict = {
	"Attack": 35,
	"Star_Beam": 50,
	"Star_Beam +": 60,
	"Black_Hole": 70,
	"Black_Hole +": 80,
	"Shredder": 40,
	"Shredder +": 50,
	"Burst": 30,
	"Burst +": 40,
	"Ultimate": 100
}


func won_battle():
	battle_count += 1

func get_count(): 
	return battle_count


func _ready():
	curr_interact = Interact.NORMAL

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func take_damage(atk, move_name):
	var power = pow_dict[move_name]
	var dam = (atk + power) 
	return dam

func check_interaction():
	"""
	if(
		(Player.get_style() == Player.Playstyle.DEFENSIVE && 
		Enemy1.get_style() == Enemy1.Playstyle.OFFENSIVE) ||
		(Player.get_style() == Player.Playstyle.TRICKY && 
		Enemy1.get_style() == Enemy1.Playstyle.DEFENSIVE 
		)
		 ):
	"""
	curr_interact = Interact.STRONG
	curr_interact = Interact.NORMAL
	curr_interact = Interact.WEAK
