//
//	OVGLSLProgram.mm
//

// Custom Headers
#import "general.h"
#import "gl_general.h"

// Local Header
#import "OVGLSLProgram.h"

#define kFailedToInitialiseGLException @"Failed to initialise OpenGL"

@implementation OVGLSLProgram

@synthesize isCreated = _isCreated;
@synthesize isCompiledAndLinked = _isCompiledAndLinked;

- (id) init
{
	return [self initFromVertexFile:nil geometryFile:nil fragmentFile:nil withName:nil];
}


- (id) initFromVertexFile:(NSString*) vertexFileName geometryFile:(NSString*) geometryFileName fragmentFile:(NSString*) fragmentFileName withName:(NSString*) programName
{
	self = [super init];
	
	if( self ){
		
		_isCreated = NO;
		_isCompiledAndLinked = NO;
		
		_vertexShader = 0;
        _geometryShader = 0;
		_fragmentShader = 0;
		
		_program = 0;
		
		_programName = nil;
		
		if( vertexFileName && fragmentFileName && programName ){
	
			BOOL success = [self createFromVertexFile:vertexFileName geometryFile: geometryFileName fragmentFile:fragmentFileName withName:programName];
	
			if( !success ){
		
				NSLog(@"Failed loading shader %@", programName);
				return nil;
			}
		}
	}
	
	return self;
}

- (BOOL) createFromVertexFile:(NSString*) vertexFileName geometryFile:(NSString*) geometryFileName fragmentFile:(NSString*) fragmentFileName withName:(NSString*) programName
{
	// early out if already loaded
	if( _isCreated ) return NO;
	
	_programName = programName;
	
	const GLchar *vertexSource = (GLchar *)[[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:vertexFileName ofType:@"vsh"]
																encoding:NSASCIIStringEncoding error:nil] cStringUsingEncoding:NSASCIIStringEncoding];
	
	if( !vertexSource ) return NO;
	
	_vertexShader = glCreateShader( GL_VERTEX_SHADER );
	GetGLError();
	
	glShaderSource(_vertexShader, 1, &vertexSource, nil);
	GetGLError();
    
    if( geometryFileName )
    {
        const GLchar *geometrySource = (GLchar *)[[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:geometryFileName ofType:@"gsh"]
                                                                            encoding:NSASCIIStringEncoding error:nil] cStringUsingEncoding:NSASCIIStringEncoding];
        
        if( !geometrySource ) return NO;
        
        _geometryShader = glCreateShader( GL_GEOMETRY_SHADER );
        GetGLError();
        
        glShaderSource(_geometryShader, 1, &geometrySource, nil);
        GetGLError();
    }
	
	const GLchar *fragmentSource = (GLchar *)[[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fragmentFileName ofType:@"fsh"]
																		encoding:NSASCIIStringEncoding error:nil] cStringUsingEncoding:NSASCIIStringEncoding];
	
	if( !fragmentSource ) return NO;
	
	_fragmentShader = glCreateShader( GL_FRAGMENT_SHADER );
	GetGLError();
	
	glShaderSource(_fragmentShader, 1, &fragmentSource, nil);
	GetGLError();	
	
	_program = glCreateProgram();
	GetGLError();
	
	glAttachShader(_program, _vertexShader);
	GetGLError();
    
    if( _geometryShader )
    {
        glAttachShader(_program, _geometryShader);
        GetGLError();
    }
	
	glAttachShader(_program, _fragmentShader);
	GetGLError();
	
	_isCreated = YES;

	return YES;
}

- (void) compileAndLink
{
	assert(_isCreated);
	
	// early out if program is already compiled and linked
	if(_isCompiledAndLinked) return;
	
	glCompileShader(_vertexShader);
	GetGLError();
	
	GLint status = GL_FALSE;
	glGetShaderiv(_vertexShader, GL_COMPILE_STATUS, &status);
	GetGLError();
	if( status != GL_TRUE )
	{
		glDeleteShader(_vertexShader);
		GetGLError();
		[NSException raise:kFailedToInitialiseGLException format:@"Vertex shader compilation failed for %@", _programName];
	}
	
    if( _geometryShader )
    {
        glCompileShader(_geometryShader);
        GetGLError();
        
        status = GL_FALSE;
        glGetShaderiv(_geometryShader, GL_COMPILE_STATUS, &status);
        GetGLError();
        if( status != GL_TRUE )
        {
            glDeleteShader(_geometryShader);
            GetGLError();
            [NSException raise:kFailedToInitialiseGLException format:@"Geometry shader compilation failed for %@", _programName];
        }
    }
	
	glCompileShader(_fragmentShader);
	GetGLError();
	
	status = GL_FALSE;
	glGetShaderiv(_fragmentShader, GL_COMPILE_STATUS, &status);
	GetGLError();
	if( status != GL_TRUE )
	{
		glDeleteShader(_fragmentShader);
		GetGLError();
		[NSException raise:kFailedToInitialiseGLException format:@"Fragment shader compilation failed for %@", _programName];
	}
	
	glLinkProgram(_program);
	GetGLError();
	
	status = GL_FALSE;
	glGetProgramiv(_program, GL_LINK_STATUS, &status);
	GetGLError();
	if( status != GL_TRUE )
	{
		[NSException raise:kFailedToInitialiseGLException format:@"Failed to link shader program"];
	}
		
	_isCompiledAndLinked = YES;
}

- (void) bindAndEnable
{
	assert(_isCompiledAndLinked);
	
	glUseProgram(_program);
	GetGLError();
}

- (void) disable
{	
	glUseProgram(0);
	GetGLError();
}

- (void) validate
{	
	glValidateProgram(_program);
	GetGLError();
	
	GLint status = GL_FALSE;
	glGetProgramiv(_program, GL_VALIDATE_STATUS, &status);
	GetGLError();
	if ( status != GL_TRUE )
	{
		[NSException raise:kFailedToInitialiseGLException format:@"%@ program is invalid.", _programName];
	}
}

- (void) releaseProgram
{
	_isCreated = NO;
	_isCompiledAndLinked = NO;

	glDeleteProgram(_program);
	
	_vertexShader = 0;
    _geometryShader = 0;
	_fragmentShader = 0;
	_program = 0;
}

- (GLint) getUniformLocation:(const GLchar *) name
{
	assert( name );
	
	GLint param = glGetUniformLocation(_program, name);
	if ( param == -1 ) {
		[NSException raise:kFailedToInitialiseGLException format:@"Could not find uniform %s in program %@.", name, _programName];
	}
	
	return param;
}

- (GLint) getAttributeLocation:(const GLchar *) name
{
	assert( name );
	
	GLint param = glGetAttribLocation(_program, name);
	if ( param == -1 ) {
		[NSException raise:kFailedToInitialiseGLException format:@"Could not find attribute %s in program %@.", name, _programName];
	}
	
	return param;
}

- (GLint) getSamplerLocation:(const GLchar *) name
{
	assert( name );
	
	GLint param = glGetUniformLocation(_program, name);
	if ( param == -1 ) {
		[NSException raise:kFailedToInitialiseGLException format:@"Could not find sampler %s in program %@.", name, _programName];
	}
	
	return param;
}

- (void) setParameter1i:(GLint) location X:(int) x
{
	// this can happen when a uniform name was not found
	// and thus could not be mapped to a parameter id
	if ( location == -1 )
		return;
	
	glUniform1i(location, x);
	GetGLError();
}

- (void) setParameter2i:(GLint) location X:(int) x Y:(int) y
{
	// this can happen when a uniform name was not found
	// and thus could not be mapped to a parameter id
	if ( location == -1 )
		return;
	
	glUniform2i(location, x, y);
	GetGLError();
}

- (void) setParameter3i:(GLint) location X:(int) x Y:(int) y Z:(int) z
{
	// this can happen when a uniform name was not found
	// and thus could not be mapped to a parameter id
	if ( location == -1 )
		return;
	
	glUniform3i(location, x, y, z);
	GetGLError();
}

- (void) setParameter4i:(GLint) location X:(int) x Y:(int)y Z:(int)z W:(int)w
{
	// this can happen when a uniform name was not found
	// and thus could not be mapped to a parameter id
	if ( location == -1 )
		return;
	
	glUniform4i(location, x, y, z, w);
	GetGLError();
}


- (void) setParameter2iv:(GLint) location V:(const int *) v
{
	// this can happen when a uniform name was not found
	// and thus could not be mapped to a parameter id
	if ( location == -1 )
		return;
	
	glUniform2iv(location, 1, v);
	GetGLError();
}

- (void) setParameter3iv:(GLint) location V:(const int *) v
{
	// this can happen when a uniform name was not found
	// and thus could not be mapped to a parameter id
	if ( location == -1 )
		return;
	
	glUniform3iv(location, 1, v);
	GetGLError();
}

- (void) setParameter4iv:(GLint) location V:(const int *) v
{
	// this can happen when a uniform name was not found
	// and thus could not be mapped to a parameter id
	if ( location == -1 )
		return;
	
	glUniform4iv(location, 1, v);
	GetGLError();
}


- (void) setParameter1f:(GLint) location X:(float) x
{
	// this can happen when a uniform name was not found
	// and thus could not be mapped to a parameter id
	if ( location == -1 )
		return;
	
	glUniform1f(location, x);
	GetGLError();
}

- (void) setParameter2f:(GLint) location X:(float) x Y:(float) y
{
	// this can happen when a uniform name was not found
	// and thus could not be mapped to a parameter id
	if ( location == -1 )
		return;
	
	glUniform2f(location, x, y);
	GetGLError();
}

- (void) setParameter3f:(GLint) location X:(float) x Y:(float) y Z:(float) z
{
	// this can happen when a uniform name was not found
	// and thus could not be mapped to a parameter id
	if ( location == -1 )
		return;
	
	glUniform3f(location, x, y, z);
	GetGLError();
}

- (void) setParameter4f:(GLint) location X:(float) x Y:(float) y Z:(float) z W:(float) w
{
	// this can happen when a uniform name was not found
	// and thus could not be mapped to a parameter id
	if ( location == -1 )
		return;
	
	glUniform4f(location, x, y, z, w);
	GetGLError();
}


- (void) setParameter2fv:(GLint) location V:(const float *) v
{
	// this can happen when a uniform name was not found
	// and thus could not be mapped to a parameter id
	if ( location == -1 )
		return;
	
	glUniform2fv(location, 1, v);
	GetGLError();
}

- (void) setParameter3fv:(GLint) location V:(const float *) v
{
	// this can happen when a uniform name was not found
	// and thus could not be mapped to a parameter id
	if ( location == -1 )
		return;
	
	glUniform3fv(location, 1, v);
	GetGLError();
}

- (void) setParameter4fv:(GLint) location V:(const float *) v
{
	// this can happen when a uniform name was not found
	// and thus could not be mapped to a parameter id
	if ( location == -1 )
		return;
	
	glUniform4fv(location, 1, v);
	GetGLError();
}

- (void) setParameter4x4fv:(GLint) location M:(const float *) m
{
	// this can happen when a uniform name was not found
	// and thus could not be mapped to a parameter id
	if ( location == -1 )
		return;
	
	glUniformMatrix4fv(location, 1, GL_FALSE, m);
	GetGLError();
}


- (void) dealloc
{
	[self releaseProgram];
}

@end
