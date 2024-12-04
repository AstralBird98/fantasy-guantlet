extends Node2D
#@onready var hp: ProgressBar = $Player/HP
#@onready var mp: ProgressBar = $Player/MP
#@onready var special: ProgressBar = $Player/Special
#@onready var defensive_icon: Sprite2D = $"Player/Defensive Icon"
#@onready var offensive__icon: Sprite2D = $"Player/Offensive  Icon"
#@onready var tricky_icon: Sprite2D = $"Player/Tricky Icon"
#@onready var supportive_icon: Sprite2D = $"Player/Supportive Icon"
#@onready var animation_player: AnimationPlayer = $Player/AnimationPlayer
#
var party: Array = []


# Called when the node enters the scene tree for the first time.
func _ready():
	party = get_children()
	for p in party.size():
		party[p].position = Vector2(0, p * 32)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
