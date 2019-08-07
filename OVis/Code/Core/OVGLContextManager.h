/*!	@header		OVGLContextManager.h
	@discussion	Manager object for OpenGL (and OpenCL) contexts.
	@author		Thomas Höllt
	@updated	2013-08-01 */

// System Headers
#import <Foundation/Foundation.h>

// Custom Headers
#import "general.h"

/*!	@class		OVGLContextManager
	@discussion	Manager object for OpenGL (and OpenCL) contexts.*/
@interface OVGLContextManager : NSObject{
	
	NSOpenGLPixelFormat *_glPixelFormat;
	
	NSOpenGLContext *_glContextDummy;
	
	NSOpenGLContext *_glContext2D;
	NSOpenGLContext *_glContext3D;
	NSOpenGLContext *_glContextTimeSeries;
}

/*!	@property	glPixelFormat
	@brief		Global pixel format used for all OpenGL Contexts.*/
@property (nonatomic) NSOpenGLPixelFormat *glPixelFormat;

/*!	@property	glContextDummy
	@brief		OpenGL context for sharing.*/
@property (nonatomic) NSOpenGLContext *glContextDummy;

/*!	@property	glContext2D
    @brief		OpenGL context for the 2D view (used for offscreen rendering).*/
@property (nonatomic) NSOpenGLContext *glContext2D;

/*!	@property	glContext3D
    @brief		OpenGL context for the 3D view.*/
@property (nonatomic) NSOpenGLContext *glContext3D;

/*!	@property	glContextTimeSeries
	@brief		OpenGL context for the Time Series view.*/
@property (nonatomic) NSOpenGLContext *glContextTimeSeries;

/*!	@method		getGLContextForView
	@discussion	Gets the OpenGL context for the given view. If the context is nil
				it is created sharing _glContextDummys resources.
	@param	viewId	The OVViewId of the view whose context is requested.
	@result		Returns the NSOpenGLContex for the given view.*/
- (NSOpenGLContext*) getGLContextForView: (OVViewId) viewId;

@end
