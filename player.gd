extends CharacterBody2D


@export var speed: float = 200.0
@export var jump_velocity = -200.0
@export var double_jump_velocity = -150.0
@onready var anim = %AnimatedSprite2D

var direction : Vector2 = Vector2.ZERO
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var has_double_jumped: bool = false
var animation_locked: bool = false
var was_in_air: bool = false
var ground_point = 0

var is_grabbed = false
var another_player = null
var overlapping_players = []

var rolling = false
var facing = 1


func _enter_tree():
	set_multiplayer_authority(name.to_int())
	%Camera2D.enabled = is_multiplayer_authority()

func _physics_process(delta):
	if is_multiplayer_authority():
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			has_double_jumped = false
		
		
		if Input.is_action_just_pressed("jump"):
			rolling = false
			if is_on_floor():
				jump()
			elif not has_double_jumped:
				velocity.y = double_jump_velocity
				has_double_jumped = true
		
		direction = Input.get_vector("move_left", "move_right", "ui_up", "ui_down")
		if direction and not rolling:
			velocity.x = direction.x * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			
		if Input.is_action_just_pressed("roll"):
			if not rolling and is_on_floor():
				rolling = true
		
		overlapping_players = %PlayerBox.get_overlapping_areas()
		for player_area in overlapping_players:
			if player_area != self:
				another_player = player_area.get_parent()
		
		if Input.is_action_just_pressed("grab"):
			if overlapping_players.size() > 0 and another_player:
				grab_character()
		if Input.is_action_just_released("grab"):
			if is_grabbed:
				is_grabbed = false
				print("Released")
	
	roll(delta)
	move_and_slide()
	update_facing_direction()
	update_animation()
	
func update_facing_direction():
	if direction.x > 0:
		anim.flip_h = false
		facing = 1
	elif direction.x < 0:
		anim.flip_h = true
		facing = -1

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
	
func roll(delta):
	if rolling:
		position[0] += facing * delta * 200
		anim.play("roll")
		animation_locked = true
	
func _on_animated_sprite_2d_animation_finished():
	animation_locked = false
	rolling = false
	
func grab_character():
	if not is_grabbed and another_player:
		another_player.global_position[0] += 20
		is_grabbed = true
		print(another_player.global_position)
	
