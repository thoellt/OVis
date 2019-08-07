/*!	@header		OVViewSettings.h
	@discussion	This class holds global settings for the views and functions as
				the connection between the UI and the core.
	@author		Thomas Höllt
	@updated	2013-07-26 */

// System Headers
#import <Foundation/Foundation.h>

// Custom Headers
#import "general.h"

// Friend Classes
@class OVColormap;
@class OVVariable;

/*!	@class		OVViewSettings
	@discussion	This class holds global settings for the views and functions as
				the connection between the UI and the core.*/
@interface OVViewSettings : NSObject {
	
@private
   
   BOOL _isDark;
	
	// colormaps
	NSMutableArray *_colormaps;
	
	// 3D View
	float*	_threeDViewBackgroundColor;
	BOOL	_renderAsWireframe3D;
	
	OVEnsembleProperty _activeSurface3D;
	NSInteger _activeSurfaceVariable3D;
	OVEnsembleProperty _activeProperty3D;
	NSInteger _activePropertyVariable3D;
	OVEnsembleProperty _activeNoiseProperty3D;
	NSInteger _activeNoisePropertyVariable3D;
	
	int     _activeColormap3D;
   BOOL    _flatColormap3D;
	BOOL	_discreteColormap3D;
    
	BOOL	_showColormapLegend3D;
	
	// 2D View
	OVEnsembleProperty _activeProperty2D;
	NSInteger _activePropertyVariable2D;
	OVEnsembleProperty _activeNoiseProperty2D;
	NSInteger _activeNoisePropertyVariable2D;
    
	int	 _activeColormap2D;
	BOOL	_flatColormap2D;
	BOOL	_discreteColormap2D;
    
	BOOL	_showColormapLegend2D;
	
	// TS View
	float*	_tSViewBackgroundColor;
	
	NSString* _leftGlyphActiveItem;
	NSString* _rightGlyphActiveItem;
	
	OVVariable* _leftGlyphActiveVariable;
	OVVariable* _rightGlyphActiveVariable;
	
	int	 _activeColormapTS;
	BOOL	_discreteColormapTS;
    
    // Histogram View
    iVector2 _histogramPosition;
	
	// Properties
	BOOL	_animateTime;
	BOOL	_animateMember;
    
    // Pathline Vis
    BOOL _isPathlineTracingEnabled;
    BOOL _isPathlineTraceAvailable;
    
    int _activeColormapPathline;
    
    int _pathlineScale;
    int _pathlineAlpha;
}

/*!	@method		setThreeDViewBackgroundColorWithNSColor
	@discussion	Sets the color for the 3D View background using an NSColor object.
				The color is save in a four value float array.
	@param	color	An NSColor object that defines the color for the 3D view background.*/
- (void) setThreeDViewBackgroundColorWithNSColor: (NSColor*) color;

/*!	@method		colormapAtIndex
	@discussion	Returns the colormap at the provided index.
	@param	index	The index of the colormap that shall be returned.
	@result		OVColormap object corresponding to the colormap at the given index.*/
- (OVColormap*) colormapAtIndex: (NSInteger) index;

/*!	@method		numColormaps
    @discussion	Returns the number of available colormaps.
    @result     The number of colormaps.*/
- (NSInteger) numColormaps;

/*!	@method		activeColormapForView
	@discussion	Returns the active colormap for the provided viewId.
				The index for the active colormap is fetched from the
				activeColormapXX member and the corresponding colormap is
				returned using the colormapAtIndex method.
	@param	viewId	The view that requests the active colormap.
	@result		OVColormap object corresponding to the active colormap of the
				given view.*/
- (OVColormap*) activeColormapForView:(OVViewId) viewId;

/*!	@method		activeColormapForView
    @discussion	Returns the active colormap for pathline vis.
    @result		OVColormap object corresponding to the active colormap.*/
- (OVColormap*) activeColormapForPathline;

/*!	@method		activeColormapIndexForView
	@discussion	Returns the index of the active colormap for the provided viewId.
				The index for the active colormap is fetched from the
				activeColormapXX member.
	@param	viewId	The view that requests the active colormap.
	@result		Integer value corresponding to the index of the active colormap
				in the given view.*/
- (int) activeColormapIndexForView:(OVViewId) viewId;

/*!	@method		isColormapFlatForView
    @discussion	Returns a BOOL value indicating whether the colormap shall be
                used with flat shading or linear interpolation
    @param	viewId	The view that requests the state of the colormap.
    @result		BOOL value indicating whether the colormap in the given view shall
                be handled as a flat colormap.*/
- (BOOL) isColormapFlatForView:(OVViewId) viewId;

/*!	@method			setColormapFlat
    @discussion		Sets the state of a colormap to flat or linear.
    @param	isDiscrete	The state of the colormap.
    @param	viewId  The view that the state of the colormap is set for.*/
- (void) setColormapFlat:(BOOL) isFlat forView:(OVViewId) viewId;

/*!	@method		isColormapDiscreteForView
	@discussion	Returns a BOOL value indicating whether the colormap shall be
				used as a stepfunction with discrete values or with continuous values.
	@param	viewId	The view that requests the state of the colormap.
	@result		BOOL value indicating whether the colormap in the given view shall
				be handled as a discrete colormap.*/
- (BOOL) isColormapDiscreteForView:(OVViewId) viewId;

/*!	@method			setColormapDiscrete
	@discussion		Sets the state of a colormap to discrete or continuous.
	@param	isDiscrete	The state of the colormap.
	@param	viewId  The view that the state of the colormap is set for.*/
- (void) setColormapDiscrete:(BOOL) isDiscrete forView:(OVViewId) viewId;

/*!	@method		setActiveColormapIndex
	@discussion	Sets the index of the active colormap for a specified view.
	@param	index	The index of the colormap.
	@param	viewId	The view that the index of the colormap is set for.*/
- (void) setActiveColormapIndex:(int) index forView:(OVViewId) viewId;

/*!	@method		toggleColormapLegendForView
    @discussion	Toogles the display of the colormap Legend for a specified view.
    @param	viewId	The view that the index of the colormap is set for.*/
- (void) toggleColormapLegendForView:(OVViewId) viewId;

/*!	@method		setColormapLegendVisible
    @discussion	Set the display of the colormap Legend for a specified view.
    @param	visible	BOOL value indicating visibility.
    @param	viewId	The view that the index of the colormap is set for.*/
- (void) setColormapLegendVisible: (BOOL) visible forView:(OVViewId) viewId;

/*!	@method		isColormapLegendVisibleForView
    @discussion	Returns a BOOL value indicating whether the legend for the colormap
                shall be rendered on screen or not.
 @param	viewId	The view that requests the state of the colormap legend.
 @result		BOOL value indicating whether the colormap in the given view shall
                be rendered on screen or not.*/
- (BOOL) isColormapLegendVisibleForView:(OVViewId) viewId;

/*!   @method      updateBackgroundColors
   @discussion   Updates background colors for some views, to be used when
               switching between regular and dark mode.*/
- (void) updateBackgroundColors;

/*!	@method		initColormaps
	@discussion	Initializes the hardcoded colormaps.*/
- (void) initColormaps;

/*!   @property   renderAsWireframe3D
 @brief      BOOL value, indicating if the surface in the 3D view is rendered
 opaque or as mesh.*/
@property (nonatomic) BOOL renderAsWireframe3D;

/*!	@property	tSViewBackgroundColor
	@brief		Float pointer to three [0..1] scaled rgb values used as background
				color for the Time Series View.*/
@property (nonatomic) float *tSViewBackgroundColor;

/*!	@property	threeDViewBackgroundColor
	@brief		Float pointer to three [0..1] scaled rgb values used as background
				color for the 3D View.*/
@property (nonatomic) float *threeDViewBackgroundColor;

/*!	@property	isDark
	@brief		BOOL value, indicating if the system is in dark mode.*/
@property (nonatomic) BOOL isDark;

/*!	@property	activeSurface3D
	@brief		The OVEnsembleProperty used for the surface geometry in the 3D view.*/
@property (nonatomic) OVEnsembleProperty activeSurface3D;

/*!	@property	activeSurfaceVariable3D
    @brief		The ID of the variable used for the surface geometry in the 3D view.*/
@property (nonatomic) NSInteger activeSurfaceVariable3D;

/*!	@property	activeProperty3D
	@brief		The OVEnsembleProperty used for the surface texture in the 3D view.*/
@property (nonatomic) OVEnsembleProperty activeProperty3D;

/*!	@property	activePropertyVariable3D
    @brief		The ID of the variable used for the surface texture in the 3D view.*/
@property (nonatomic) NSInteger activePropertyVariable3D;

/*!	@property	activeNoiseProperty3D
    @brief		The OVEnsembleProperty used for the noise texture in the 3D view.*/
@property (nonatomic) OVEnsembleProperty activeNoiseProperty3D;

/*!	@property	activeNoisePropertyVariable3D
    @brief		The ID of the variable used for the noise texture in the 3D view.*/
@property (nonatomic) NSInteger activeNoisePropertyVariable3D;

/*!	@property	activeProperty2D
	@brief		The OVEnsembleProperty used for the surface texture in the 2D view.*/
@property (nonatomic) OVEnsembleProperty activeProperty2D;

/*!	@property	activePropertyVariable2D
    @brief		The ID of the variable used for the surface texture in the 2D view.*/
@property (nonatomic) NSInteger activePropertyVariable2D;

/*!	@property	activeNoiseProperty2D
    @brief		The OVEnsembleProperty used for the noise texture in the 2D view.*/
@property (nonatomic) OVEnsembleProperty activeNoiseProperty2D;

/*!	@property	activeNoisePropertyVariable2D
    @brief		The ID of the variable used for the noise texture in the 2D view.*/
@property (nonatomic) NSInteger activeNoisePropertyVariable2D;

/*!	@property	animateTime
	@brief		BOOL value, indicating if the time steps shall be animated.*/
@property (nonatomic) BOOL animateTime;

/*!	@property	animateMember
	@brief		BOOL value, indicating if the members shall be animated.*/
@property (nonatomic) BOOL animateMember;

/*!	@property	leftGlyphActiveItem
	@brief		NSString with the name if the active platform or path for the left side
				of the glyphs in the time series view.*/
@property (nonatomic) NSString *leftGlyphActiveItem;

/*!	@property	rightGlyphActiveItem
	@brief		NSString with the name if the active platform or path for the right side
				of the glyphs in the time series view.*/
@property (nonatomic) NSString *rightGlyphActiveItem;

/*!	@property	leftGlyphActiveVariable
    @brief		The variable for the left side of the glyphs in the time series view.
                Negative values for additional data variables, positive for main data.*/
@property (nonatomic) OVVariable *leftGlyphActiveVariable;

/*!	@property	rightGlyphActiveVariableId
    @brief		The variable for the right side of the glyphs in the time series view.
                Negative values for additional data variables, positive for main data.*/
@property (nonatomic) OVVariable *rightGlyphActiveVariable;

/*!	@property	histogramPosition
    @brief		The position of the 1D histogram im the histogram view.*/
@property (nonatomic) iVector2 histogramPosition;

/*!	@property	isPathlineTracingEnabled
    @brief		Flag whether pathline tracing is enabled.*/
@property (nonatomic) BOOL isPathlineTracingEnabled;

/*!	@property	isPathlineTraceAvailable
    @brief		Flag whether a trace is available.*/
@property (nonatomic) BOOL isPathlineTraceAvailable;

/*!	@property	activeColormapPathline
    @brief		The index of the active colormap for the pathline trace.*/
@property (nonatomic) int activeColormapPathline;

/*!	@property	pathlineScale
    @brief		The scale for cutting of the percentages on top.*/
@property (nonatomic) int pathlineScale;

/*!	@property	pathlineAlpha
    @brief		The scale for the alpha value used in the visualization.*/
@property (nonatomic) int pathlineAlpha;


@end
