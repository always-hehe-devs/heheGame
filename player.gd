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
var throwable_object = null
var overlapping_objects = []

var attacking = false
var rolling = false
var facing = 1

var thrown = false
var throw_speed = 600
var travelled_distance = 0
var throw_range = 1000
var throw_direction = 1

func _ready():
	anim.flip_h = false

func _physics_process(delta):
	
	if not is_on_floor():
		attacking = false
		velocity.y += gravity * delta
	else:
		has_double_jumped = false
		
	if Input.is_action_just_pressed("get_throwable"):
		get_throwable()
	
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
		if not rolling and is_on_floor() and not is_grabbed:
			rolling = true
		if is_grabbed:
			throw_direction = facing
			thrown = true
	
	if Input.is_action_just_pressed("attack"):
		attack()
		
	if Input.is_action_just_pressed("attack_second"):
		attack_secondary()
	
	overlapping_objects = %PlayerBox.get_overlapping_areas()
	for throwable in overlapping_objects:
		if throwable != self:
			throwable_object = throwable.get_parent()
	
	if Input.is_action_just_pressed("grab"):
		if overlapping_objects.size() > 0 and throwable_object and not is_grabbed:
			is_grabbed = true
	if Input.is_action_just_released("grab"):
		if is_grabbed:
			is_grabbed = false
	
	thrown_object(delta)
	update_grab()
	update_roll(delta)
	move_and_slide()
	update_facing_direction()
	update_animation()

func get_throwable():
	const THROWABLE = preload("res://throwable.tscn")
	var new_throwable = THROWABLE.instantiate()
	new_throwable.global_position = position
	self.get_parent().add_child(new_throwable)

func thrown_object(delta):
	if thrown:
		throwable_object.global_position.x += throw_direction * throw_speed * delta
		travelled_distance += throw_speed * delta
		if travelled_distance > throw_range:
			thrown = false
			throwable_object.queue_free()
		
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
	elif not animation_locked:
		if direction.x != 0:
			anim.play("run")
		else:
			anim.play("idle")
			
func jump():
	velocity.y = jump_velocity
	anim.play("jump_start")
	animation_locked = true
	
func attack():
	anim.play("attack")
	attacking = true
	animation_locked = true

func attack_secondary():
	anim.play("attack_second")
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
	if throwable_object and is_grabbed:
		throwable_object.global_position = global_position

