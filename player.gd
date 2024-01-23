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

var attacking = false
var rolling = false
var facing = 1
var turning = false

func _physics_process(delta):
	
	if not is_on_floor():
		attacking = false
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
	if direction and not rolling and not attacking:
		velocity.x = direction.x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
	if Input.is_action_just_pressed("roll"):
		if not rolling and is_on_floor():
			rolling = true
	
	if Input.is_action_just_pressed("attack"):
		attack()
	
	overlapping_players = %PlayerBox.get_overlapping_areas()
	for player_area in overlapping_players:
		if player_area != self:
			another_player = player_area.get_parent()
	
	if Input.is_action_just_pressed("grab"):
		if overlapping_players.size() > 0 and another_player and not is_grabbed:
			is_grabbed = true
	if Input.is_action_just_released("grab"):
		if is_grabbed:
			is_grabbed = false
			
	update_grab()
	update_roll(delta)
	move_and_slide()
	update_facing_direction()
	update_animation()
	
func update_facing_direction():
	if direction.x > 0:
		turn_around()
		facing = 1
	elif direction.x < 0:
		turn_around()
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
				
func turn_around():
	if facing == 1 and direction.x < 0:
		anim.play("turn")
		anim.flip_h = false
		animation_locked = true
		if not animation_locked:
			anim.flip_h = true
	elif facing == 1 and direction.x > 0:
		anim.flip_h = false
	
	if facing == -1 and direction.x > 0:
		anim.play("turn")
		animation_locked = true
		anim.flip_h = true
		if not animation_locked:
			anim.flip_h = true
	elif facing == -1 and direction.x < 0:
		anim.flip_h = true
			
func jump():
	velocity.y = jump_velocity
	anim.play("jump_start")
	animation_locked = true
	
func attack():
	anim.play("attack")
	attacking = true
	animation_locked = true
	
func update_roll(delta):
	if rolling:
		position.x += facing * delta * speed
		anim.play("roll")
		animation_locked = true
	
func _on_animated_sprite_2d_animation_finished():
	animation_locked = false
	attacking = false
	rolling = false

func update_grab():
	if another_player and is_grabbed:
		another_player.global_position = global_position
	
