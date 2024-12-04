extends Button




#func _process(_delta):
	#if(bat_1.spell_select && bat_1.isDef):
		#grab_focus()


func _on_battle_1_def_spell_menu():
	grab_focus()
