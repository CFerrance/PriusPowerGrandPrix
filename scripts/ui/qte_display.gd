class_name QTE_Display extends Control

@export var prompts: Array[InputIconTextureRect] = []


func display_qte_sequence(qtes: Array[StringName]) -> void:
	assert(!qtes.is_empty())
	
	if len(prompts) < len(qtes):
		for i: int in range(len(prompts), len(qtes)):
			var new_prompt: InputIconTextureRect = InputIconTextureRect.new()
			prompts.append(new_prompt)
			add_child(new_prompt)
	
	for i: int in range(len(prompts)):
		if i < len(qtes):
			prompts[i].set_action_property_value(qtes[i])
		else:
			prompts[i].hide()
	
	show()


func clear_sequence() -> void:
	hide()
