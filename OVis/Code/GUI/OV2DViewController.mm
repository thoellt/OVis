//
//	OV2DViewController.mm
//

// System Headers
#import <Foundation/NSGeometry.h>
#import <MapKit/MapKit.h>

// Custom Headers
#import "OVViewSettings.h"
#import "OVEnsembleData.h"
#import "OVEnsembleData+Platforms.h"
#import "OVOffShorePlatform.h"
#import "OV2DView.h"
#import "OVMapOverlay.h"
#import "OVMapOverlayRenderer.h"
#import "OVPlatformAnnotation.h"

#import "general.h"

// Local Header
#import "OV2DViewController.h"

@implementation OV2DViewController

@synthesize mapview = _mapview;

#pragma mark View Generation

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
	self = [super initWithNibName:nibName bundle:nibBundle];
    
	if (self) {
		// Initialization code here.
		_appDelegate = (id<OVAppDelegateProtocol>) [NSApplication sharedApplication].delegate;
		_viewSettings = _appDelegate.viewSettings;
		
		_mainOverlay = [[OVMapOverlay alloc] init];
		_mainOverlayRenderer = [[OVMapOverlayRenderer alloc] initWithOverlay:_mainOverlay];
		
		_isDraggingPin = NO;
		_draggingPinName = nil;
	}
	
	return self;
}

-(void)awakeFromNib
{
	[super awakeFromNib];
	
	[_mapview setShowsControls:YES];
	[_mapview setMapType:MKMapTypeSatellite];
	
	[self refreshFromData:NO];
}

- (void)loadView
{
	[super loadView];
	
	[verticalSpace2DViewBottom setConstant:100.0f];
	
	// Implement this method to handle any initialization after your view controller's view has been loaded from its nib file.
	[self performSelectorOnMainThread:@selector(reloadMap:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:NO];
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void) dealloc
{
}

#pragma mark Data

- (void) refreshFromData:(BOOL) newData
{
	[_mapview removeOverlay:_mainOverlay];
	
	[_mainOverlay refreshData];
    
    // We need to rebuild the renderer everytime this is called after loading a new dataset
    // even if now data is rendered at this point
    if( newData )
		[_mainOverlayRenderer rebuildRenderer];
	else
		[_mainOverlayRenderer refreshRenderer];
	
    // we early out here without refreshing the data and adding the overlay if no data shall be rendered
    // this results in no overlay at all in the 2D, which is desired, other than in the 3D view, where we always
    // want the surface (with dummy colorcoding if no property is selected)
	if( [_viewSettings activeProperty2D] == EnsemblePropertyNone ) return;
    
    [_mainOverlayRenderer refreshImageDataForView:ViewId2D];
	
	[_mapview addOverlay:_mainOverlay];
}

- (void) refreshGUI
{
    [self refreshPlatformGUI];
	[self refreshPins];
}

- (void) reloadMap:(NSNumber*) animate
{
	EnsembleLonLat *lonlat = _appDelegate.ensembleData.ensembleLonLat;
	
	if( !lonlat ) return;
	
	MKCoordinateRegion region;
	region.center.latitude = (lonlat->lat_max + lonlat->lat_min) * 0.5;
	region.center.longitude = (lonlat->lon_max + lonlat->lon_min) * 0.5;
	region.span.latitudeDelta = lonlat->lat_max - lonlat->lat_min;
	region.span.longitudeDelta = lonlat->lon_max - lonlat->lon_min;
	
	[_mapview setRegion:[_mapview regionThatFits:region] animated:[animate boolValue]];
}

- (void) refreshPins
{
	NSMutableDictionary *platforms = [_appDelegate.ensembleData platforms];
	NSString *activeName = [_appDelegate.ensembleData getActivePlatform].name;
	
	NSMutableArray *annotations = [[NSMutableArray alloc] initWithCapacity:[platforms count]];
	
	for(id key in platforms) {
		OVOffShorePlatform *p = [platforms objectForKey:key];
		NSString *name = [p name];
        
        // Check if this pin has been added via GUI or loaded (if loaded it will not have an annotation
        if( !p.annotation )
        {
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([p latitude], [p longitude]);
            OVPlatformAnnotation* annotation = [[OVPlatformAnnotation alloc] initWithCoordinates:coordinate
                                                                                            Name:name
                                                                                     Description:[NSString stringWithFormat:@"Lat: %.3f, Lon: %.3f", [p latitude], [p longitude]]
                                                                                       Draggable:![p isFixed]];
            
            [p setAnnotation:annotation];
            [_mapview addAnnotation:annotation];
        }
        
		
		NSColor* color = NSColor.systemGreenColor;
		bool isSelected = [name isEqualToString:activeName];
		if( isSelected ) color = NSColor.systemRedColor;
		
		//[mapview removeAnnotation:p.annotation];
		[p.annotation setPinColor:color];
		[p.annotation setSubtitle:[NSString stringWithFormat:@"Lat: %.3f, Lon: %.3f", p.latitude, p.longitude]];
		
		[annotations addObject:p.annotation];
		//[mapview addAnnotation:p.annotation];
	}
	
	[_mapview removeAnnotations:[annotations copy]];
	[_mapview addAnnotations:[annotations copy]];
	
	OVOffShorePlatform *p = [_appDelegate.ensembleData getActivePlatform];
	[[_mapview viewForAnnotation:p.annotation] setSelected:YES animated:NO];
	
}

- (void) refreshCoordsFromPinWithTitle: (NSString*) title
{
	OVOffShorePlatform *platform	= [_appDelegate.ensembleData getPlatformWithName:title];
	
	MKAnnotationView *annotationView = [_mapview viewForAnnotation:platform.annotation];
	CLLocationCoordinate2D coord;
	
	if( _isDraggingPin )
	{
		// TODO: there should be a better way to get the coord
		CGPoint hoverPoint = CGPointMake(NSMinX(annotationView.frame) + annotationView.centerOffset.x,
										 NSMaxY(annotationView.frame) - 1.5 );
		coord = [_mapview convertPoint:hoverPoint toCoordinateFromView:_mapview];
		//NSLog(@"View Coordinate Lat = %f, Lon = %f", coord.latitude, coord.longitude);
	}
	else
	{
		coord = annotationView.annotation.coordinate;
		//NSLog(@"Anno Coordinate Lat = %f, Lon = %f", coord.latitude, coord.longitude);
	}
	
	
    [[_appDelegate ensembleData] updatePositionOfPlatformWithName:title toLat:coord.latitude lon:coord.longitude];
	
	[self refreshLonLatGUI];
}

#pragma mark Overlay & Annotations

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
	
	if( [overlay isEqual:_mainOverlay] )
		return _mainOverlayRenderer;

	return nil;
}


- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	if ([annotation isKindOfClass:[MKUserLocation class]])
	{
		return nil;
	}
	
	static NSString* myIdentifier = @"myIndentifier";
	MKPinAnnotationView* pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:myIdentifier];
    
	OVPlatformAnnotation* ovisAnnotation = (OVPlatformAnnotation *)annotation;
	
	if (!pinView)
	{
		pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:myIdentifier];
		pinView.pinTintColor = NSColor.systemGreenColor;
		pinView.animatesDrop = NO;
		pinView.draggable = [ovisAnnotation draggable];
		pinView.canShowCallout = YES;
		
		[pinView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
	}
	
	pinView.pinTintColor = ovisAnnotation.pinColor;
	
	return pinView;
}

- (void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView
								 didChangeDragState:(MKAnnotationViewDragState)newState
										 fromOldState:(MKAnnotationViewDragState)oldState
{
	if (newState == MKAnnotationViewDragStateStarting)
	{
		_isDraggingPin = YES;
		_draggingPinName = annotationView.annotation.title;
	}
	else if (newState == MKAnnotationViewDragStateEnding)
	{
		CLLocationCoordinate2D coord = annotationView.annotation.coordinate;
        
        [[_appDelegate ensembleData] updatePositionOfPlatformWithName:_draggingPinName toLat:coord.latitude lon:coord.longitude];

		
		//OVOffShorePlatform *platform = [_appDelegate.ensembleData getPlatformWithName:_draggingPinName];
		//[platform setLatitude:coord.latitude];
		//[platform setLongitude:coord.longitude];
		//NSLog(@"Drop Coordinate Lat = %f, Lon = %f", coord.latitude, coord.longitude);
		
		_isDraggingPin = NO;
		_draggingPinName = nil;
		
		[self refreshPlatformGUI];
	}
	else if (newState == MKAnnotationViewDragStateCanceling)
	{
		_isDraggingPin = NO;
		_draggingPinName = nil;
	}
	else if (newState == MKAnnotationViewDragStateNone)
	{
	}
}

- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)annotationView
{
	//NSLog(@"Selected %@", annotationView.annotation.title);
}

- (void) mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)annotationView
{
	//NSLog(@"Deselected %@", annotationView.annotation.title);
}

#pragma mark GUI

- (void) toggleProperties
{
	[verticalSpace2DViewBottom setConstant:100.0f-verticalSpace2DViewBottom.constant];
}

- (void) keyDown:(NSEvent *)event
{
	NSString *str = [event charactersIgnoringModifiers];
	unsigned char key = [str characterAtIndex:0];
	
	switch (key) {
		case 'r':
			[self setViewToMatchEnsemble:self];
			break;
		case 'c':
			[_mapview setMapType:MKMapTypeSatellite];
			break;
		case 'x':
			[_mapview setMapType:MKMapTypeHybrid];
			break;
		case 'z':
			[_mapview setMapType:MKMapTypeStandard];
			break;
		default:
			break;
	}
}

- (void) refreshPlatformGUI
{
	[activePlatformPopUp removeAllItems];
	
	NSMutableDictionary *platforms = [_appDelegate.ensembleData platforms];
	for(id key in platforms) {
		OVOffShorePlatform *p = [platforms objectForKey:key];
		NSString *name = [p name];
		[activePlatformPopUp addItemWithTitle:name];
	}
	OVOffShorePlatform *platform	= [_appDelegate.ensembleData getActivePlatform];
	[activePlatformPopUp selectItemWithTitle:platform.name];
	
	[self refreshLonLatGUI];
	
	[_appDelegate refreshGUIforView:ViewIdTS];
	[_appDelegate refreshViewFromData:ViewIdTS];
}

- (void) refreshLonLatGUI
{
	OVOffShorePlatform *platform	= [_appDelegate.ensembleData getActivePlatform];
	
	[latTextField setStringValue:[NSString stringWithFormat:@"%.6f", platform.latitude]];
	[lonTextField setStringValue:[NSString stringWithFormat:@"%.6f", platform.longitude]];
	
	[_appDelegate refreshViewFromData:ViewIdTS];
}

- (void) refreshCalloutForPinWithTitle: (NSString*) title
{
	OVOffShorePlatform *p = [_appDelegate.ensembleData getPlatformWithName:title];
	[p.annotation setSubtitle:[NSString stringWithFormat:@"Lat: %.3f, Lon: %.3f", p.latitude, p.longitude]];
}

#pragma mark Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	if ([keyPath isEqualToString:@"frame"] )
	{
		if([((MKAnnotationView *)object).annotation.title isEqualToString:_draggingPinName])
		{
			[self refreshCoordsFromPinWithTitle:_draggingPinName];
			[self refreshCalloutForPinWithTitle:_draggingPinName];
		}
	}
}

#pragma mark IBActions

-(IBAction) setViewToMatchEnsemble:(id)sender;
{
	[self performSelectorOnMainThread:@selector(reloadMap:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
}

- (IBAction) showAddPlatformPopOver:(id)sender
{
	[addPlatformPopover showRelativeToRect:[addPlatformButton bounds]
									ofView:addPlatformButton
							 preferredEdge:NSMinYEdge];
}

- (IBAction) cancelAddPlatform:(id)sender
{
	[addPlatformPopover close];
	[addPlatformNameTextField setStringValue:@""];
}

- (IBAction) addPlatform:(id)sender
{	
	NSString *name = [addPlatformNameTextField stringValue];
	if( [name isEqualToString:@""] ) name = @"Unnamed Platform";
	EnsembleLonLat *bounds = _appDelegate.ensembleData.ensembleLonLat;
	float lat = ( bounds->lat_max + bounds->lat_min ) * 0.5;
	float lon = ( bounds->lon_max + bounds->lon_min ) * 0.5;;
		
	CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, lon);

    OVOffShorePlatform* p = [_appDelegate.ensembleData addPlatformWithName:name lat:lat lon:lon];
    OVPlatformAnnotation* annotation = [[OVPlatformAnnotation alloc] initWithCoordinates:coordinate
                                                                                    Name:[p name]
                                                                             Description:[NSString stringWithFormat:@"Lat: %.3f, Lon: %.3f", lat, lon] Draggable:YES];
	
    [p setAnnotation:annotation];
    [_mapview addAnnotation:annotation];
	
	[self refreshPlatformGUI];
	[self refreshPins];
	
	[addPlatformPopover close];
	[addPlatformNameTextField setStringValue:@""];
}

- (IBAction) removePlatform:(id)sender
{
	NSString *itemName = [[activePlatformPopUp selectedItem] title];
	
	OVOffShorePlatform* p = [_appDelegate.ensembleData getPlatformWithName:itemName];
	OVPlatformAnnotation* annotation = p.annotation;
	
	[_mapview removeAnnotation:annotation];
	
	[_appDelegate.ensembleData removePlatformWithName:itemName];
	
	[self refreshPlatformGUI];
	[self refreshPins];
}

- (IBAction) selectPlatform:(id)sender
{
	NSString *itemName = nil;
	if([sender isKindOfClass:[NSButton class]] )
		itemName = [[sender selectedItem] title];
	else if ([sender isKindOfClass:[OVPlatformAnnotation class]] )
		itemName = [sender title];
		
	if( !itemName ) return;
		
	[_appDelegate.ensembleData setActvePlatformByName:itemName];
	
	[self refreshPlatformGUI];
	[self refreshPins];
}

- (IBAction) setLatitude:(id)sender
{
    [[_appDelegate ensembleData] updateLatitudeOfActivePlatformToLat:[sender floatValue]];
	
	[self refreshLonLatGUI];
    
	OVOffShorePlatform *platform	= [_appDelegate.ensembleData getActivePlatform];
	CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latTextField.floatValue, lonTextField.floatValue);
	[platform.annotation setCoordinate:coordinate];
}

- (IBAction) setLongitude:(id)sender
{
    [[_appDelegate ensembleData] updateLongitudeOfActivePlatformToLon:[sender floatValue]];
	
	[self refreshLonLatGUI];
	
	OVOffShorePlatform *platform	= [_appDelegate.ensembleData getActivePlatform];
	CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latTextField.floatValue, lonTextField.floatValue);
	[platform.annotation setCoordinate:coordinate];
}

#pragma mark popover delegate


@end
