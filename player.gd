extends CharacterBody2D

const gravity = 4200
const  jump_speed = -1400

func _physics_process(delta):
	velocity.y += gravity * delta
	if is_on_floor():
		if not get_parent().game_running:
			$AnimatedSprite2D.play("idle")
		else:
			if Input.is_action_just_pressed("jump"):
				velocity.y = jump_speed 
				$AnimatedSprite2D.play("jump")
			else:
				$AnimatedSprite2D.play("run")

	move_and_slide()
