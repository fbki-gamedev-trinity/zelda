extends Node

class_name InventoryManager

var items: Array = []

func add_item(item, amount: int) -> void:
	for entry in items:
		if entry["item"] == item:
			entry["amount"] += amount
			return
	items.append({"item": item, "amount": amount})


func get_inventory() -> Array:
	return items
