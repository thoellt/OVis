//
//	AppDelegate.mm
//

// System Headers

// Custom Headers
#import "OVEnsembleData+Loader.h"
#import "OVEnsembleData+Statistics.h"
#import "OVGLContextManager.h"
#import "OVNCLoaderController.h"
#import "OVViewSettings.h"

#import "OVMainWindow.h"
#import "OV2DViewController.h"
#import "OV3DViewController.h"
#import "OVHistogramViewController.h"
#import "OVPropertiesViewController.h"
#import "OVTimeSeriesViewController.h"
#import "OVPreferencesWindowController.h"
#import "OVVariable2D.h"

// Local Header
#import "OVAppDelegate.h"

@implementation OVAppDelegate

@synthesize viewSettings = _viewSettings;
@synthesize ensembleData = _ensembleData;
@synthesize glContextManager = _glContextManager;

#pragma mark - App Launch

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// init data
	_viewSettings = [[OVViewSettings alloc] init];
	_ensembleData = [[OVEnsembleData alloc] init];
	_glContextManager = [[OVGLContextManager alloc] init];
   
   [NSDistributedNotificationCenter.defaultCenter addObserver:self selector:@selector(themeChanged:) name:@"AppleInterfaceThemeChangedNotification" object: nil];
	
    [self showPropertiesView:self];
    [self show2DView:self];
    [self show3DView:self];
    [self showHistogramView:self];
    [self showTimeSeriesView:self];
    
    _isMainWindowVisible = YES;
    
    _importFilesMenuItemEnabled = NO;
}

-(void)awakeFromNib
{
}

#pragma mark - IBAction

- (IBAction) toggleMainWindow:(id)sender
{
    if( _isMainWindowVisible ){
        [_mainWindow close];
        [_toggleMainWindowMenuItem setTitle:@"Open Main Window"];
        _isMainWindowVisible = NO;
    } else {
        [_mainWindow makeKeyAndOrderFront:self];
        [_toggleMainWindowMenuItem setTitle:@"Close Main Window"];
        _isMainWindowVisible = YES;
    }
}

- (IBAction) showPreferencesWindow:(id)sender
{
   if( !_preferencesWindowController ){
      _preferencesWindowController = [[OVPreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindow"];
   }
   
   [_preferencesWindowController showWindow:self];
}

- (IBAction) showPropertiesView:(id)sender
{
   if( _propertiesViewController ) return;
    
   _propertiesViewController = [[OVPropertiesViewController alloc] initWithNibName:@"PropertiesView" bundle:nil];
    
   NSView *propertiesView = _propertiesViewController.view;
   propertiesView.translatesAutoresizingMaskIntoConstraints = NO;
   [_propertiesScrollView setDocumentView:propertiesView];

   int h = propertiesView.frame.size.height;
   NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(propertiesView);
   [_propertiesClipView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[propertiesView]-0-|" options:0 metrics:nil views:viewsDictionary] ];
   NSString *height = [NSString stringWithFormat:@"V:[propertiesView(==%d)]", h ];
   [_propertiesClipView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:height options:0 metrics:nil views:viewsDictionary] ];

   bool isDark = [[[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"] isEqualToString: @"Dark"];
   float baseGrayValue = isDark ? 1.0 - 0.929: 0.929;

   CALayer *viewLayer = [CALayer layer];
   [viewLayer setBackgroundColor:CGColorCreateGenericRGB(baseGrayValue, baseGrayValue, baseGrayValue, 1.0)];
   [_propertiesClipView setWantsLayer:YES];
   [_propertiesClipView setLayer:viewLayer];
}

- (IBAction) show2DView:(id)sender
{
   if( _twoDViewController ) return;

   _twoDViewController = [[OV2DViewController alloc] initWithNibName:@"2DView" bundle:nil];

   [_bottomSplitView replaceSubview:_2DView with:[_twoDViewController view]];
}

- (IBAction) show3DView:(id)sender
{
   if( _threeDViewController ) return;

   _threeDViewController = [[OV3DViewController alloc] initWithNibName:@"3DView" bundle:nil];

   [_topSplitView replaceSubview:_3DView with:[_threeDViewController view]];
}

- (IBAction) showTimeSeriesView:(id)sender
{
	if( _timeSeriesViewController ) return;
    
	_timeSeriesViewController = [[OVTimeSeriesViewController alloc] initWithNibName:@"TimeSeriesView" bundle:nil];
    
    [_bottomSplitView replaceSubview:_timeSeriesView with:[_timeSeriesViewController view]];
}

- (IBAction) showHistogramView:(id)sender
{
	if( _histogramViewController ) return;
        
    _histogramViewController = [[OVHistogramViewController alloc] initWithNibName:@"HistogramView" bundle:nil];
    
    [_topSplitView replaceSubview:_histogramView with:[_histogramViewController view]];
}

- (IBAction) toggle2DWindowProperties:(id)sender
{
	if( !_twoDViewController ) return;
	
	if( [show2DProperties.title isEqualToString:@"Show 2D View Properties"] )
	{
		[show2DProperties setTitle:@"Hide 2D View Properties"];
	} else
	{
		[show2DProperties setTitle:@"Show 2D View Properties"];
	}
	
	[_twoDViewController toggleProperties];
}

- (IBAction) toggleTimeSeriesWindowProperties:(id)sender
{
	if( !_timeSeriesViewController ) return;
	
	if( [showTSProperties.title isEqualToString:@"Show Time Series View Properties"] )
	{
		[showTSProperties setTitle:@"Hide Time Series View Properties"];
	} else
	{
		[showTSProperties setTitle:@"Show Time Series View Properties"];
	}
	
	[_timeSeriesViewController toggleProperties];
}

- (IBAction) openFile:(id)sender
{	
	// Create the File Open Dialog class.
	NSOpenPanel* filePicker = [NSOpenPanel openPanel];	
	
	[filePicker setFloatingPanel:YES];
	[filePicker setCanChooseDirectories:NO];
	[filePicker setCanChooseFiles:YES];
	[filePicker setAllowsMultipleSelection:YES];
	[filePicker setAllowedFileTypes:[NSArray arrayWithObjects:@"ovis", @"nc", nil]];
	
	// Display the dialog.
	// If the OK button was pressed, process the files.
	if ( [filePicker runModal] != NSOKButton ) return;
    
    // reset the data
    //_ensembleData = [[OVEnsembleData alloc] init];

    // Get an array containing the full filenames of all
    // files and directories selected.
    _fileList = [filePicker URLs];
    assert( [_fileList count] > 0 );
    
    NSString *ext = [[_fileList objectAtIndex:0] pathExtension];

    if( [ext isEqualToString:@"ovis"] )
    {
        [self openFromFileList];
    }
    else if( [ext isEqualToString:@"nc"] )
    {
        for( int i = 0; i < [_fileList count]; i++ )
        {
            assert( [[[_fileList objectAtIndex:i] pathExtension] isEqualToString:@"nc"] );
        }
        
        if(!_netCDFLoaderController)
            _netCDFLoaderController = [[OVNCLoaderController alloc] init];
        
        [_netCDFLoaderController addFiles:_fileList];
        
        //[_netCDFLoaderController showSheet:filePicker];
        [_netCDFLoaderController showSheet:_mainWindow];
    }
}

- (void) openFromFileList
{
    assert( [_fileList count] > 0 );
    
    NSString *ext = [[_fileList objectAtIndex:0] pathExtension];
    
    BOOL success = NO;
    
    if( [ext isEqualToString:@"ovis"] )
    {
        assert( [_fileList count] == 1 );
        success = [_ensembleData openEnsembleFromOVisFile:[_fileList objectAtIndex:0]];
    }
    else if( [ext isEqualToString:@"nc"] )
    {
        //[_ensembleData openEnsembleFromNCDFiles:_fileList];
        success = YES;
    }
    
    if( success )
    {
        [_ensembleData setIsLoaded:YES];
        
        [_ensembleData invalidateStatisticsWithUpdate:NO];
        // TODO VAR
        OVVariable2D* variable = _ensembleData.variables2D[0];
        [_ensembleData initRangesForVariable:variable];
        [_ensembleData updateStatisticsForVariable:variable];
        
        [_viewSettings setLeftGlyphActiveItem:@"Active"];
        [_viewSettings setLeftGlyphActiveVariable:variable];
        [_viewSettings setRightGlyphActiveItem:@"Active"];
        [_viewSettings setRightGlyphActiveVariable:variable];
        
        _importFilesMenuItemEnabled = YES;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC/10), dispatch_get_main_queue(), ^(void){
            
            [self->_threeDViewController refreshFromData:YES];
            
            [self->_twoDViewController refreshFromData:YES];
            [self->_twoDViewController setViewToMatchEnsemble:self];
            
            [self->_timeSeriesViewController refreshFromData:YES];
            [self->_timeSeriesViewController refreshGUI];
            
            [self->_histogramViewController refreshFromData:YES];
            
            [self->_propertiesViewController refreshGUI];
            
            [self->_preferencesWindowController initRangeControls];
        });
    }
}

- (IBAction) importFile:(id)sender
{
 	// Create the File Open Dialog class.
	NSOpenPanel* filePicker = [NSOpenPanel openPanel];
	
	[filePicker setFloatingPanel:YES];
	[filePicker setCanChooseDirectories:NO];
	[filePicker setCanChooseFiles:YES];
	[filePicker setAllowsMultipleSelection:YES];
	[filePicker setAllowedFileTypes:[NSArray arrayWithObjects:@"ova", nil]];
	
	// Display the dialog.
	// If the OK button was pressed, process the files.
	if ( [filePicker runModal] != NSOKButton ) return;
    
    // Get an array containing the full filenames of all
    // files and directories selected.
    NSArray* files = [filePicker URLs];
    assert( [files count] > 0 );
    
    NSString *ext = [[files objectAtIndex:0] pathExtension];
    
    assert( [ext isEqualToString:@"ova"] );
    
    [_ensembleData importDataFromOvaFiles:files];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC/10), dispatch_get_main_queue(), ^(void){
        
        [self->_twoDViewController refreshGUI];
        
        [self->_timeSeriesViewController refreshGUI];
    
        [self->_propertiesViewController refreshGUI];
        
        [self->_histogramViewController refreshFromData:YES];
    });
}

#pragma mark - View Handling

- (void) refreshAllViewsFromData
{
	[self refreshAllViewsFromDataIncludingGUI:NO];
}

- (void) refreshAllViewsFromDataIncludingGUI: (BOOL) includeGUI
{
	for( NSInteger v = 0; v < ViewIdCount; v++ )
	{
		[self refreshViewFromData:(OVViewId)(v)];
	}
}

- (void) refreshViewFromData:(OVViewId) viewId
{
	[self refreshViewFromData:viewId includingGUI:NO];
}

- (void) refreshViewFromData:(OVViewId) viewId includingGUI: (BOOL) includeGUI
{
	switch( viewId )
	{
		case ViewId2D:
			[_twoDViewController refreshFromData:includeGUI];
			break;
		case ViewId3D:
			[_threeDViewController refreshFromData:includeGUI];
			break;
		case ViewIdTS:
			[_timeSeriesViewController refreshFromData:includeGUI];
			break;
        case ViewIdHistogram:
            [_histogramViewController refreshFromData:includeGUI];
            break;
		default:
			break;
	}
}

- (void) refreshGUIforView: (OVViewId) viewId
{
	switch( viewId )
	{
		case ViewId2D:
			[_twoDViewController refreshGUI];
			break;
		case ViewId3D:
			break;
		case ViewIdTS:
			[_timeSeriesViewController refreshGUI];
			break;
		default:
			break;
	}
}

- (void) refreshGLBuffers: (OVViewId) viewId
{
	switch( viewId )
	{
		case ViewId2D:
			break;
		case ViewId3D:
			[_threeDViewController refreshGLBuffers];
			break;
		case ViewIdTS:
			break;
		default:
			break;
	}
}

- (void) themeChanged:(NSNotification *) notification
{
   //NSLog (@"%@", notification);
   bool isDark = [[[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"] isEqualToString: @"Dark"];
   [_viewSettings setIsDark:isDark];
   
   float baseGrayValue = isDark ? 1.0 - 0.929: 0.929;
    
    [[_propertiesClipView layer] setBackgroundColor:CGColorCreateGenericRGB(baseGrayValue, baseGrayValue, baseGrayValue, 1.0)];
}

#pragma mark Toolbar Delegate

- (void) changeColor:(id)sender
{
	[_viewSettings setThreeDViewBackgroundColorWithNSColor: [sender color]];
}

- (IBAction) toggleRenderWireframe:(id)sender
{
	[_viewSettings setRenderAsWireframe3D: ![_viewSettings renderAsWireframe3D]];
}

#pragma mark SplitView Delegate

-(void)splitViewWillResizeSubviews:(NSNotification *)notification
{
    [_mainWindow disableUpdatesUntilFlush];
}

#pragma mark MenuValidation
- (BOOL)validateMenuItem:(NSMenuItem *)item {

    if (item == _importFilesMenuItem)
    {
        if (_importFilesMenuItemEnabled)
        {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

@end
