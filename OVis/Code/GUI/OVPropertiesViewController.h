/*!	@header		OVPropertiesViewController.h
	@discussion Controller for the window containting the OVPropertiesView.
	@author		Thomas Höllt
	@updated	2013-10-17 */


// System Headers
#import <Cocoa/Cocoa.h>

// Custom Headers
#import "OVAppDelegateProtocol.h"

// Friend Classes
@class OVPropertiesView;
@class OVEnsembleData;
@class OVViewSettings;
@class SMDoubleSlider;

/*!	@class		OV3DWindowController
	@discussion	Controller for the window containting the OVPropertiesView.*/
@interface OVPropertiesViewController : NSViewController {
	
   id<OVAppDelegateProtocol> _appDelegate;
   OVEnsembleData *_ensembleData;
   OVViewSettings *_viewSettings;
   
   bool _isDark;

   IBOutlet NSView *viewSection2D;
   IBOutlet NSView *viewSection3D;
   IBOutlet NSView *viewSectionStatistics;
   IBOutlet NSView *viewSectionRisk;
   IBOutlet NSView *viewSectionCurrent;


   // ===== Statistics =====
   // Time Range
   IBOutlet NSTextField *timeRangeLoTextField;
   IBOutlet NSTextField *timeRangeHiTextField;
   IBOutlet NSStepper *timeRangeLoStepper;
   IBOutlet NSStepper *timeRangeHiStepper;
   IBOutlet SMDoubleSlider *timeRangeDoubleSlider;

   // Time Single
   IBOutlet NSButton *timeSingleButton;
   IBOutlet NSTextField *timeSingleTextField;
   IBOutlet NSSlider *timeSingleSlider;
   IBOutlet NSButton *timeSingleAnimateButton;
   NSTimer *_timeSingleTimer;

   // Member Range
   IBOutlet NSTextField *memberRangeLoTextField;
   IBOutlet NSTextField *memberRangeHiTextField;
   IBOutlet NSStepper *memberRangeLoStepper;
   IBOutlet NSStepper *memberRangeHiStepper;
   IBOutlet SMDoubleSlider *memberRangeDoubleSlider;

   // Member Single
   IBOutlet NSButton *memberSingleButton;
   IBOutlet NSTextField *memberSingleTextField;
   IBOutlet NSSlider *memberSingleSlider;
   IBOutlet NSButton *memberSingleAnimateButton;
   NSTimer *_memberSingleTimer;


   // ===== 3D Properties =====
   IBOutlet NSPopUpButton *surface3DPopUP;
   IBOutlet NSPopUpButton *surface3DVariablePopUP;
   IBOutlet NSPopUpButton *statistic3DPopUP;
   IBOutlet NSPopUpButton *statistic3DVariablePopUP;
   IBOutlet NSPopUpButton *colormap3DPopUP;
   IBOutlet NSButton *colormapDiscrete3DButton;
   IBOutlet NSButton *colormapFlat3DButton;
   IBOutlet NSPopUpButton *noise3DPopUP;
   IBOutlet NSPopUpButton *noise3DVariablePopUP;


   // ===== 2D Properties =====
   IBOutlet NSPopUpButton *statistic2DPopUP;
   IBOutlet NSPopUpButton *statistic2DVariablePopUP;
   IBOutlet NSPopUpButton *colormap2DPopUP;
   IBOutlet NSButton *colormapFlat2DButton;
   IBOutlet NSButton *colormapDiscrete2DButton;
   IBOutlet NSPopUpButton *noise2DPopUP;
   IBOutlet NSPopUpButton *noise2DVariablePopUP;


   // ===== Risk Management =====
   IBOutlet NSTextField *riskHeightIsoTextField;
   IBOutlet NSStepper *riskHeightIsoStepper;
   IBOutlet NSSlider *riskHeightIsoSlider;

   IBOutlet NSTextField *riskIsoTextField;
   IBOutlet NSStepper *riskIsoStepper;
   IBOutlet NSSlider *riskIsoSlider;


   // ===== Current Vis =====
   IBOutlet NSButton *enableCurrentTracingButton;
   IBOutlet NSButton *clearCurrentTraceButton;

   IBOutlet NSPopUpButton *colormapCurrentPopUP;

   IBOutlet NSTextField *currentScaleTextField;
   IBOutlet NSStepper *currentScaleStepper;
   IBOutlet NSSlider *currentScaleSlider;

   IBOutlet NSTextField *currentAlphaTextField;
   IBOutlet NSStepper *currentAlphaStepper;
   IBOutlet NSSlider *currentAlphaSlider;
}

/*!	@method		refreshGUI
	@discussion	Refreshes the complete GUI from available data. (Parameter
				ranges, risk range, etc.) */
- (void) refreshGUI;

/*!   @method      refreshBackgroundColors
    @discussion   Refreshes the Background for the view. */
- (void) refreshBackgroundColors;


/*!	@method		refreshPropertiesGUI
	@discussion	Refreshes general properties GUI valid for all views from data.*/
- (void) refreshPropertiesGUI;

/*!	@method		refresh3DGUI
	@discussion	Refreshes GUI corresponding to 3D view.*/
- (void) refresh3DGUI;

/*!	@method		refresh2DGUI
	@discussion	Refreshes GUI corresponding to 2D view.*/
- (void) refresh2DGUI;

/*!	@method		refreshRiskGUI
	@discussion	Refreshes GUI corresponding to risk settings.*/
- (void) refreshRiskGUI;

/*!	@method		refreshCurrentGUI
    @discussion	Refreshes GUI corresponding to current settings.*/
- (void) refreshCurrentGUI;

/*!	@method		refreshTimeRangeControls
	@discussion	Refreshes GUI for the time parameter in the general section.*/
- (void) refreshTimeRangeControls;

/*!	@method		refreshMemberRangeControls
	@discussion	Refreshes GUI for the member parameter in the general section.*/
- (void) refreshMemberRangeControls;

/*!	@method		refreshRiskHeightControls
	@discussion	Refreshes GUI for the critical sea level corresponding to the risk computation.*/
- (void) refreshRiskHeightControls;

/*!	@method		refreshRiskControls
	@discussion	Refreshes GUI for the actual risk percentage.*/
- (void) refreshRiskControls;

/*!	@method		increaseSingleTimeStep
	@discussion	Increases the active single time parameter by one (or sets it to
				the min of the time range if it is the max of the range).
	@param	timer	The timer object that fires this method.*/
- (void) increaseSingleTimeStep: (NSTimer *)timer;

/*!	@method		increaseSingleMember
	@discussion	Increases the active single member parameter by one (or sets it to
				the min of the time range if it is the max of the range).
	@param	timer	The timer object that fires this method.*/
- (void) increaseSingleMember: (NSTimer *)timer;

/*!	@method		setTimeRange
	@discussion	Sets lower and upper boundaries for the time parameter via the
				NSSteppers and NSTextFields.
	@param	sender	The sender of the event.*/
- (IBAction) setTimeRange:(id)sender;

/*!	@method		setTimeRangeFromSlider
	@discussion	Sets lower and upper boundaries for the time parameter via the NSSLider.
	@param	sender	The sender of the event.*/
- (IBAction) setTimeRangeFromSlider:(id)sender;

/*!	@method		setTimeSingle
	@discussion	Toggles whether a single time step or the defined range will be
				visualized.
	@param	sender	The sender of the event.*/
- (IBAction) setTimeSingle:(id)sender;

/*!	@method		setTimeSingleId
	@discussion	Sets the id for the single time step in case setTimeSingle is set.
	@param	sender	The sender of the event.*/
- (IBAction) setTimeSingleId:(id)sender;

/*!	@method		setTimeSingleAnimate
	@discussion	Toggles animation of single time steps over the defined range.
	@param	sender	The sender of the event.*/
- (IBAction) setTimeSingleAnimate:(id)sender;

/*!	@method		setMemberRange
	@discussion	Sets lower and upper boundaries for the member parameter via the
				NSSteppers and NSTextFields.
	@param	sender	The sender of the event.*/
- (IBAction) setMemberRange:(id)sender;

/*!	@method		setMemberRangeFromSlider
	@discussion	Sets lower and upper boundaries for the member parameter via the NSSLider.
	@param	sender	The sender of the event.*/
- (IBAction) setMemberRangeFromSlider:(id)sender;

/*!	@method		setMemberSingle
	@discussion	Toggles whether a single member or the defined range will be
				visualized.
	@param	sender	The sender of the event.*/
- (IBAction) setMemberSingle:(id)sender;

/*!	@method		setMemberSingleId
	@discussion	Sets the id for the single member in case setTimeSingle is set.
	@param	sender	The sender of the event.*/
- (IBAction) setMemberSingleId:(id)sender;

/*!	@method		setMemberSingleAnimate
	@discussion	Toggles animation of single member over the defined range.
	@param	sender	The sender of the event.*/
- (IBAction) setMemberSingleAnimate:(id)sender;

/*!	@method		setActiveSurface3D
	@discussion	Sets the active property to be used for the surface geometry in
				the 3D view.
	@param	sender	The sender of the event.*/
- (IBAction) setActiveSurface3D:(id)sender;

/*!	@method		setActiveSurface3D
    @discussion	Sets the active variable to be used for the surface geometry in
                the 3D view.
    @param	sender	The sender of the event.*/
- (IBAction) setActiveSurfaceVariable3D:(id)sender;

/*!	@method		setActiveStatistic3D
	discussion	Sets the active property to be used for the surface texture in
				the 3D view.
	@param	sender	The sender of the event.*/
- (IBAction) setActiveStatistic3D:(id)sender;

/*!	@method		setActiveStatistic3D
    discussion	Sets the active variable to be used for the surface texture in
                the 3D view.
 @param	sender	The sender of the event.*/
- (IBAction) setActiveStatisticVariable3D:(id)sender;

/*!	@method		setActiveColormap3D
	@discussion	Sets the active colormap for surface texturing in the 3D view.
	@param	sender	The sender of the event.*/
- (IBAction) setActiveColormap3D:(id)sender;

/*!	@method		setActiveColormapFlat3D
    @discussion	Toggles between flat and interpolated colormaps in the 3D view.
    @param	sender	The sender of the event.*/
- (IBAction) setActiveColormapFlat3D:(id)sender;

/*!	@method		setActiveColormapDiscrete3D
	@discussion	Toggles between discrete and continuous colormaps in the 3D view.
	@param	sender	The sender of the event.*/
- (IBAction) setActiveColormapDiscrete3D:(id)sender;

/*!	@method		setActiveNoiseStatistic3D
    discussion	Sets the active property to be used for the noise texture in
    the 3D view.
    @param	sender	The sender of the event.*/
- (IBAction) setActiveNoiseStatistic3D:(id)sender;

/*!	@method		setActiveNoiseStatistic3D
    discussion	Sets the active variable to be used for the noise texture in
                the 3D view.
    @param	sender	The sender of the event.*/
- (IBAction) setActiveNoiseStatisticVariable3D:(id)sender;

/*!	@method		setActiveStatistic2D
	@discussion	Sets the active property to be used for the surface texture in
				the 2D view.
	@param	sender	The sender of the event.*/
- (IBAction) setActiveStatistic2D:(id)sender;

/*!	@method		setActiveStatisticVariable2D
    @discussion	Sets the active variable to be used for the surface texture in
                the 2D view.
    @param	sender	The sender of the event.*/
- (IBAction) setActiveStatisticVariable2D:(id)sender;

/*!	@method		setActiveColormap2D
	@discussion	Sets the active colormap for surface texturing in the 2D view.
	@param	sender	The sender of the event.*/
- (IBAction) setActiveColormap2D:(id)sender;

/*!	@method		setActiveColormapFlat2D
    @discussion	Toggles between flat and interpolated colormaps in the 2D view.
    @param	sender	The sender of the event.*/
- (IBAction) setActiveColormapFlat2D:(id)sender;

/*!	@method		setActiveColormapDiscrete2D
	@discussion	Toggles between discrete and continuous colormaps in the 2D view.
	@param	sender	The sender of the event.*/
- (IBAction) setActiveColormapDiscrete2D:(id)sender;

/*!	@method		setActiveNoiseStatistic2D
    discussion	Sets the active property to be used for the noise texture in
    the 2D view.
    @param	sender	The sender of the event.*/
- (IBAction) setActiveNoiseStatistic2D:(id)sender;

/*!	@method		setActiveNoiseStatisticVariable2D
    discussion	Sets the active variable to be used for the noise texture in
                the 2D view.
    @param	sender	The sender of the event.*/
- (IBAction) setActiveNoiseStatisticVariable2D:(id)sender;

/*!	@method		setRiskHeightIsoValue
	@discussion	Sets the isovalue for the critical sea level.
	@param	sender	The sender of the event.*/
- (IBAction) setRiskHeightIsoValue:(id)sender;

/*!	@method		setRiskIsoValue
	@discussion	Sets the isovalue for the risk derived from the critical sea level.
	@param	sender	The sender of the event.*/
- (IBAction) setRiskIsoValue:(id)sender;

/*!	@method		setCurrentTracingActive
    @discussion	Enables/disables the current tracing and visualization.
    @param	sender	The sender of the event.*/
- (IBAction) enableCurrentTracing:(id)sender;

/*!	@method		clearCurrentTrace
    @discussion	Clears the current trace.
    @param	sender	The sender of the event.*/
- (IBAction) clearCurrentTrace:(id)sender;

/*!	@method		setActiveColormapPathline
    @discussion	Sets the active colormap for traced pathlines.
    @param	sender	The sender of the event.*/
- (IBAction) setActiveColormapPathline:(id)sender;

/*!	@method		setPathlineScale
    @discussion	Sets the scaling for the pathline trace texture.
    @param	sender	The sender of the event.*/
- (IBAction) setPathlineScale:(id)sender;

/*!	@method		setPathlineAlpha
    @discussion	Sets the alpha scaling for the pathline trace texture.
    @param	sender	The sender of the event.*/
- (IBAction) setPathlineAlpha:(id)sender;


@end
