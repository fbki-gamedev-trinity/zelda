extends Camera2D

@export var tilemap: TileMapLayer 

func _ready() -> void:
	if tilemap:
		var map_rect = tilemap.get_used_rect()  # Получаем границы используемых ячеек
		var cell_size = tilemap.rendering_quadrant_size    # Размер одной плитки в пикселях
		print(cell_size)
		var world_size_in_pixels = map_rect.size * cell_size
		
		# Устанавливаем лимиты камеры
		limit_left = map_rect.position.x * cell_size
		limit_top = map_rect.position.y * cell_size
		limit_right = limit_left + world_size_in_pixels.x
		limit_bottom = limit_top + world_size_in_pixels.y
		
		print("Camera limits set:")
		print("Left:", limit_left, "Top:", limit_top, "Right:", limit_right, "Bottom:", limit_bottom)
	else:
		push_error("TileMapLayer not assigned to Camera2D!")
