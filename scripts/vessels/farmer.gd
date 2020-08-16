extends KinematicBody2D


# Declare member variables here. Examples:
var possessed = false

var move = Vector2()
var speed = 100

const abilityDelay = 1
var abilityTimer = 0

const dizzyDelay = 5
var dizzyTimer = 0

var state = Game.IDLE

var path = PoolVector2Array()


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("vessel")
	add_to_group("farmer")
	randomize()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	$dizzy.visible = state == Game.DIZZY
	$curious.visible = state == Game.CURIOUS
	
	match state:
		Game.POSSESSED:
			possessed(delta)
		Game.DIZZY:
			dizzy(delta)
		Game.IDLE:
			idle()
		Game.CURIOUS:
			curious()
	pass

func idle():
	$AnimationPlayer.play("idle")
	$CollisionShape2D/Sprite.flip_h = move.x < 0
	
	move = move*0.99
	move_and_slide(move)
	pass

func dizzy(delta):
	$AnimationPlayer.play("dizzy")
	move = Vector2(0,0)
	dizzyTimer = clamp(dizzyTimer - delta, 0, dizzyDelay)
	if dizzyTimer <= 0:
		state = Game.IDLE
	pass

func possessed(delta):
	$CollisionShape2D/Sprite.flip_h = not get_global_mouse_position().x > get_global_position().x
	$AnimationPlayer.play("idle")
	$Line2D.visible = state != Game.POSSESSED
	
	#MOVE
	move = Vector2(0,0)
	if Input.is_action_pressed("mouseL"):
		if get_global_mouse_position().distance_to(get_global_position()) > 20:
			move = (get_global_mouse_position() - get_global_position()).normalized() * speed
	move_and_slide(move)
	
	#SAY 'Hey!'
	abilityTimer = clamp(abilityTimer - delta, 0, abilityDelay)
	if abilityTimer <= 0:
		if Input.is_action_just_pressed("mouseR"):
			print("'Hey!'")
			abilityTimer = abilityDelay
	
	pass

func curious():
	move_and_slide((path[0]-global_position).normalized()*speed)
	if path[0].distance_to(global_position) <= 32:
		path.remove(0)
	if len(path) == 0:
		state = Game.IDLE
	$Line2D.global_position = Vector2(0,0)
	$Line2D.points = path
	get_node("Line2D").points = path
	pass

func _on_Timer_timeout():
	#NPC MOVEMENT
	if state != Game.POSSESSED:
		move = Vector2(((randf()-0.5)*2), ((randf()-0.5)*2)).normalized()*speed
		$Timer.wait_time = randf()*1
	pass # Replace with function body.

func get_curious(where):
	if state == Game.IDLE or state == Game.CURIOUS:
		state = Game.CURIOUS
		path = Game.get_main().get_node("Navigation2D").get_simple_path(global_position, where, false)
