extends Node

class_name Inventory

@onready var inventory_ui: InventoryUI = $"../inventoryUI"
@export var items: Array[InventoryItem] = []

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		inventory_ui.toggle()
		
func add_item(item: InventoryItem, stacks: int):
	if stacks && item.max_stacks > 1:
		add_stackable_item_to_inventory(item, stacks)
	else:
		items.append(item)
		#обновить ui
		
func add_stackable_item_to_inventory(item: InventoryItem, stacks: int):
	var item_index = -1
	for i in items.size():
		if items[i] != null and items[i].name == item.name:
			item_index = i
	
	if item_index != -1:
		var inventory_item = items[item_index]
	
		if inventory_item.stacks + stacks <= item.max_stacks:
			inventory_item.stacks += stacks
			items[item_index] = inventory_item
			#обновить ui
		else:
			var stacks_diff = inventory_item.stacks + stacks - item.max_stacks
			var additional_inventory_item = inventory_item.duplicate(true)
			inventory_item.stacks = item.max_stacks
			#обновить ui
			additional_inventory_item.stacks = stacks_diff
			items.append(additional_inventory_item)
			#обновить ui
	else:
		item.stacks = stacks
		items.append(item)
		#обновить ui
