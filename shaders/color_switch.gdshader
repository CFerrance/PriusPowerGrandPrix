shader_type canvas_item;

uniform sampler2D original_palette;
uniform sampler2D replacement_palette;
uniform int num_colors;

void fragment() {
	// Called for every pixel the material is visible on.
	
	//get current pixel color
	vec4 tex_color = texture(TEXTURE, UV);
	
	for (int i = 0; i < num_colors; i++){
		float u = ((float(i) + 0.5) / float(num_colors));
		float v = 0.5;
		vec2 uv = vec2(u, v);
		
		vec4 current_color = texture(original_palette, uv);
		float color_dist = distance(tex_color, current_color);
		
		if (color_dist <= 0.001) {
			COLOR = texture(replacement_palette, uv);
			break;
		}
	} 
}
