extends Node

const PLAYER_SCENE = preload("res://scenes/player.tscn")
@onready var player_spawn_place_marker: Marker2D = $PlayerSpawnPlace


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TransitionChangeManager.transition_done.connect(on_transition_done)
	var player = PLAYER_SCENE.instantiate() 
	self.add_child(player)	
	
	if TransitionChangeManager.is_transitioning:
		player.set_physics_process(false)
		player.set_process_input(false)
	player.position = player_spawn_place_marker.position
	


func on_transition_done():
	$Player.set_physics_process(true)
	$Player.set_process_input(true)


func _on_exit_area_body_entered(body: Node2D) -> void:
	TransitionChangeManager.change_scene("res://scenes/main.tscn")
	
