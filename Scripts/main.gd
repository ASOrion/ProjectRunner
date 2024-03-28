extends Node2D



var obstacle = preload("res://obstacle.tscn")
var stump = preload("res://stump.tscn")
var rock = preload("res://rock.tscn")
var barrel = preload("res://barrel.tscn")
var obstacle_types := [stump, rock, barrel, obstacle]
var obstacles : Array
var last_obs
var ground_height : int

const dino_start_pos := Vector2i(102, 457)
const cam_start_pos := Vector2i(444, 309)
const start_speed : float = 4.0
const max_speed : int = 25

var score : int
var score_modifier : int = 10
var speed : float
var speed_modifier : int = 50000

var screen_size : Vector2i
var game_running : bool

var difficulty
var max_difficulty = 2

func _ready():
	screen_size = get_window().size
	ground_height = $ground.get_node("Sprite2D").texture.get_height()
	$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()

func new_game():
	score = 0
	show_score()
	difficulty = 0
	game_running = false
	$dino.position = dino_start_pos
	$dino.velocity = Vector2i(0, 0)
	$Camera2D.position = cam_start_pos
	$ground.position = Vector2i(0, 0)
	$GameOver.hide()

func _process(delta):
	if game_running:
		speed = start_speed + score / speed_modifier
		if speed > max_speed:
			speed = max_speed
		adjust_difficulty()
		generate_obs()

		$dino.position.x += speed
		$Camera2D.position.x += speed

		score += speed
		show_score()

		if $Camera2D.position.x - $ground.position.x > screen_size.x * 1.4:
			$ground.position.x += screen_size.x 

		for obs in obstacles:
			if obs.position.x < $Camera2D.position.x - screen_size.x:
				remove_obs(obs)
	else:
		if Input.is_action_just_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("pressstart").hide()
			

	

func show_score():
	$HUD.get_node("score").text = "Score: " + str(score / score_modifier)

func generate_obs():
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + 100 + (i * 100)
			var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 5
			last_obs = obs
			add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y):
	obs.body_entered.connect(hit_obs)
	obs.position = Vector2i(x, y)
	add_child(obs)
	obstacles.append(obs)

func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)

func hit_obs(body):
	if body.name == "dino":
		game_over()

func adjust_difficulty():
	difficulty = score / speed_modifier
	if difficulty > max_difficulty:
		difficulty = max_difficulty

func game_over():
	get_tree().paused
	game_running = false
	$GameOver.show()

