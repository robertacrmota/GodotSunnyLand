extends CharacterBody2D

var SPEED = 50
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player
var chasePlayer = false

@onready var animSprite = get_node("AnimatedSprite2D")

func _ready():
	animSprite.play("Idle")

func _physics_process(delta):
	# Add gravity to frog
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if animSprite.animation == "Death":
		return
	
	if chasePlayer:
		player = get_node("../../PlayerContainer/Player")
		var direction = (player.global_position - self.global_position).normalized()
		
		if direction.x > 0:
			animSprite.flip_h = true
		else:
			animSprite.flip_h = false
			
		velocity.x = direction.x * SPEED
		animSprite.play("Jump");
	else:
		velocity.x = 0
		animSprite.play("Idle");
		
	move_and_slide()

func _on_player_detection_area_body_entered(body):
	if body.name == "Player":
		chasePlayer = true

func _on_player_detection_area_body_exited(body):
	if body.name == "Player":
		chasePlayer = false

func _on_frog_death_area_body_entered(body):
	if body.name == "Player":
		die()

func _on_player_hurt_area_body_entered(body):
	if body.name == "Player" && animSprite.animation != "Death":
		Game.playerHP -= 3
		die()
	
func die():
	Game.Gold += 5
	Utils.saveGame()
	
	chasePlayer = false
	animSprite.play("Death")
	await animSprite.animation_finished
	self.queue_free()
