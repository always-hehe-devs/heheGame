extends CharacterBody2D


@export var speed: float = 300.0
@export var jump_velocity = -200.0
@export var double_jump_velocity = -150.0
@onready var anim = %AnimatedSprite2D

var direction : Vector2 = Vector2.ZERO
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var has_double_jumped: bool = false
var animation_locked: bool = false
var was_in_air: bool = false
var ground_point = 0

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _physics_process(delta):
	if is_multiplayer_authority():
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			has_double_jumped = false
			
		if Input.is_action_just_pressed("jump"):
			if is_on_floor():
				jump()
			elif not has_double_jumped:
				velocity.y = double_jump_velocity
				has_double_jumped = true
		
		if Input.is_action_just_pressed("roll"):
			roll()
		
		direction = Input.get_vector("move_left", "move_right", "ui_up", "ui_down")
		if direction:
			velocity.x = direction.x * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	
	move_and_slide()
	update_facing_direction()
	update_animation()
	
func update_facing_direction():
	if direction.x > 0:
		anim.flip_h = false
	elif direction.x < 0:
		anim.flip_h = true

func update_animation():
	if ground_point < velocity.y:
		animation_locked = false
		anim.play("fall")
	else:
		if not animation_locked:
			if direction.x != 0:
				anim.play("run")
			else:
				anim.play("idle")
			
func jump():
	velocity.y = jump_velocity
	anim.play("jump_start")
	animation_locked = true
	
func roll():
	anim.play("roll")
	animation_locked = true
