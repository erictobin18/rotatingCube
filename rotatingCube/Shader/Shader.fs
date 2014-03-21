#version 410 core

layout(location = 3) in vec4 colorsOut;
out vec4 fColor;

void
main()
{
    fColor = colorsOut;
}