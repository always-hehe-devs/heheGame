extends CharacterBody2D


@export var speed: float = 300.0
@export var jump_velocity = -200.0
@export var double_jump_velocity = -150.0
@onready var anim = %knight

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var has_double_jumped: bool = false


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		has_double_jumped = false

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_velocity
		elif not has_double_jumped:
			velocity.y = double_jump_velocity
			has_double_jumped = true


	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
		anim.play_run_animation()
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		anim.play_idle_animation()

	move_and_slide()
