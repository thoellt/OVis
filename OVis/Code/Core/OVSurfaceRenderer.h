/*!	@header		OVSurfaceRenderer.h
	@discussion	Base class for structured and unstructured surface renderers.
	@author		Thomas Höllt
	@updated	2013-08-01 */

// System Headers
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <OpenCL/OpenCL.h>

// Custom Headers
#import "OVAppDelegateProtocol.h"

#define RADIANS_PER_PIXEL (M_PI / 320.f)

// Friend Classes
@class OVViewSettings;
@class OVGLSLProgram;

/*!	@class		 OVSurfaceRenderer
	@discussion	Base class for structured and unstructured surface renderers.*/
@interface OVSurfaceRenderer : NSObject {
	
	id<OVAppDelegateProtocol> _appDelegate;
    
    OVViewId _viewId;
	
	int _viewWidth;
	int _viewHeight;
	
	float _viewAspect;
	
	OVViewSettings *_viewSettings;
	
	BOOL _shadersLoaded;
	
	GLuint _vertexArrayObject;
	GLuint _vertexBuffer;
	GLuint _indexBuffer;
	size_t _indexBufferSize;
	
	//GLuint _pathlineVertexBuffer;
	//GLuint _pathlineColorBuffer;
    
    GLuint _legendVertexBuffer;
    GLuint _legendColorBuffer;
    
	OVGLSLProgram *_glslProgramBasicGL;
	OVGLSLProgram *_glslProgramBasicGLColorBuffer;
	
	//cl_mem _vertexBufferCL;
	
	GLuint _surfaceTexture;
	GLuint _statisticTexture[2];
	GLuint _colormapTexture[2];
	
	GLKMatrix4 _mvp;
    
    // Offscreen rendering
    BOOL _offScreenNeedsRefresh;
    
    GLuint _renderBuffer;
    GLuint _depthBuffer;
    GLuint _FBO;
    
    int _bufferWidth;
    int _bufferHeight;
    
    unsigned char* _cpuBuffer;
	
	BOOL _includeLIC;
	
	// Interaction
	CGPoint _initialLocation;
	
	GLKQuaternion _quaternion;
	GLKQuaternion _initQuaternion;
	
	GLKVector3 _currentLocation;
	GLKVector3 _anchorLocation;
	
	GLKMatrix4 _rotationMatrix;
	
	float _zoomLevel;
	float _translate[2];
	
	// lerping
	BOOL	_slerping;
	float	_slerpCur;
	float	_slerpMax;
	GLKQuaternion _slerpStart;
	GLKQuaternion _slerpEnd;
	
	float _zoomStep;
	float _translateStep[2];
	
	float _lerpSpeed;
}

/*!	@method		initWithViewId
    @discussion	Custom initializer that set the id of the view which user this renderer instance.
                The standard init calls this with ViewId3D.
    @param	viewId	The id of the parent view.*/
- (id) initWithViewId:(OVViewId) viewId;

/*!	@method		rebuild
	@discussion	Rebuilds the renderer from the ground up without the need to
				destroy and recreate a renderer object. Call this after loading
				a new dataset.*/
- (void) rebuild;

/*!	@method		createFBO
    @discussion	Creates a new Framebuffer Object for offscreen OpenGL rendering.*/
- (void) createFBO;

/*!	@method		refreshData
	@discussion	Refreshes the renderer data, like textures. Call this when
				the derived data of the active dataset changes, for example, when
				changing the statistic or parameter range.*/
- (void) refreshData;

/*!	@method		resizeWithWidth
	@discussion	Resizes the renderer, should be called when the view containing
				the renderer is resized.
	@param	width	 The new width in points.
	@param	height	The new height in points.*/
- (void) resizeWithWidth:(GLuint)width height:(GLuint)height;

/*!	@method		setupMatrix
	@discussion	Sets the View Matrix (Model View Projection) according to the
				current settings (zoom, rotation, etc.).*/
- (void) setupMatrix;

/*!	@method		drawWithShaderProgram
	@discussion	Draw with a given shader program. The shader program is setup in
				the subclassed renderer but drawing is always the same for all
				sublasses.
	@param	shaderProgram	OVGLSLProgram object containing the compiled and linked
				shader program.*/
- (void) drawWithShaderProgram: (OVGLSLProgram*) shaderProgram;

/*!	@method		drawLegend
    @discussion	Draw the legend for the colormap.*/
- (void) drawLegend;

/*!	@method		surfacePositionForScreenCoordinateX
    @discussion	Calculates and returns the surface x and y coordinates from a given
                screen position using the result from the offscreen drawing.
    @param	x	The new screen coordinates x component.
    @param	y	The new screen coordinates y component.
    @result     Pointer to two NSIntergers containing the surface (x,y) coordinate.*/
- (iVector2) surfacePositionForScreenCoordinateX:(int) x Y:(int) y;

/*!	@method		initArcBall
	@discussion	Initializes the Arc Ball for interaction with the view.*/
- (void) initArcBall;

/*!	@method		projectOntoSurface
	@discussion	Projects the mouse position onto the ArcBalls surface.
	@param	clickedPosition	GLKVector3 of the mouse position.
	@result		GLKVector3 containing the position on the ArcBall surface.*/
- (GLKVector3) projectOntoSurface:(GLKVector3) clickedPosition;

/*!	@method		initLocation
	@discussion	Initializes the position when starting interaction with the ArcBall.
	@param	location	The mouse position when starting interaction.*/
- (void) initLocation:(CGPoint)location;

/*!	@method		updateLocation
	@discussion	Refreshes the ArcBall from the given new position when moving the mouse.
	@param	newLocation		The new mouse position.*/
- (void) updateLocation:(CGPoint) newLocation;

/*!	@method		resetLocation
	@discussion	Resets the ArcBall and with it the model to its initial state.*/
- (void) resetLocation;

/*!	@method		setZoom
	@discussion	Sets the zoom value for the view.
	@param	zoom	Signed float value giving the delta value for the zoom.*/
- (void) setZoom:(float) zoom;

/*!	@method		translateInX
	@discussion	Translates the model using the given deltas.
	@param	deltaX	Integer value giving the translation in x-direction in view coordinates (screen points).
	@param	deltaY	Integer value giving the translation in y-direction in view coordinates (screen points).*/
- (void) translateInX:(int) deltaX Y:(int) deltaY;

@end
