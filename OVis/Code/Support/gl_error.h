/*
**	error.h
**
**	Copyright (c) 2008 Max Rupp (feelgood@cs.pdx.edu) All rights reserved.
*/

#ifndef __GL_ERROR_H__
#define __GL_ERROR_H__

#ifdef	DEBUG

#include <stdlib.h>
#include <assert.h>

#define GetGLError( )\
		{\
			for ( GLenum Error = glGetError( ); ( GL_NO_ERROR != Error ); Error = glGetError( ) )\
			{\
				switch ( Error )\
				{\
					case GL_INVALID_ENUM:		printf( "\n%s\n\n", "GL_INVALID_ENUM"		); assert( 0 ); break;\
					case GL_INVALID_VALUE:	 printf( "\n%s\n\n", "GL_INVALID_VALUE"	 ); assert( 0 ); break;\
					case GL_INVALID_OPERATION: printf( "\n%s\n\n", "GL_INVALID_OPERATION" ); assert( 0 ); break;\
					case GL_OUT_OF_MEMORY:	 printf( "\n%s\n\n", "GL_OUT_OF_MEMORY"	 ); assert( 0 ); break;\
					default:																				break;\
				}\
			}\
		}

#define CheckFramebufferStatus( )\
		{\
			switch ( glCheckFramebufferStatus( GL_FRAMEBUFFER ) )\
			{\
				case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT:		 printf( "\n%s\n\n", "GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT"		 ); assert( 0 ); break;\
				case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT: printf( "\n%s\n\n", "GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT" ); assert( 0 ); break;\
				case GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER:		printf( "\n%s\n\n", "GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER"		); assert( 0 ); break;\
				case GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER:		printf( "\n%s\n\n", "GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER"		); assert( 0 ); break;\
				case GL_FRAMEBUFFER_UNSUPPORTED:					 printf( "\n%s\n\n", "GL_FRAMEBUFFER_UNSUPPORTED"					 ); assert( 0 ); break;\
				case GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE:		printf( "\n%s\n\n", "GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE"		); assert( 0 ); break;\
				case GL_FRAMEBUFFER_UNDEFINED:					 printf( "\n%s\n\n", "GL_FRAMEBUFFER_UNDEFINED"					 ); assert( 0 ); break;\
				default:																																break;\
			}\
		}

#define GetShaderInfoLog( Shader, Source )\
		{\
			GLint	 Status, Count;\
			GLchar *Error;\
			\
			glGetShaderiv( Shader, GL_COMPILE_STATUS, &Status );\
			\
			if ( !Status )\
			{\
				glGetShaderiv( Shader, GL_INFO_LOG_LENGTH, &Count );\
				\
				if ( Count > 0 )\
				{\
					glGetShaderInfoLog( Shader, Count, NULL, ( Error = calloc( 1, Count ) ) );\
					\
					printf( "%s\n\n%s\n", Source, Error );\
					\
					free( Error );\
					\
					assert( 0 );\
				}\
			}\
		}

#else

#define GetGLError( )

#define CheckFramebufferStatus( )

#define GetShaderInfoLog( Shader, Source )

#define kFailedToInitialiseGLException @"Failed to initialise OpenGL"

#endif /*	 DEBUG	 */
#endif /* __GL_ERROR_H__ */
