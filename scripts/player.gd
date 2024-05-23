extends CharacterBody2D

@onready var dodge_cooldown = $Dodge_Cooldown
@onready var dodge_timer = $Dodge_Timer
@onready var jump_cooldown = $Jump_Cooldown
@onready var jumps_label = get_node("jumps_label")

@export var MAX_JUMPS = 2
@export var SPEED = 600.0
@export var MAX_SPEED = 600
@export var JUMP_VELOCITY = -700.0
@export var GRAVITY = 2500
@export var DODGE_POWER = 1600
@export var ACCELERATION = 6600
@export var DECELERATION = 6000

var CAN_DODGE = true
var CAN_JUMP = true
var JUMPS = 2
var IS_DODGING = false

func _physics_process(delta):
	
	# Add the gravity.
	if !is_on_floor():
		velocity.y += GRAVITY * delta
		
	# Update the jumps label text
	jumps_label.text = "Jumps: " + str(JUMPS)
	
	# Handle jump.
	if JUMPS > 0 and (is_on_floor() or jump_cooldown.is_stopped()):
		CAN_JUMP = true
	else:
		CAN_JUMP = false
	if is_on_floor():
		JUMPS = MAX_JUMPS

	if Input.is_action_just_pressed("jump") and CAN_JUMP:
		velocity.y = JUMP_VELOCITY
		JUMPS -= 1
		CAN_JUMP = false
		jump_cooldown.start()
		print("jump")
	var direction = Input.get_axis("move_left", "move_right")
	var dodge_direction = Vector2(direction, 0)
	
	if Input.is_action_just_pressed("dodge") and CAN_DODGE:
		# Set up the dodge mechanics here
		velocity += DODGE_POWER * dodge_direction
		IS_DODGING = true
		CAN_DODGE = false
		# Start the dodge cooldown timer
		dodge_cooldown.start()
		dodge_timer.start()
		print("dodge")

	if direction and !IS_DODGING:
		if direction > 0:
			# Accelerate right
			velocity.x = min(velocity.x + ACCELERATION * delta, MAX_SPEED)
		elif direction < 0:
			# Accelerate left
			velocity.x = max(velocity.x - ACCELERATION * delta, -MAX_SPEED)
	else:
		# Deceleration when no input
		if velocity.x > 0:
			velocity.x = max(velocity.x - DECELERATION * delta, 0)
		elif velocity.x < 0:
			velocity.x = min(velocity.x + DECELERATION * delta, 0)

	move_and_slide()

	if Input.get_axis("move_left", "move_right") == 0:
		$AnimatedSprite2D.play("idle")
	else:
		$AnimatedSprite2D.play("run")
		$AnimatedSprite2D.flip_h = velocity.x < 0
	if IS_DODGING:
		$AnimatedSprite2D.animation = "dodge"
		$AnimatedSprite2D.flip_h = velocity.x < 0
		$AnimatedSprite2D.frame = 0  # Reset the frame index
		$AnimatedSprite2D.play()

func _on_dodge_cooldown_timeout():
	CAN_DODGE = true
	print("dgcd")
	
func _on_dodge_timer_timeout():
	IS_DODGING = false
	print("dgtimer")


func _on_jump_cooldown_timeout():
	CAN_JUMP = true
	print("jcd")
