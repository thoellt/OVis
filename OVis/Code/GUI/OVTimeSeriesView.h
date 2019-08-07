/*!	@header		OVTimeSeriesView.h
	@discussion Custom Time Series View for OVis derived from OVGLView.
	@author		Thomas Höllt
	@updated	2013-07-29 */

// Custom Headers
#import "OVGLView.h"

// Friend Classes
@class OVTimeSeriesRenderer;

/*!	@class		OVTimeSeriesView
 @discussion	Custom Time Series View for OVis derived from OVGLView.*/
@interface OVTimeSeriesView : OVGLView {
	
	IBOutlet OVTimeSeriesRenderer *_renderer;
}

@end
