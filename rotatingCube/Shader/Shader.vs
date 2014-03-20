#version 410 core

layout(location = 0) in vec4 vPosition;
//layout(location = 1) in double cosine;
//layout(location = 2) in double sine;

void
main()
{
    //mat4x4 rotationMatrix = mat4(cosine,    -sine,  0,  0,
    //                             sine,      cosine, 0,  0,
    //                             0,         0,      1,  0,
    //                             0,         0,      0,  1);
    gl_Position = vPosition;
}