extends CharacterBody2D

class_name Player

@onready var animated_sprite_2d: AnimationController = $AnimatedSprite2D
@onready var inventory: Inventory = $inventory
@onready var health_system: HealthSystem = $HealthSystem
@onready var on_screen_ui: OnScreenUI = $onScreenUI
@onready var combat_system: CombatSystem = $CombatSystem
@onready var camera: Camera2D = $Camera2D  # Ссылка на камеру игрока

@export var health = 100

func _ready() -> void:
	health_system.init(health)
	health_system.died.connect(on_player_dead)
	health_system.damage_taken.connect(on_damage_taken)
	on_screen_ui.init_health_bar(health)

	# Подключаем сигнал смены сцены
	var world_manager = get_tree().get_current_scene()
	if world_manager and world_manager.has_signal("scene_changed"):
		world_manager.connect("scene_changed", Callable(self, "_on_scene_changed"))

const SPEED = 3000.0

func _physics_process(delta: float) -> void:
	if animated_sprite_2d.animation.contains("attack"):
		return

	var direction = Input.get_vector("left", "right", "up", "down")

	# Запрещаем движение по диагонали
	if direction.x != 0 and direction.y != 0:
		direction.y = 0  # Отдаем приоритет горизонтальному движению

	if direction:
		velocity = direction * SPEED * delta
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		velocity.y = move_toward(velocity.y, 0, SPEED * delta)

	if velocity != Vector2.ZERO:
		animated_sprite_2d.play_movement_animation(velocity)
	else:
		animated_sprite_2d.play_idle_animation()

	move_and_slide()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is PickUpItem:
		inventory.add_item(area.inventry_item, area.stacks)
		area.queue_free()

	if area.get_parent() is Enemy:
		var damage_to_player = (area.get_parent() as Enemy).damage_to_player
		health_system.apply_damage(damage_to_player)

func on_damage_taken(damage: int) -> void:
	on_screen_ui.apply_damage_to_health_bar(damage)

func on_player_dead():
	set_physics_process(false)
	combat_system.set_process_input(false)
	animated_sprite_2d.play("dead")

# Изменение лимитов камеры в зависимости от сцены
func _on_scene_changed(scene_name: String) -> void:
	match scene_name:
		"res://scenes/main.tscn":
			camera.limit_left = 0
			camera.limit_top = 0
			camera.limit_right = 1024
			camera.limit_down = 768
		"res://scenes/house_scene.tscn":
			camera.limit_left = -500
			camera.limit_top = -300
			camera.limit_right = 1500
			camera.limit_down = 1200
		_:
			camera.limit_left = 0
			camera.limit_top = 0
			camera.limit_right = 1920
			camera.limit_down = 1080



#extends CharacterBody2D
#
#class_name Player
#
#@onready var animated_sprite_2d: AnimationController = $AnimatedSprite2D
#@onready var inventory: Inventory = $inventory
#@onready var health_system: HealthSystem = $HealthSystem
#@onready var on_screen_ui: OnScreenUI = $onScreenUI
#@onready var combat_system: CombatSystem = $CombatSystem
#
#@onready var camera: Camera2D = $Camera2D
#
#@export var health = 100
#
#func _ready() -> void:
	#health_system.init(health)
	#health_system.died.connect(on_player_dead)
	#health_system.damage_taken.connect(on_damage_taken)
	#on_screen_ui.init_health_bar(health)
#
#const SPEED = 3000.0
#
#func _physics_process(delta: float) -> void:
	#if animated_sprite_2d.animation.contains("attack"):
		#return
#
	#var direction = Input.get_vector("left", "right", "up", "down")
#
	## Запрещаем движение по диагонали
	#if direction.x != 0 and direction.y != 0:
		#direction.y = 0  # Отдаем приоритет горизонтальному движению
#
	#if direction:
		#velocity = direction * SPEED * delta
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		#velocity.y = move_toward(velocity.y, 0, SPEED * delta)
#
	#if velocity != Vector2.ZERO:
		#animated_sprite_2d.play_movement_animation(velocity)
	#else:
		#animated_sprite_2d.play_idle_animation()
#
	#move_and_slide()
#
#func _on_area_2d_area_entered(area: Area2D) -> void:
	#if area is PickUpItem:
		#inventory.add_item(area.inventry_item, area.stacks)
		#area.queue_free()
#
	#if area.get_parent() is Enemy:
		#var damage_to_player = (area.get_parent() as Enemy).damage_to_player
		#health_system.apply_damage(damage_to_player)
#
#func on_damage_taken(damage: int) -> void:
	#on_screen_ui.apply_damage_to_health_bar(damage)
#
#func on_player_dead():
	#set_physics_process(false)
	#combat_system.set_process_input(false)
	#animated_sprite_2d.play("dead")
