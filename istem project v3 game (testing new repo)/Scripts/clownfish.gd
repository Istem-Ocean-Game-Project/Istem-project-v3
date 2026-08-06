#everyone will look at this script eventually so important info:
#Layer 1 = Player
#Layer 2 = Walls
#Layer 3 = HarpoonProjectile
#Layer 11 = Enemies hurtbox
#test5767767575
extends CharacterBody2D
var speed = 185
var damage_occuring = false
var aggro = false
var chase_subject = null
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var current_health = 2
var kbtime = 0.0
var kbvelocity = Vector2.ZERO
@onready var damage_number_template: damage_number_template = $damage_number_template
var nearbyclownfish: Array[Node2D] = []
var separationdirection = Vector2.ZERO
var separationstrength = 80.0
	
func _ready() -> void:
		animated_sprite_2d.play("idle")
func _process(_delta): #x axis flipping for now
	
	if not chase_subject == null and chase_subject.position.x > position.x:
		animated_sprite_2d.flip_h = true
	elif not chase_subject == null and chase_subject.position.x < position.x:
		animated_sprite_2d.flip_h = false
	
	
	if current_health <= 0:
		queue_free()
		
		
func _on_aggro_area_body_entered(body):
	chase_subject = body
	aggro = true
	animated_sprite_2d.play("aggro")
	print('entered')
	
	
	
func _on_aggro_area_body_exited(_body: Node2D) -> void:
	chase_subject = null
	aggro = false
	animated_sprite_2d.play("idle")
	print("exited")



func _physics_process(_delta):
	if kbtime > 0:
		kbtime 	-= _delta
		velocity = kbvelocity
	else:
		if aggro and chase_subject:
			velocity = (chase_subject.global_position - global_position).normalized() * speed
			separationdirection = Vector2.ZERO
			for fish in nearbyclownfish:
				if is_instance_valid(fish):
					separationdirection += (global_position - fish.global_position).normalized()

			if separationdirection != Vector2.ZERO:
				separationdirection = separationdirection.normalized()
				velocity += separationdirection * separationstrength
		else: 
			velocity = Vector2.ZERO

	
	move_and_slide()
	
	
#damage script below
func take_damage(amount: int):
	current_health -= amount
	animation_player.play("damaged")
	damage_number_template.spawn_label(amount, false)
	await get_tree().create_timer(0.1).timeout
	

# knockback script below
func take_kb(source_position: Vector2):
	var kbdirection = (global_position - source_position).normalized()
	kbvelocity = kbdirection * 600
	kbtime = 0.12
#func _on_template_hurtbox_area_entered(area: Area2D) -> void:
	#var kbdirection = (global_position - area.global_position).normalized()
	#kbvelocity = kbdirection * 600
	#kbtime = 0.12

func on_SeperationArea_entered(body: Node2D) -> void:
	if body != self and body not in nearbyclownfish:
		nearbyclownfish.append(body)
	
func on_SeperationArea_exited(body: Node2D) -> void:
	nearbyclownfish.erase(body)



	
