#version 410 core

uniform sampler2DRect tex;

in vec4 colorsOut;
in vec2 tex_coordinate_out;

layout(location = 0) out vec4 fColor;



void main(void)
{
    colorsOut;
    fColor = texture(tex, tex_coordinate_out);
}