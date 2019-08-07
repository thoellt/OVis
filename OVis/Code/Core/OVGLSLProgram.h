/*!	@header		OVGLSLProgram.h
	@discussion	Wrapper class for GLSL Shaders, handles creation, compilation
				linking and binding shaders as well as setting of parameters.
	@author		Thomas Höllt
	@updated	2013-07-31 */

// System Headers
#import <Foundation/Foundation.h>

/*!	@class		OVGLSLProgram
	@discussion	Wrapper class for GLSL Shaders, handles creation, compilation
				linking and binding shaders as well as setting of parameters.*/
@interface OVGLSLProgram : NSObject {
	
	BOOL _isCreated;
	BOOL _isCompiledAndLinked;
	
	NSString *_programName;
	
	GLuint _vertexShader;
    GLuint _geometryShader;
	GLuint _fragmentShader;
	GLuint _program;
}

/*!	@property	isCreated
	@brief		BOOL flag indicating whether the shader program is created succesfully.*/
@property (nonatomic) BOOL isCreated;

/*!	@property	isCompiledAndLinked
	@brief		BOOL flag indicating whether the shader program is comiled and linked.*/
@property (nonatomic) BOOL isCompiledAndLinked;

/*!	@method		initFromVertexFile
    @discussion	Initializes the OVGLSLProgram object from shader files.
    @param	vertexFileName		NSString containing the URL for the vertex shader file.
    @param	fragmentFileName	NSString containing the URL for the fragment shader file.
    @param	geometryFileName	NSString containing the URL for the geometry shader file.
    @param	programName			NSString containing the name for the shader program.*/
- (id) initFromVertexFile:(NSString*) vertexFileName geometryFile:(NSString*) geometryFileName fragmentFile:(NSString*) fragmentFileName withName:(NSString*) programName;

/*!	@method		createFromVertexFile
    @discussion	Creates the actual program data from shader files.
    @param	vertexFileName		NSString containing the URL for the vertex shader file.
    @param	fragmentFileName	NSString containing the URL for the fragment shader file.
    @param	geometryFileName	NSString containing the URL for the geometry shader file.
    @param	programName			NSString containing the name for the shader program.
    @result		BOOL set to YES if the creation was succesful.*/
- (BOOL) createFromVertexFile:(NSString*) vertexFileName geometryFile:(NSString*) geometryFileName fragmentFile:(NSString*) fragmentFileName withName:(NSString*) programName;

/*!	@method		compileAndLink
	@discussion	Compiles and links the actual glsl shader program.*/
- (void) compileAndLink;

/*!	@method		bindAndEnable
	@discussion	Binds the glsl shader program and enables it. Every draw call after
				this and before disabling is carried out using the shader program.*/
- (void) bindAndEnable;

/*!	@method		disable
	@discussion	Disables the glsl shader program.*/
- (void) disable;

/*!	@method		validate
	@discussion	Validates the glsl shader program. Throws a GL error if the program
				is not valid.*/
- (void) validate;

/*!	@method		releaseProgram
	@discussion	Frees GL resources of the OVGLSLProgram opject.*/
- (void) releaseProgram;

/*!	@method		getUniformLocation
	@discussion	Gets the GL location of a uniform in this GLSL program.
	@param	name	GLchar array containing the name of the parameter as used in the
				shader program.
	@result		GLint containing the GL location of the uniform.*/
- (GLint) getUniformLocation:(const GLchar *) name;

/*!	@method		getAttributeLocation
	@discussion	Gets the GL location of an attribute in this GLSL program.
	@param	name	GLchar array containing the name of the attribute as used in the
				shader program.
	@result		GLint containing the GL location of the attribute.*/
- (GLint) getAttributeLocation:(const GLchar *) name;

/*!	@method		getSamplerLocation
	@discussion	Gets the GL location of an sampler in this GLSL program.
	@param	name	GLchar array containing the name of the sampler as used in the
				shader program.
	@result		GLint containing the GL location of the sampler.*/
- (GLint) getSamplerLocation:(const GLchar *) name;

/*!	@method			setParameter1i
	@discussion		Sets a single integer parameter for the shader program.
	@param	location	GLint containing the location of the parameter as queried
					by getUniformLocation.
	@param	x		Integer value for the parameter.*/
- (void) setParameter1i:(GLint) location X:(int) x;

/*!	@method			setParameter2i
	@discussion		Sets an ivec2 parameter for the shader program.
	@param	location	GLint containing the location of the parameter as queried
					by getUniformLocation.
	@param	x		Integer value for the first value of the parameter vector.
	@param	y		Integer value for the second value of the parameter vector.*/
- (void) setParameter2i:(GLint) location X:(int) x Y:(int) y;

/*!	@method			setParameter3i
	@discussion		Sets an ivec3 parameter for the shader program.
	@param	location	GLint containing the location of the parameter as queried
					by getUniformLocation.
	@param	x		Integer value for the first value of the parameter vector.
	@param	y		Integer value for the second value of the parameter vector.
	@param	z		Integer value for the third value of the parameter vector.*/
- (void) setParameter3i:(GLint) location X:(int) x Y:(int) y Z:(int) z;

/*!	@method			setParameter4i
	@discussion		Sets an ivec4 parameter for the shader program.
	@param	location	GLint containing the location of the parameter as queried
					by getUniformLocation.
	@param	x		Integer value for the first value of the parameter vector.
	@param	y		Integer value for the second value of the parameter vector.
	@param	z		Integer value for the third value of the parameter vector.
	@param	w		Integer value for the fourth value of the parameter vector.*/
- (void) setParameter4i:(GLint) location X:(int) x Y:(int) y Z:(int) z W:(int) w;

/*!	@method			setParameter2iv
	@discussion		Sets an ivec2 parameter for the shader program
	@param	location	GLint containing the location of the parameter as queried
					by getUniformLocation.
	@param	v		Pointer to an array containing two integer values for the vector.*/
- (void) setParameter2iv:(GLint) location V:(const int *) v;

/*!	@method			setParameter3iv
	@discussion		Sets an ivec3 parameter for the shader program
	@param	location	GLint containing the location of the parameter as queried
					by getUniformLocation.
	@param	v		Pointer to an array containing three integer values for the vector.*/
- (void) setParameter3iv:(GLint) location V:(const int *) v;

/*!	@method			setParameter4iv
	@discussion		Sets an ivec4 parameter for the shader program
	@param	location	GLint containing the location of the parameter as queried
					by getUniformLocation.
	@param	v		Pointer to an array containing four integer values for the vector.*/
- (void) setParameter4iv:(GLint) location V:(const int *) v;

/*!	@method			setParameter1f
	@discussion		Sets an single float parameter for the shader program.
	@param	location	GLint containing the location of the parameter as queried
					by getUniformLocation.
	@param	x		Float value for the value of the parameter.*/
- (void) setParameter1f:(GLint) location X:(float) x;

/*!	@method			setParameter2f
	@discussion		Sets an vec2 parameter for the shader program.
	@param	location	GLint containing the location of the parameter as queried
					by getUniformLocation.
	@param	x		Float value for the first value of the parameter vector.
	@param	y		Float value for the second value of the parameter vector.*/
- (void) setParameter2f:(GLint) location X:(float) x Y:(float) y;

/*!	@method			setParameter3f
	@discussion		Sets an vec3 parameter for the shader program.
	@param	location	GLint containing the location of the parameter as queried
					by getUniformLocation.
	@param	x		Float value for the first value of the parameter vector.
	@param	y		Float value for the second value of the parameter vector.
	@param	z		Float value for the third value of the parameter vector.*/
- (void) setParameter3f:(GLint) location X:(float) x Y:(float) y Z:(float) z;

/*!	@method			setParameter4f
	@discussion		Sets an vec4 parameter for the shader program.
	@param	location	GLint containing the location of the parameter as queried
					by getUniformLocation.
	@param	x		Float value for the first value of the parameter vector.
	@param	y		Float value for the second value of the parameter vector.
	@param	z		Float value for the third value of the parameter vector.
	@param	w		Float value for the fourth value of the parameter vector.*/
- (void) setParameter4f:(GLint) location X:(float) x Y:(float) y Z:(float) z W:(float) w;

/*!	@method			setParameter2fv
	@discussion		Sets an vec2 parameter for the shader program
	@param	location	GLint containing the location of the parameter as queried
					by getUniformLocation.
	@param	v		Pointer to an array containing two float values for the vector.*/
- (void) setParameter2fv:(GLint) location V:(const float *) v;

/*!	@method			setParameter3fv
	@discussion		Sets an vec3 parameter for the shader program
	@param	location	GLint containing the location of the parameter as queried
					by getUniformLocation.
	@param	v		Pointer to an array containing three float values for the vector.*/
- (void) setParameter3fv:(GLint) location V:(const float *) v;

/*!	@method			setParameter4fv
	@discussion		Sets an vec4 parameter for the shader program
	@param	location	GLint containing the location of the parameter as queried
					by getUniformLocation.
	@param	v		Pointer to an array containing four float values for the vector.*/
- (void) setParameter4fv:(GLint) location V:(const float *) v;

/*!	@method			setParameter4x4fv
	@discussion		Sets an mat4 parameter for the shader program
	@param	location	GLint containing the location of the parameter as queried
					by getUniformLocation.
	@param	m		Pointer to an array containing four by four float values for the matrix.*/
- (void) setParameter4x4fv:(GLint) location M:(const float *) m;

@end
