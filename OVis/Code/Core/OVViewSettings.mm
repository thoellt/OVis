//
//	OVViewSettings.mm
//

// System Headers
#import <AppKit/NSColor.h>

// Custom Headers
#import "OVColormap.h"

// Local Header
#import "OVViewSettings.h"

@implementation OVViewSettings

@synthesize tSViewBackgroundColor = _tSViewBackgroundColor;

@synthesize threeDViewBackgroundColor = _threeDViewBackgroundColor;
@synthesize renderAsWireframe3D		 = _renderAsWireframe3D;

@synthesize activeSurface3D	= _activeSurface3D;
@synthesize activeSurfaceVariable3D	= _activeSurfaceVariable3D;
@synthesize activeProperty3D = _activeProperty3D;
@synthesize activePropertyVariable3D = _activePropertyVariable3D;
@synthesize activeNoiseProperty3D = _activeNoiseProperty3D;
@synthesize activeNoisePropertyVariable3D = _activeNoisePropertyVariable3D;
@synthesize activeProperty2D = _activeProperty2D;
@synthesize activePropertyVariable2D = _activePropertyVariable2D;
@synthesize activeNoiseProperty2D = _activeNoiseProperty2D;
@synthesize activeNoisePropertyVariable2D = _activeNoisePropertyVariable2D;
@synthesize animateTime		= _animateTime;
@synthesize animateMember	= _animateMember;

@synthesize leftGlyphActiveItem	= _leftGlyphActiveItem;
@synthesize rightGlyphActiveItem = _rightGlyphActiveItem;
@synthesize leftGlyphActiveVariable = _leftGlyphActiveVariable;
@synthesize rightGlyphActiveVariable = _rightGlyphActiveVariable;

@synthesize histogramPosition = _histogramPosition;

@synthesize isPathlineTracingEnabled = _isPathlineTracingEnabled;
@synthesize isPathlineTraceAvailable = _isPathlineTraceAvailable;
@synthesize activeColormapPathline = _activeColormapPathline;
@synthesize pathlineScale = _pathlineScale;
@synthesize pathlineAlpha = _pathlineAlpha;

#pragma mark - Initialization

- (id) init
{
	self = [super init];
	
	if( !self ) return nil;
   
   _isDark = [[[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"] isEqualToString: @"Dark"];
	
   _threeDViewBackgroundColor = new float[4];
   _tSViewBackgroundColor = new float[4];
   
   float baseGrayValue = _isDark ? 50.f : 237.f;
   _threeDViewBackgroundColor[0] = baseGrayValue / 255.0f;
   _threeDViewBackgroundColor[1] = baseGrayValue / 255.0f;
   _threeDViewBackgroundColor[2] = baseGrayValue / 255.0f;
   _threeDViewBackgroundColor[3] = 1.0f;
   
   [self updateBackgroundColors];
   
	[self initColormaps];
	
	_renderAsWireframe3D = NO;
	
	_activeSurface3D = EnsemblePropertyMean;
	_activeSurfaceVariable3D = 0;
	_activeProperty3D = EnsemblePropertyNone;
	_activePropertyVariable3D = 0;
	_activeNoiseProperty3D = EnsemblePropertyNone;
	_activeNoisePropertyVariable3D = 0;
	_activeColormap3D = -1;
	_discreteColormap3D = 0;
    _showColormapLegend3D = NO;
	
	_activeProperty2D = EnsemblePropertyNone;
	_activePropertyVariable2D = 0;
	_activeNoiseProperty2D = EnsemblePropertyNone;
	_activeNoisePropertyVariable2D = 0;
	_activeColormap2D = -1;
	_discreteColormap2D = 0;
    _showColormapLegend2D = NO;
	
	_leftGlyphActiveItem = @"Active";
	_rightGlyphActiveItem = @"Active";
    
    _leftGlyphActiveVariable = nil;
    _rightGlyphActiveVariable = nil;
	
	_activeColormapTS = -1;
	_discreteColormapTS = 0;

	_animateTime = NO;
	_animateMember = NO;
    
    _isPathlineTracingEnabled = NO;
    _isPathlineTraceAvailable = NO;
    
    _activeColormapPathline = -1;
    
    _pathlineScale = 200;
    _pathlineAlpha = 1;

		
	return self;
}

- (void) updateBackgroundColors
{
   float baseGrayValue = _isDark ? 50.f : 237.f;
   
   if(_threeDViewBackgroundColor[0] == 50.f / 255.0f || _threeDViewBackgroundColor[0] == 237.f / 255.0f)
   {
      _threeDViewBackgroundColor[0] = baseGrayValue / 255.0f;
      _threeDViewBackgroundColor[1] = baseGrayValue / 255.0f;
      _threeDViewBackgroundColor[2] = baseGrayValue / 255.0f;
      _threeDViewBackgroundColor[3] = 1.0f;
   }
   
   _tSViewBackgroundColor[0] = baseGrayValue / 255.0f;
   _tSViewBackgroundColor[1] = baseGrayValue / 255.0f;
   _tSViewBackgroundColor[2] = baseGrayValue / 255.0f;
   _tSViewBackgroundColor[3] = 1.0f;
}

- (void) initColormaps
{
	_colormaps = [[NSMutableArray alloc] initWithCapacity:9];
	
	RGB col[11] =
    { {.r = 252, .g = 251, .b = 253},
      {.r = 239, .g = 237, .b = 245},
      {.r = 218, .g = 218, .b = 235},
      {.r = 188, .g = 189, .b = 220},
      {.r = 158, .g = 154, .b = 200},
      {.r = 128, .g = 125, .b = 168},
      {.r = 106, .g =  81, .b = 163},
      {.r =  84, .g =  39, .b = 143},
      {.r =  63, .g =   0, .b = 125},
      {.r =   0, .g =   0, .b =   0},
      {.r =   0, .g =   0, .b =   0} };
	[_colormaps addObject:[[OVColormap alloc] initWithData:col ofSize:9 name:@"Seq - Purple"]];
	
	col[0]	= {.r = 255, .g = 255, .b = 229};
	col[1]	= {.r = 247, .g = 252, .b = 185};
	col[2]	= {.r = 217, .g = 240, .b = 163};
	col[3]	= {.r = 173, .g = 221, .b = 142};
	col[4]	= {.r = 120, .g = 198, .b = 121};
	col[5]	= {.r =	 65, .g = 171, .b =	 93};
	col[6]	= {.r =	 35, .g = 132, .b =	 67};
	col[7]	= {.r =	  0, .g = 104, .b =	 55};
	col[8]	= {.r =	  0, .g =  69, .b =	 41};
	col[9]	= {.r =	  0, .g =   0, .b =	  0};
	col[10] = {.r =	  0, .g =   0, .b =	  0};
	[_colormaps addObject:[[OVColormap alloc] initWithData:col ofSize:9 name:@"Seq - Yellow Green"]];
	
	col[0]	= {.r = 255, .g = 255, .b = 229};
	col[1]	= {.r = 255, .g = 247, .b = 188};
	col[2]	= {.r = 254, .g = 227, .b = 145};
	col[3]	= {.r = 254, .g = 196, .b =	 79};
	col[4]	= {.r = 254, .g = 153, .b =	 41};
	col[5]	= {.r = 236, .g = 112, .b =	 20};
	col[6]	= {.r = 204, .g =  76, .b =	  2};
	col[7]	= {.r = 153, .g =  52, .b =	  4};
	col[8]	= {.r = 102, .g =  37, .b =	  6};
	col[9]	= {.r =	  0, .g =   0, .b =	  0};
	col[10] = {.r =	  0, .g =   0, .b =	  0};
	[_colormaps addObject:[[OVColormap alloc] initWithData:col ofSize:9 name:@"Seq - Yellow Orange Brown"]];
	
	col[0]	= {.r = 255, .g = 247, .b = 243};
	col[1]	= {.r = 253, .g = 224, .b = 221};
	col[2]	= {.r = 252, .g = 197, .b = 192};
	col[3]	= {.r = 250, .g = 159, .b =	181};
	col[4]	= {.r = 247, .g = 104, .b =	161};
	col[5]	= {.r = 221, .g =  52, .b =	151};
	col[6]	= {.r = 174, .g =   1, .b =	126};
	col[7]	= {.r = 122, .g =   1, .b =	119};
	col[8]	= {.r =  73, .g =   0, .b =	106};
	col[9]	= {.r =	  0, .g =   0, .b =	  0};
	col[10] = {.r =	  0, .g =   0, .b =	  0};
	[_colormaps addObject:[[OVColormap alloc] initWithData:col ofSize:9 name:@"Seq - Red Purple"]];
	
	col[0]	= {.r = 255, .g = 255, .b = 217};
	col[1]	= {.r = 237, .g = 248, .b = 177};
	col[2]	= {.r = 199, .g = 233, .b = 180};
	col[3]	= {.r = 127, .g = 205, .b =	187};
	col[4]	= {.r =  65, .g = 182, .b =	196};
	col[5]	= {.r =  29, .g = 145, .b =	192};
	col[6]	= {.r =  34, .g =  94, .b =	168};
	col[7]	= {.r =  37, .g =  52, .b =	148};
	col[8]	= {.r =   8, .g =  29, .b =	 88};
	col[9]	= {.r =	  0, .g =   0, .b =	  0};
	col[10] = {.r =	  0, .g =   0, .b =	  0};
	[_colormaps addObject:[[OVColormap alloc] initWithData:col ofSize:9 name:@"Seq - Yellow Green Blue"]];
	
	col[10] = {.r = 103, .g =	0, .b =	 31};
	col[9]	= {.r = 178, .g =  24, .b =	 43};
	col[8]	= {.r = 214, .g =  96, .b =	 77};
	col[7]	= {.r = 244, .g = 165, .b = 130};
	col[6]	= {.r = 253, .g = 219, .b = 199};
	col[5]	= {.r = 247, .g = 247, .b = 247};
	col[4]	= {.r = 209, .g = 229, .b = 240};
	col[3]	= {.r = 146, .g = 197, .b = 222};
	col[2]	= {.r =	 67, .g = 147, .b = 195};
	col[1]	= {.r =	 33, .g = 102, .b = 172};
	col[0]	= {.r =	  5, .g =  48, .b =	 97};
	[_colormaps addObject:[[OVColormap alloc] initWithData:col ofSize:11 name:@"Div - Red Blue"]];
	
	col[10] = {.r = 103, .g =   0, .b =	 31};
	col[9]	= {.r = 178, .g =  24, .b =	 43};
	col[8]	= {.r = 214, .g =  96, .b =	 77};
	col[7]	= {.r = 244, .g = 165, .b = 130};
	col[6]	= {.r = 253, .g = 219, .b = 199};
	col[5]	= {.r = 255, .g = 255, .b = 255};
	col[4]	= {.r = 224, .g = 224, .b = 224};
	col[3]	= {.r = 186, .g = 186, .b = 186};
	col[2]	= {.r = 135, .g = 135, .b = 135};
	col[1]	= {.r =	77, .g =   77, .b =  77};
	col[0]	= {.r =	26, .g =   26, .b =  26};
	[_colormaps addObject:[[OVColormap alloc] initWithData:col ofSize:11 name:@"Div - Red Grey"]];
	
	col[10] = {.r = 142, .g =   1, .b =	 82};
	col[9]	= {.r = 197, .g =  27, .b =	125};
	col[8]	= {.r = 222, .g = 119, .b =	174};
	col[7]	= {.r = 241, .g = 182, .b = 218};
	col[6]	= {.r = 253, .g = 224, .b = 239};
	col[5]	= {.r = 247, .g = 247, .b = 247};
	col[4]	= {.r = 230, .g = 245, .b = 208};
	col[3]	= {.r = 184, .g = 225, .b = 134};
	col[2]	= {.r = 127, .g = 188, .b =  65};
	col[1]	= {.r =	 77, .g = 146, .b =  33};
	col[0]	= {.r =	 39, .g = 100, .b =  25};
	[_colormaps addObject:[[OVColormap alloc] initWithData:col ofSize:11 name:@"Div - Pink Green"]];
	
	col[10] = {.r =  84, .g =  48, .b =	  5};
	col[9]	= {.r = 140, .g =  81, .b =	 10};
	col[8]	= {.r = 191, .g = 129, .b =	 45};
	col[7]	= {.r = 223, .g = 194, .b = 125};
	col[6]	= {.r = 246, .g = 232, .b = 195};
	col[5]	= {.r = 245, .g = 245, .b = 245};
	col[4]	= {.r = 199, .g = 234, .b = 229};
	col[3]	= {.r = 128, .g = 205, .b = 193};
	col[2]	= {.r =  53, .g = 151, .b = 143};
	col[1]	= {.r =	  1, .g = 102, .b =  94};
	col[0]	= {.r =	  0, .g =  60, .b =  48};
	[_colormaps addObject:[[OVColormap alloc] initWithData:col ofSize:11 name:@"Div - Brown BlueGreen"]];
	
	col[10] = {.r = 165, .g =   0, .b =	 38};
	col[9]	= {.r = 215, .g =  48, .b =	 39};
	col[8]	= {.r = 244, .g = 109, .b =	 67};
	col[7]	= {.r = 253, .g = 174, .b =	 97};
	col[6]	= {.r = 254, .g = 224, .b = 139};
	col[5]	= {.r = 255, .g = 255, .b = 191};
	col[4]	= {.r = 217, .g = 239, .b = 139};
	col[3]	= {.r = 166, .g = 217, .b = 106};
	col[2]	= {.r = 102, .g = 189, .b =	 99};
	col[1]	= {.r =	 26, .g = 152, .b =	 80};
	col[0]	= {.r =   0, .g = 104, .b =	 55};
	[_colormaps addObject:[[OVColormap alloc] initWithData:col ofSize:11 name:@"Div - Red Yellow Green"]];
	
	col[10] = {.r = 158, .g =	1, .b =	 66};
	col[9]	= {.r = 213, .g =  62, .b =	 79};
	col[8]	= {.r = 244, .g = 109, .b =	 67};
	col[7]	= {.r = 253, .g = 174, .b =	 97};
	col[6]	= {.r = 254, .g = 224, .b = 139};
	col[5]	= {.r = 255, .g = 255, .b = 191};
	col[4]	= {.r = 230, .g = 245, .b = 152};
	col[3]	= {.r = 171, .g = 221, .b = 164};
	col[2]	= {.r = 102, .g = 194, .b = 165};
	col[1]	= {.r =	 50, .g = 136, .b = 189};
	col[0]	= {.r =	 94, .g =  79, .b = 162};
	[_colormaps addObject:[[OVColormap alloc] initWithData:col ofSize:11 name:@"Div - Spectral"]];
}

#pragma mark - View Settings

- (void) setIsDark:(BOOL)isDark
{
   _isDark = isDark;
   [self updateBackgroundColors];
}

- (void) setThreeDViewBackgroundColorWithNSColor: (NSColor*) color
{
	NSColor *col = [color colorUsingColorSpaceName:NSDeviceRGBColorSpace];
	
	_threeDViewBackgroundColor[0] = col.redComponent;
	_threeDViewBackgroundColor[1] = col.greenComponent;
	_threeDViewBackgroundColor[2] = col.blueComponent;
	_threeDViewBackgroundColor[3] = 1.0;
}

#pragma mark - Color Maps

- (OVColormap*) activeColormapForView:(OVViewId) viewId
{	
	switch (viewId)
	{
		case ViewId2D:
			return [self colormapAtIndex:_activeColormap2D];
			break;
		case ViewId3D:
			return [self colormapAtIndex:_activeColormap3D];
			break;
		case ViewIdTS:
			return [self colormapAtIndex:_activeColormapTS];
			break;
        case ViewIdHistogram:
            return nil;
		default:
			return nil;
	}
	return nil;
}

- (OVColormap*) activeColormapForPathline
{
    return [self colormapAtIndex: _activeColormapPathline ];
}

- (BOOL) isColormapDiscreteForView:(OVViewId) viewId
{
	switch (viewId)
	{
		case ViewId2D:
			return _discreteColormap2D;
			break;
		case ViewId3D:
			return _discreteColormap3D;
			break;
		case ViewIdTS:
			return _discreteColormapTS;
			break;
        case ViewIdHistogram:
            return NO;
		default:
			return NO;
	}
	return NO;
}

- (BOOL) isColormapFlatForView:(OVViewId) viewId
{
	switch (viewId)
	{
		case ViewId2D:
			return _flatColormap2D;
			break;
		case ViewId3D:
			return _flatColormap3D;
			break;
		case ViewIdTS:
			return NO;
			break;
        case ViewIdHistogram:
            return NO;
		default:
			return NO;
	}
	return NO;
}

- (int) activeColormapIndexForView:(OVViewId) viewId
{
	switch (viewId)
	{
		case ViewId2D:
			return _activeColormap2D;
			break;
		case ViewId3D:
			return _activeColormap3D;
			break;
		case ViewIdTS:
			return _activeColormapTS;
			break;
        case ViewIdHistogram:
            return 0;
		default:
			return 0;
	}
	return 0;
}

- (void) setColormapFlat:(BOOL) isFlat forView:(OVViewId) viewId
{
	switch (viewId)
	{
		case ViewId2D:
			_flatColormap2D = isFlat;
			break;
		case ViewId3D:
			_flatColormap3D = isFlat;
			break;
		case ViewIdTS:
			break;
        case ViewIdHistogram:
            break;
		case ViewIdCount:
			break;
		default:
			break;
	}
}

- (void) setColormapDiscrete:(BOOL) isDiscrete forView:(OVViewId) viewId
{
	switch (viewId)
	{
		case ViewId2D:
			_discreteColormap2D = isDiscrete;
			break;
		case ViewId3D:
			_discreteColormap3D = isDiscrete;
			break;
		case ViewIdTS:
			_discreteColormapTS = isDiscrete;
			break;
        case ViewIdHistogram:
            break;
		case ViewIdCount:
			break;
		default:
			break;
	}
}

- (void) setActiveColormapIndex:(int) idx forView:(OVViewId) viewId
{
	switch (viewId)
	{
		case ViewId2D:
			_activeColormap2D = idx;
			break;
		case ViewId3D:
			_activeColormap3D = idx;
			break;
		case ViewIdTS:
			_activeColormapTS = idx;
			break;
        case ViewIdHistogram:
            break;
		case ViewIdCount:
			break;
		default:
			break;
	}
}

- (void) setColormapLegendVisible: (BOOL) visible forView:(OVViewId) viewId
{
	switch (viewId)
	{
		case ViewId2D:
			_showColormapLegend2D = visible;
			break;
		case ViewId3D:
			_showColormapLegend3D = visible;
			break;
		case ViewIdTS:
			break;
        case ViewIdHistogram:
            break;
		case ViewIdCount:
			break;
		default:
			break;
	}
}

- (void) toggleColormapLegendForView:(OVViewId) viewId
{
	switch (viewId)
	{
		case ViewId2D:
			_showColormapLegend2D = !_showColormapLegend2D;
			break;
		case ViewId3D:
			_showColormapLegend3D = !_showColormapLegend3D;
			break;
		case ViewIdTS:
			break;
        case ViewIdHistogram:
            break;
		case ViewIdCount:
			break;
		default:
			break;
	}
}

- (BOOL) isColormapLegendVisibleForView:(OVViewId) viewId
{
	switch (viewId)
	{
		case ViewId2D:
			return _showColormapLegend2D;
			break;
		case ViewId3D:
			return _showColormapLegend3D;
			break;
		case ViewIdTS:
			return NO;
			break;
        case ViewIdHistogram:
            return NO;
		default:
			return NO;
	}
	return NO;
}

- (OVColormap*) colormapAtIndex: (NSInteger) index
{
	if( index < 0 || index >= [_colormaps count] ) return nil;
	
	return _colormaps[index];
}

- (NSInteger) numColormaps
{
    return [_colormaps count];
}

@end
