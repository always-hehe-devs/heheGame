extends Node2D

@onready var anim = $AnimatedSprite2D

func _ready():
	anim.play("run")
