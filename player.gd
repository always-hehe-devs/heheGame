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

var is_grabbed = false
var another_player = null
var overlapping_players = []
var lock_pos = false

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
		
		
		direction = Input.get_vector("move_left", "move_right", "ui_up", "ui_down")
		if direction:
			velocity.x = direction.x * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			
		if Input.is_action_just_pressed("roll"):
			roll()
		
		overlapping_players = %PlayerBox.get_overlapping_areas()
		for player_area in overlapping_players:
			if player_area != self:
				another_player = player_area.get_parent()
		
		if Input.is_action_just_pressed("grab"):
			if overlapping_players.size() > 0 and another_player:
				is_grabbed = true
		if Input.is_action_just_released("grab"):
			if is_grabbed:
				is_grabbed = false
				lock_pos = false
				print("Released")
	
	
	grab_character(delta)
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
	
func _on_animated_sprite_2d_animation_finished():
	animation_locked = false
	
func grab_character(delta):
	if is_grabbed and another_player and not lock_pos:
		another_player.global_position = self.global_position
		lock_pos = true
		print(another_player.global_position)
	
