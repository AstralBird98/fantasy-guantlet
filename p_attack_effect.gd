extends CPUParticles2D


func _on_player_p_attack_anim():
	$".".emitting = true

func _on_player_p_star_beam_anim():
	$"../P_Star_Beam_Effect".emitting = true

func _on_player_p_enhance_star_beam_anim():
	$"../P_Enhance_Star_Beam_Effect".emitting = true

func _on_player_p_black_hole_anim():
	$"../P_Black_Hole_Effect".emitting = true

func _on_player_p_enhance_black_hole_anim():
	$"../P_Enhance_Black_Hole_Effect".emitting = true

func _on_player_p_shred_anim():
	$"../P_Shred_Effect".emitting = true

func _on_player_p_enhance_shred_anim():
	$"../P_Enhance_Shred_Effect".emitting = true

func _on_player_p_burst_anim():
	$"../P_Burst_Effect".emitting = true

func _on_player_p_enhance_burst_anim():
	$"../P_Enhance_Burst_Effect".emitting = true

func _on_player_ult_anim():
	$"../P_Ult_Effect".emitting = true
