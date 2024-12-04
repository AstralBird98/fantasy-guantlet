extends CPUParticles2D


func _on_enemy_e_attack_anim():
	$".".emitting = true

func _on_enemy_e_star_beam_anim():
	$"../E_Star_Beam_Effect".emitting = true

func _on_enemy_e_black_hole_anim():
	$"../E_Black_Hole_Effect".emitting = true

func _on_enemy_e_shred_anim():
	$"../E_Shred_Effect".emitting = true

func _on_enemy_e_burst_anim():
	$"../E_Burst_Effect".emitting = true
