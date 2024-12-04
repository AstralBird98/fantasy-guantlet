extends Node2D
@onready var _focus = $Enemy/Focus
#@onready var hp: ProgressBar = $HP
#@onready var defensive_icon: Sprite2D = $"Defensive Icon"
#@onready var offensive__icon: Sprite2D = $"Offensive  Icon"
#@onready var tricky_icon: Sprite2D = $"Tricky Icon"
#@onready var supportive_icon: Sprite2D = $"Supportive Icon"
#@onready var stagger: ProgressBar = $Stagger
#@onready var animation_player: AnimationPlayer = $AnimationPlayer
var foes: Array = []
var index : int = 0

# Called when the node enters the scene tree for the first time.
func target():
	_focus.show()


func _ready():
	foes = get_children()
	for e in foes.size():
		foes[e].position = Vector2(0, e * 32)
	
