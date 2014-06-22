#version 410 core

layout(location = 0) in vec4 vPosition;
layout(location = 1) in vec4 colorsIn;
layout(location = 2) in mat4x4 modelViewPerspective;
layout(location = 6) in vec2 texture_coordinate;

out vec4 colorsOut;
out vec2 tex_coordinate_out;


void main(void)
{
    colorsOut = colorsIn;
    tex_coordinate_out = texture_coordinate;
    gl_Position = modelViewPerspective*vPosition;
    
}