extends ItemList

func update_disguises(number):
	clear()
	for disguises in range(number):
		add_icon_item(load(Global.box_sprite), true)

func _on_DisguiseDisplay_item_selected(index):
	unselect_all()
	get_tree().call_group("Player", "use_box")
