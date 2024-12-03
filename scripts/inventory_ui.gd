extends CanvasLayer

class_name InventoryUI

signal equip_item(idx: int, slot_to_equip)

@onready var grid_container: GridContainer = %GridContainer
const INVENTORY_SLOT_SCENE = preload("res://scenes/inventory_slot.tscn")

@export var size = 8
@export var columns = 4

func _ready() -> void:
	grid_container.columns = columns
	for i in size:
		var inventory_slot = INVENTORY_SLOT_SCENE.instantiate()
		grid_container.add_child(inventory_slot)
		
		inventory_slot.equip_item.connect(func(slot_to_equip: String): equip_item.emit(i, slot_to_equip))

func toggle():
	visible = !visible
	
func add_item(item: InventoryItem):
	var slots = grid_container.get_children().filter(func (slot): return slot.is_empty)
	var first_empty_slot = slots.front() as InventorySlot
	first_empty_slot.add_item(item)
	
func update_stack_at_slot_index(stacks_value: int, inventory_slot_index: int):
	if inventory_slot_index == -1:
		return
	var inventory_slot: InventorySlot = grid_container.get_child(inventory_slot_index)
	inventory_slot.stacks_label.text = str(stacks_value)
	
