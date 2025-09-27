shader_type canvas_item;

uniform float border_width : hint_range(0.0, 0.5) = 0.05;
uniform vec4 border_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec2 uv = UV;
    
    // Calculate distance from edges
    float left = uv.x;
    float right = 1.0 - uv.x;
    float top = uv.y;
    float bottom = 1.0 - uv.y;
    
    // Find the minimum distance to any edge
    float edge_distance = min(min(left, right), min(top, bottom));
    
    // Determine if we're in the border region
    if (edge_distance < border_width) {
        COLOR = border_color;
    } else {
        // Use the ColorRect's modulate color for the fill
        COLOR = COLOR;
    }
}