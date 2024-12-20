extends Node

@export var tilemap: TileMapLayer 

const PLAYER_SCENE = preload("res://scenes/player.tscn")
@onready var player_spawn_place_marker: Marker2D = $PlayerSpawnPlace

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TransitionChangeManager.transition_done.connect(on_transition_done)
	var player = PLAYER_SCENE.instantiate() 
	self.add_child(player)
	player.sync_inventory_with_manager()

	# Добавляем камеру к игроку
	var camera = Camera2D.new()
	camera.name = "Camera2D"
	camera.zoom.x = 3
	camera.zoom.y = 3
	
	if tilemap:
		var map_rect = tilemap.get_used_rect()  # Получаем границы используемых ячеек
		var cell_size = tilemap.rendering_quadrant_size    # Размер одной плитки в пикселях
		print(cell_size)
		var world_size_in_pixels = map_rect.size * cell_size
		
		# Устанавливаем лимиты камеры
		camera.limit_left = map_rect.position.x * cell_size
		camera.limit_top = map_rect.position.y * cell_size
		camera.limit_right = camera.limit_left + world_size_in_pixels.x
		camera.limit_bottom = camera.limit_top + world_size_in_pixels.y
		
		print("Camera limits set:")
	else:
		push_error("TileMapLayer not assigned to Camera2D!")
	
	player.add_child(camera)

	if TransitionChangeManager.is_transitioning:
		player.set_physics_process(false)
		player.set_process_input(false)
	
	player.position = player_spawn_place_marker.position
	for child in self.get_children():
		if child.get("id"):
			if TransitionChangeManager.load_state(child.id) == false:
				child.queue_free()


func on_transition_done():
	$Player.set_physics_process(true)
	$Player.set_process_input(true)

func _on_exit_area_body_entered(body: Node2D) -> void:
	TransitionChangeManager.change_scene("res://scenes/main.tscn")
