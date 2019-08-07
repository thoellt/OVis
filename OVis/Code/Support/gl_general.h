//
//	general.h
//	OVis
//
//	Created by Thomas Höllt on 16/06/13.
//	Copyright (c) 2013 Thomas Höllt. All rights reserved.
//

#ifndef __GL_GENERAL_H__
#define __GL_GENERAL_H__

#define GL_SILENCE_DEPRECATION

#import <OpenGL/OpenGL.h>
#import <OpenGL/gl3.h>

#include "general.h"

#include "gl_error.h"

typedef struct
{
	GLfloat r,g,b,a;
} Color;

typedef struct
{
	Vector4 position;
	Color color;
} Vertex;

#endif // __GL_GENERAL_H__
