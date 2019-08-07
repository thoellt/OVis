//
//	OVEnsembleData+Loader.mm
//

// Custom Headers
#import "netcdf.h"
#import "OVNCLoaderController.h"
#import "OVNetCDFLoader.h"
#import "OVOffShorePlatform.h"
#import "OVRawFilePresenter.h"
#import "OVVariable.h"
#import "OVVariable1D.h"
#import "OVVariable2D.h"

// Local Headers
#import "OVEnsembleData+Loader.h"
#import "OVEnsembleData+Pathlines.h"
#import "OVEnsembleData+Platforms.h"
#import "OVEnsembleData+Statistics.h"

@implementation OVEnsembleData (loader)

- (BOOL) openEnsembleFromOVisFile:(NSURL *)url
{
	NSURL *ovisFile = url;
	NSURL *sshRawFileUrl = nil;
	NSURL *uRawFileUrl = nil;
	NSURL *vRawFileUrl = nil;
	NSURL *gridFileUrl = nil;
	
	NSString *fileContents = [NSString stringWithContentsOfURL:ovisFile encoding:NSUTF8StringEncoding error:nil];
	
	NSArray *lines = [fileContents componentsSeparatedByString:@"\n"];
	
    NSString *variableName = @"Main Variable";
    NSString *variableUnit = @"";
    NSString *zVariableName = @"Z";
    NSString *zVariableUnit = @"";
	BOOL structured = YES;
    NSInteger versionMajor = 0;
    NSInteger versionMinor = 0;
	NSInteger dim_x = -1;
	NSInteger dim_y = -1;
	NSInteger dim_z = -1;
	NSInteger dim_t = -1;
	NSInteger dim_m = -1;
	float lon_min = 999.9f;
	float lon_max = 999.9f;
	float lat_min = 999.9f;
	float lat_max = 999.9f;
    float lon_off = 0.0f;
    float lat_off = 0.0f;
	int nodeCount = 0;
    int triangleCount = 0;
    
    NSDate *startDate = nil;
    NSDateComponents *timeStepLength = [[NSDateComponents alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
	
	for( int i = 0; i < [lines count]; i++ ){
		
		NSString *currentLine = [lines objectAtIndex:i];
		
		if ([currentLine rangeOfString:@"#"].location == 0) continue;

#ifdef DEBUG
		NSLog( @"%@", currentLine );
#endif // DEBUG
		
		NSMutableArray *items = [[currentLine componentsSeparatedByString:@" "] mutableCopy];
		
        if( [[items objectAtIndex:0] isEqualToString:@"_VERSION"] ){
            
            if( [items count] > 1 ){
                NSArray* version = [[items objectAtIndex:1] componentsSeparatedByString:@"."];
                assert( [version count] == 2 );
                versionMajor = [[version objectAtIndex:0] intValue];
                versionMinor = [[version objectAtIndex:1] intValue];
            }
        } else if( [[items objectAtIndex:0] isEqualToString:@"_STRUCTURED"] ){
			
			if( [items count] > 1 ){
				structured = [[items objectAtIndex:1] boolValue];
			}
			
		} else if( [[items objectAtIndex:0] isEqualToString:@"_VARIABLE"] ){
            
            if( [items count] > 1 ){
                [items removeObjectAtIndex:0];
                variableName = [items componentsJoinedByString:@" "];
            }
        } else if( [[items objectAtIndex:0] isEqualToString:@"_VARIABLE_UNIT"] ){
            
            if( [items count] > 1 ){
                [items removeObjectAtIndex:0];
                variableUnit = [items componentsJoinedByString:@" "];
            }
        } else if( [[items objectAtIndex:0] isEqualToString:@"_GRIDZ"] ){
            
            if( [items count] > 1 ){
                [items removeObjectAtIndex:0];
                zVariableName = [items componentsJoinedByString:@" "];
            }
        } else if( [[items objectAtIndex:0] isEqualToString:@"_GRIDZ_UNIT"] ){
            
            if( [items count] > 1 ){
                [items removeObjectAtIndex:0];
                zVariableUnit = [items componentsJoinedByString:@" "];
            }
        } else if( [[items objectAtIndex:0] isEqualToString:@"_FILENAME"] || [[items objectAtIndex:0] isEqualToString:@"_FILENAME_SSH"] ){
			
			if( [items count] > 1 ){
				NSString *urlString = [ovisFile absoluteString];
				NSRange ovisNameRange = [urlString rangeOfString:[ovisFile lastPathComponent] options:NSBackwardsSearch];
				
				if (ovisNameRange.location != NSNotFound) {
					// Chop the fragment.
					NSString *newURLString = [urlString substringToIndex:ovisNameRange.location];
					sshRawFileUrl = [NSURL URLWithString:[newURLString stringByAppendingString:[items objectAtIndex:1]]];
				} else {
					sshRawFileUrl = nil;
				}
			}
			
		} else if( [[items objectAtIndex:0] isEqualToString:@"_FILENAME_U"]){
			
			if( [items count] > 1 ){
				NSString *urlString = [ovisFile absoluteString];
				NSRange ovisNameRange = [urlString rangeOfString:[ovisFile lastPathComponent] options:NSBackwardsSearch];
				
				if (ovisNameRange.location != NSNotFound) {
					// Chop the fragment.
					NSString *newURLString = [urlString substringToIndex:ovisNameRange.location];
					uRawFileUrl = [NSURL URLWithString:[newURLString stringByAppendingString:[items objectAtIndex:1]]];
				} else {
					uRawFileUrl = nil;
				}
			}
			
		} else if( [[items objectAtIndex:0] isEqualToString:@"_FILENAME_V"]){
			
			if( [items count] > 1 ){
				NSString *urlString = [ovisFile absoluteString];
				NSRange ovisNameRange = [urlString rangeOfString:[ovisFile lastPathComponent] options:NSBackwardsSearch];
				
				if (ovisNameRange.location != NSNotFound) {
					// Chop the fragment.
					NSString *newURLString = [urlString substringToIndex:ovisNameRange.location];
					vRawFileUrl = [NSURL URLWithString:[newURLString stringByAppendingString:[items objectAtIndex:1]]];
				} else {
					vRawFileUrl = nil;
				}
			}
			
		} else if( [[items objectAtIndex:0] isEqualToString:@"_INVALID_VALUE"]){
			
			if( [items count] > 1 ){
				_invalidValue = [[items objectAtIndex:1] floatValue];
                _invalidAvailable = YES;
			}
			
		} else if( [[items objectAtIndex:0] isEqualToString:@"_DIMENSIONS"] ){
			
			if( structured && [items count] == 5 ){
				dim_x = [[items objectAtIndex:1] integerValue];
				dim_y = [[items objectAtIndex:2] integerValue];
				dim_z = 1;
				dim_m = [[items objectAtIndex:3] integerValue];
				dim_t = [[items objectAtIndex:4] integerValue];
			
			} else if( structured && [items count] == 6 ){
				dim_x = [[items objectAtIndex:1] integerValue];
				dim_y = [[items objectAtIndex:2] integerValue];
				dim_z = [[items objectAtIndex:3] integerValue];
				dim_m = [[items objectAtIndex:4] integerValue];
				dim_t = [[items objectAtIndex:5] integerValue];
			}
			
			if( !structured && [items count] > 2 ){
				dim_m = [[items objectAtIndex:1] integerValue];
				dim_t = [[items objectAtIndex:2] integerValue];
			}
			
        } else if( [[items objectAtIndex:0] isEqualToString:@"_STARTDATE"] ){
            
            if( [items count] > 2 ){
                [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
                startDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", [items objectAtIndex:1], [items objectAtIndex:2]]];
                
                //NSDateFormatter* outFormatter = [[NSDateFormatter alloc] init];
                //[outFormatter setDateFormat:@"d MMM yyyy HH:mm:ss"];
                //
                //NSLog(@"%@", [outFormatter stringFromDate:startDate]);
            }
        }  else if( [[items objectAtIndex:0] isEqualToString:@"_TIMESTEPLENGTH"] ){
            
            if( [items count] > 2 ){
                
                NSArray* tsmajor = [[items objectAtIndex:1] componentsSeparatedByString:@"/"];
                NSArray* tsminor = [[items objectAtIndex:2] componentsSeparatedByString:@":"];
                
                assert( [tsmajor count] == 3 );
                assert( [tsminor count] == 3 );
                
                [timeStepLength setYear:[[tsmajor objectAtIndex:0] intValue]];
                [timeStepLength setMonth:[[tsmajor objectAtIndex:1] intValue]];
                [timeStepLength setDay:[[tsmajor objectAtIndex:2] intValue]];
                
                [timeStepLength setHour:[[tsminor objectAtIndex:0] intValue]];
                [timeStepLength setMinute:[[tsminor objectAtIndex:1] intValue]];
                [timeStepLength setSecond:[[tsminor objectAtIndex:2] intValue]];
            }
        }  else if( [[items objectAtIndex:0] isEqualToString:@"_LONLAT"] ){
            
            if( [items count] > 4 ){
                lon_min = [[items objectAtIndex:1] floatValue];
                lon_max = [[items objectAtIndex:2] floatValue];
                lat_min = [[items objectAtIndex:3] floatValue];
                lat_max = [[items objectAtIndex:4] floatValue];
            }
        } else if( [[items objectAtIndex:0] isEqualToString:@"_OFFSET_LONLAT"] ){
			
			if( [items count] > 2 ){
				lon_off = [[items objectAtIndex:1] floatValue];
				lat_off = [[items objectAtIndex:2] floatValue];
			}
		} else if( [[items objectAtIndex:0] isEqualToString:@"_GRIDNAME"] ){
			
			if( [items count] > 1 ){
				NSString *urlString = [ovisFile absoluteString];
				NSRange ovisNameRange = [urlString rangeOfString:[ovisFile lastPathComponent] options:NSBackwardsSearch];
				
				if (ovisNameRange.location != NSNotFound) {
					// Chop the fragment.
					NSString *newURLString = [urlString substringToIndex:ovisNameRange.location];
					gridFileUrl = [NSURL URLWithString:[newURLString stringByAppendingString:[items objectAtIndex:1]]];
				} else {
					gridFileUrl = nil;
				}
			}
		} else if( [[items objectAtIndex:0] isEqualToString:@"_NODES"] ){
			
			if( [items count] > 1 ){
				nodeCount = [[items objectAtIndex:1] intValue];
			}
		} else if( [[items objectAtIndex:0] isEqualToString:@"_TRIANGLES"] ){
			
			if( [items count] > 1 ){
				triangleCount = [[items objectAtIndex:1] intValue];
			}
		}
	}
	
	if( versionMajor > 2 || ( versionMajor == 2 && versionMinor > 6 ) ){
		
		//NSLog( @"Fileversion = %ld.%ld. This version of Ovis only supports files up to version 2.6.\n ", versionMajor, versionMinor );
        [self fileOpenAlertWithText:[NSString stringWithFormat:@"Fileversion is %ld.%ld.\nThis version of Ovis only supports files up to v2.6. Please update your files.", versionMajor, versionMinor]];
		return NO;
	}
	
	if( versionMajor < 2 || ( versionMajor == 2 && versionMinor < 6 ) ){
		
        //NSLog( @"Fileversion = %ld.%ld. This version of Ovis only supports files greater or equal to version 2.6. Please update your files.\n ", versionMajor, versionMinor );
        [self fileOpenAlertWithText:[NSString stringWithFormat:@"Fileversion is %ld.%ld.\nThis version of Ovis only supports files greater or equal to version 2.6. Please update your files.", versionMajor, versionMinor]];
		return NO;
	}
	
	if( structured )
	{
		if( dim_x < 0 || dim_y < 0 || dim_z < 0 || dim_t < 0 || dim_m < 0 ){
		
            //NSLog( @"At least one of the file dimensions is not set. Make sure that all dimensions are defined.\n " );
            [self fileOpenAlertWithText:[NSString stringWithFormat:@"At least one of the file dimensions is not set. Make sure to specify the dimensions as '_DIMENSIONS x y z members timesteps' in %@.", [[ovisFile absoluteString] lastPathComponent]]];
			return NO;
		}
	
		if( lon_min > 180.0 || lon_max > 180.0 || lat_min > 180.0 || lat_max > 180.0 ||
            lon_min < -180.0 || lon_max < -180.0 || lat_min < -180.0 || lat_max < -180.0 ){
		
            //NSLog( @"At least one of the lat/lon dimensions is not set (correctly). Make sure that all dimensions are defined between -180.0 and 180.\n " );
            [self fileOpenAlertWithText:[NSString stringWithFormat:@"At least one of the lat/lon dimensions is not set (correctly). Make sure that all dimensions are defined between -180.0 and 180 after the _LONLAT keyword."]];
			return NO;
		}
	} else {
		
		if( dim_t < 0 || dim_m < 0 ){
			
            //NSLog( @"At least one of the file dimensions is not set. Make sure that all dimensions are defined.\n " );
            [self fileOpenAlertWithText:[NSString stringWithFormat:@"At least one of the file dimensions is not set. Make sure to specify the dimensions as '_DIMENSIONS members timesteps' in %@.", [[ovisFile absoluteString] lastPathComponent]]];
			return NO;
		}
		
		if( nodeCount <= 0 ){
			
            //NSLog( @"No nodes defined. Make sure that the number of nodes is greater than zero.\n " );
            [self fileOpenAlertWithText:[NSString stringWithFormat:@"No nodes defined. Make sure that the number of nodes is greater than zero and defined after the _NODES keyword in %@.", [[ovisFile absoluteString] lastPathComponent]]];
			return NO;
		}
		
		if( triangleCount <= 0 ){
			
            //NSLog( @"No triangles defined. Make sure that the number of triangles is greater than zero.\n " );
            [self fileOpenAlertWithText:[NSString stringWithFormat:@"No triangles defined. Make sure that the number of triangles is greater than zero and defined after the _TRIANGLES keyword in %@.", [[ovisFile absoluteString] lastPathComponent]]];
			return NO;
		}
		
		if( !gridFileUrl ){
			
            //NSLog( @"No gridfile given. Unstrucutred data requires a grid definition.\n " );
            gridFileUrl = [[ovisFile URLByDeletingPathExtension] URLByAppendingPathExtension:@"grid"];
            [self fileOpenAlertWithText:[NSString stringWithFormat:@"No gridfile defined. Assuming grid file to be %@.", [[gridFileUrl absoluteString] lastPathComponent]]];
			//return NO;
        }
        /*
        if( ![[[gridFileUrl absoluteString] stringByDeletingPathExtension] isEqualToString:[[gridFileUrl absoluteString] stringByDeletingPathExtension]]  ){
            
            //NSLog( @"No gridfile given. Unstrucutred data requires a grid definition.\n " );
            gridFileUrl = [[ovisFile URLByDeletingPathExtension] URLByAppendingPathExtension:@"grid"];
            [self fileOpenAlertWithText:[NSString stringWithFormat:@"No gridfile defined. Assuming grid file to be %@.", [[gridFileUrl absoluteString] lastPathComponent]]];
            //return NO;
        }
		*/
        dim_x = nodeCount;
        dim_y = 1;
        dim_z = 1;
	}
	
	if( !sshRawFileUrl ){
        
      sshRawFileUrl = [[ovisFile URLByDeletingPathExtension] URLByAppendingPathExtension:@"raw"];
      [self fileOpenAlertWithText:[NSString stringWithFormat:@"No raw data file defined. Assuming raw file to be %@.", [[sshRawFileUrl absoluteString] lastPathComponent]]];
      //NSLog( @"Data file is not specified. Make sure that raw file is defined.\n " );
	}

   // Register raw file for sandboxing
   [NSFileCoordinator addFilePresenter:[[OVRawFilePresenter alloc] initWithPrimaryURL: ovisFile secondaryURL: sshRawFileUrl]];
   // addFilePresenter is not synchronous so we call [NSFileCoordinator filePresenters] to make sure they exist
   [NSFileCoordinator filePresenters];
    
	NSData *nsdata = [NSData dataWithContentsOfURL:sshRawFileUrl];
   NSInteger fullSize = [nsdata length];
	
	NSInteger surfaceSize = structured ? dim_x * dim_y : nodeCount;
	NSInteger numberOfSurfaces = dim_t * dim_m;
	NSInteger size4D = surfaceSize * numberOfSurfaces;
	NSInteger size5D = size4D * dim_z;
    
    if( _variables2D )
    {
        [_variables2D removeAllObjects];
    } else {
        _variables2D = [[NSMutableArray alloc] init];
    }
    
    OVVariable2D* variable = [[OVVariable2D alloc] init];
    [_variables2D addObject:variable];
    
	 variable.data = new float[ size4D ];
    variable.name = variableName;
    variable.unit = variableUnit;
    [variable setDimensionsX: dim_x Y: dim_y Z: dim_z M: dim_m T: dim_t];
    
    if( !structured && _invalidAvailable )
    {
        assert( fullSize % sizeof(float) == 0 );
        float* tmp = new float[ fullSize/sizeof(float) ];
        
       [nsdata getBytes:tmp length:fullSize];

        assert( ( fullSize/sizeof(float) ) % ( dim_t * dim_m ) == 0 );
        // TODO this works only for structured and unstructured without invalids
        //  NSInteger memberSize = dim_x * dim_y * dim_z;//( fullSize/sizeof(float) ) / ( dim_t * dim_m );
        NSInteger memberSize = ( fullSize/sizeof(float) ) / ( dim_t * dim_m );
        
        int x = 0;
        for( int t = 0; t < dim_t; t++ )
        {
            for( int m = 0; m < dim_m; m++ )
            {
                for( int i = 0; i < memberSize; i++ )
                {
                    if( [self isValid:tmp[i]] )
                    {
                        assert( x < size4D );
                        variable.data[x++] = tmp[ t * dim_m * memberSize + m * memberSize + i ];
                    }
                }
            }
        }
        
        // TODO this works only for structured and unxtructured without invalids
        assert( x == size4D );
        
    } else {
    
        [nsdata getBytes:variable.data length:size4D*sizeof(float)];
    }
	
	if( uRawFileUrl ){
		if( _uData ){
			delete[] _uData;
			_uData = nil;
		}
		_uData = new float [ size4D ];
		float * tmpData = new float [ size5D ];
        
		nsdata = [NSData dataWithContentsOfURL:uRawFileUrl];
		[nsdata getBytes:tmpData length:size5D*sizeof(float)];
        
        for( int t = 0; t < dim_t; t++ )
        {
            for( int m = 0; m < dim_m; m++ )
            {
                for( int s = 0; s < surfaceSize; s++ )
                {
                    size_t newIdx = (size_t)s
                                  + (size_t)m * surfaceSize
                                  + (size_t)t * surfaceSize * dim_m;
                    
                    size_t oldIdx = (size_t)s
                                  + (size_t)m * surfaceSize * dim_z
                                  + (size_t)t * surfaceSize * dim_z * dim_m;
                    
                    _uData[ newIdx ] = tmpData[ oldIdx ];
                }
            }
        }
        
        delete[] tmpData;
	}
	
	if( vRawFileUrl ){
		if( _vData ){
			delete[] _vData;
			_vData = nil;
		}
		_vData = new float [ size4D ];
		float * tmpData = new float [ size5D ];
        
		nsdata = [NSData dataWithContentsOfURL:vRawFileUrl];
		[nsdata getBytes:tmpData length:size5D*sizeof(float)];
        
        for( int t = 0; t < dim_t; t++ )
        {
            for( int m = 0; m < dim_m; m++ )
            {
                for( int s = 0; s < surfaceSize; s++ )
                {
                    size_t newIdx = (size_t)s
                    + (size_t)m * surfaceSize
                    + (size_t)t * surfaceSize * dim_m;
                    
                    size_t oldIdx = (size_t)s
                    + (size_t)m * surfaceSize * dim_z
                    + (size_t)t * surfaceSize * dim_z * dim_m;
                    
                    _vData[ newIdx ] = tmpData[ oldIdx ];
                }
            }
        }
        
        delete[] tmpData;
	}
		
	[self setIsStructured: structured];
	
	if( structured )
	{
        [self createValidEntriesTableWithSize:surfaceSize];
		
        [self updateMetaDataForDimensionX: dim_x Y: dim_y Z: 1 T: dim_t M: dim_m];
        
        [self updateMetaDataForMinLat:lat_min +lat_off maxLat:lat_max +lat_off minLon:lon_min + lon_off maxLon:lon_max + lon_off];
        
        [self scanRangeForVariable: variable];
        //[self scanRangeForNumberOfSurfaces:numberOfSurfaces withSize:surfaceSize];
        
	} else {
        
        int clamped = 0;
		
		// scan min max
      variable.dataRange[0] = -9999.0f;
      variable.dataRange[1] = 9999.9f;
		for( int i = 0; i < size4D; i++ ){
			if( variable.data[i] < 9999.9f ){
                
                // FIXME: clamp
                if( variable.data[i] > 4.5f ){
                    variable.data[i] = 4.5f;
                    clamped++;
                }
                if( variable.data[i] < -4.5f ){
                    variable.data[i] = -4.5f;
                    clamped++;
                }
                
				variable.dataRange[0] = MAX(variable.data[i], variable.dataRange[0]);
				variable.dataRange[1] = MIN(variable.data[i], variable.dataRange[1]);
			}
		}
		
		NSLog(@"%f%% values > 4.5 were clamped.", clamped/(float)size4D*100);
		
		NSLog(@"%d valid Entries. Min Value is %f, Max Value is %f.", nodeCount, variable.dataRange[1], variable.dataRange[0]);
		
        // Register grid file for sandboxing
        [NSFileCoordinator addFilePresenter:[[OVRawFilePresenter alloc] initWithPrimaryURL: ovisFile secondaryURL: gridFileUrl]];
        [NSFileCoordinator filePresenters];
        
		// handle grid file
		NSString *gridFileContents = [NSString stringWithContentsOfURL:gridFileUrl encoding:NSUTF8StringEncoding error:nil];
		NSArray *gridLines = [gridFileContents componentsSeparatedByString:@"\n"];
		
#ifdef DEBUG
		NSLog(@"Loaded Unstructured GridFile with %ld lines, file description expects %d lines.", [gridLines count], nodeCount + triangleCount);
#endif // DEBUG
		
		// NODES
		if( _nodes ){
			delete[] _nodes;
			_nodes = nil;
		}
		_nodes = new float[ nodeCount * 2 ];
		memset(_nodes, 0, nodeCount * 2 * sizeof(float));
		
		// bathymetry
		float *bathymetrytmp = new float[ nodeCount ];
		memset(bathymetrytmp, 0, nodeCount * sizeof(float));
		
		float lat_min = 400; float lat_max = -400;
		float lon_min = 400; float lon_max = -400;
		float bat_min = 99999.9; float bat_max = -99999.9;
		
		int line = 0;
        int maxIdx = INT32_MIN; int minIdx = INT32_MAX;
        int* indices = new int[nodeCount];
		for( ; line < nodeCount; line++ )
		{
			//NSLog(@"%@", [gridLines objectAtIndex:line]);
			NSArray *tempItems = [[gridLines objectAtIndex:line] componentsSeparatedByString:@" "];
			NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:4];
			for( int i = 0; i < [tempItems count]; i++){
				//NSLog(@"item %d = \"%@\"",i, [tempItems objectAtIndex:i]);
				if(![[tempItems objectAtIndex:i] isEqualToString:@""]){
					[items addObject:[tempItems objectAtIndex:i]];
				}
			}
			assert([items count] == 4);
			
			// decrement indices of original value because matlab counts stats at 1
			int index = [items[0] intValue];
            indices[line] = index;
            
            if( index > maxIdx ) maxIdx = index;
            if( index < minIdx ) minIdx = index;
			//assert(index - 1 == line);
			
			float lon = [items[1] floatValue];
			float lat = [items[2] floatValue];
			
			if( lat > lat_max ) lat_max = lat;
			if( lat < lat_min ) lat_min = lat;
			if( lon > lon_max ) lon_max = lon;
			if( lon < lon_min ) lon_min = lon;
			
			_nodes[ 2 * line	 ] = lon;
			_nodes[ 2 * line + 1 ] = lat;
			
			// bathymetry
			float bat = [items[3] floatValue];
			bathymetrytmp[ line ] = bat;
			if( bat > bat_max ) bat_max = bat;
			if( bat < bat_min ) bat_min = bat;
		}
        
        // hashtable
        int numIndices = maxIdx - minIdx + 1;
        int* hash = new int [numIndices];
        memset(hash, 0, numIndices*sizeof(int));
        for( int i = 0; i < nodeCount; i++ )
        {
            int index = indices[i] - minIdx;
            hash[index] = i;
        }
        
		
		if( _gridIndices ){
			delete[] _gridIndices;
			_gridIndices = nil;
		}
		_gridIndices = new unsigned int[ triangleCount * 3 ];
		memset(_gridIndices, 0, triangleCount * 3 * sizeof(unsigned int));
		
		// TRIANGLES
		for( int triangle = 0; triangle < triangleCount; triangle++, line++ )
		{
			//NSLog(@"%@", [gridLines objectAtIndex:line]);
			NSArray *tempItems = [[gridLines objectAtIndex:line] componentsSeparatedByString:@" "];
			NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:5];
			for( int i = 0; i < [tempItems count]; i++){
				//NSLog(@"item %d = \"%@\"",i, [tempItems objectAtIndex:i]);
				if(![[tempItems objectAtIndex:i] isEqualToString:@""]){
					[items addObject:[tempItems objectAtIndex:i]];
				}
			}
			assert([items count] == 5);
			
			// decrement indices of original value because matlab counts stats at 1
			int index = [items[0] intValue] - 1;
			assert(index == triangle);
			
			// can't handle anything but triangles right now
			assert( [items[1] intValue] == 3 );
			
			_gridIndices[ 3 * index	 ] = hash[[items[2] unsignedIntValue]-minIdx];
			_gridIndices[ 3 * index + 1 ] = hash[[items[3] unsignedIntValue]-minIdx];
			_gridIndices[ 3 * index + 2 ] = hash[[items[4] unsignedIntValue]-minIdx];
			
			//NSLog(@"%d 3 %d %d %d",index, gridIndices[ 3 * index + 0 ], gridIndices[ 3 * index + 1 ], gridIndices[ 3 * index + 2 ] );
		}
        
        delete[] indices;
        delete[] hash;
		
		// STATISTICS
		_numNodes = nodeCount;
		_numTriangles = triangleCount;
		_ensembleDimension->x = nodeCount;
		_ensembleDimension->y = 1;
		_ensembleDimension->t = dim_t;
		_ensembleDimension->m = dim_m;
		_ensembleDimension->size = nodeCount * dim_t * dim_m;
		
		if( !_isStructured )
		{
			float sqr = sqrtf((float)nodeCount);
			if( sqr - (int)sqr != 0.0 ) sqr += 1.0;
			
			int texEdgeSize = (int)sqr;
			
			_ensembleDimension->texX = texEdgeSize;
			_ensembleDimension->texY = texEdgeSize;
			
			// resize and scale bathymetry
			float batScale = 1.0 / (bat_max - bat_min);
            
            OVVariable2D* zVar = [[OVVariable2D alloc] init];
            
            zVar.data = new float[ texEdgeSize * texEdgeSize ];
			memset(zVar.data, 0, texEdgeSize * texEdgeSize * sizeof(float));
			for( int i = 0; i < _numNodes; i++ )
			{
                // TODO VAR to flip or not to flip
				zVar.data[i] = /*-*/(bathymetrytmp[i] - bat_min) * batScale;
			}
            
            zVar.name = zVariableName;
            zVar.unit = zVariableUnit;
            
            [zVar setDimensionsX: nodeCount Y: 1 Z: 1 M: 1 T: 1];
            [zVar scanRange];
            
            [_variables2D addObject:zVar];
			
			delete[] bathymetrytmp;
		}
		
		_memberRangeMax = (int)dim_m - 1;
		_timeRangeMax = (int)dim_t - 1;
        
        [self updateMetaDataForMinLat: lat_min maxLat: lat_max minLon: lon_min maxLon: lon_max];

		NSLog(@"_LONLAT %f %f %f %f", lon_min, lon_max, lat_min, lat_max);
	}
    
    _startDate = startDate;
    _timeStepLength = timeStepLength;
	
	_isVectorFieldAvailable = ( _uData && _vData );
    
    return YES;
}

- (void) importDataFromOvaFiles:(NSArray *)urls
{
    for( NSURL* ovaFile in urls )
    {
        #ifdef DEBUG
            NSLog( @"%@", [ovaFile absoluteString] );
        #endif // DEBUG
        
        NSInteger version_major = 0;
        NSInteger version_minor = 0;
        
        NSString* type;
        
        BOOL structured = YES;
        
        NSString* name = @"";
        NSString* variableName = @"Variable";
        NSString* variableUnit = @"";
        
        NSURL *rawFileUrl = nil;
        
        float invalidValue = -99999.9;
        BOOL invalidAvailable = NO;
        
        NSInteger dim_x = -1;
        NSInteger dim_y = -1;
        NSInteger dim_z = -1;
        NSInteger dim_t = -1;
        NSInteger dim_m = -1;
        
        BOOL isTStatic = NO;
        BOOL isMStatic = NO;
        
        Vector2 position;
        position.x = 999.9f;
        position.y = 999.9f;
        
        float lon_off = 0.0f;
        float lat_off = 0.0f;
        
        NSString *fileContents = [NSString stringWithContentsOfURL:ovaFile encoding:NSUTF8StringEncoding error:nil];

        NSArray *lines = [fileContents componentsSeparatedByString:@"\n"];
        
        for( NSString* currentLine in lines )
        {
            if ([currentLine rangeOfString:@"#"].location == 0) continue;
            
            #ifdef DEBUG
                NSLog( @"%@", currentLine );
            #endif // DEBUG
            
            NSMutableArray *items = [[currentLine componentsSeparatedByString:@" "] mutableCopy];
            
            if( [[items objectAtIndex:0] isEqualToString:@"_VERSION"] ){
                
                if( [items count] > 1 ){
                    NSArray* version = [[items objectAtIndex:1] componentsSeparatedByString:@"."];
                    assert( [version count] == 2 );
                    version_major = [[version objectAtIndex:0] intValue];
                    version_minor = [[version objectAtIndex:1] intValue];
                }
            } else if( [[items objectAtIndex:0] isEqualToString:@"_TYPE"] ){
                
                if( [items count] > 1 ){
                    type = [items objectAtIndex:1];
                }
            } else if( [[items objectAtIndex:0] isEqualToString:@"_STRUCTURED"] ){
                
                if( [items count] > 1 ){
                    structured = [[items objectAtIndex:1] boolValue];
                }
                
            } else if( [[items objectAtIndex:0] isEqualToString:@"_NAME"] ){
                
                if( [items count] > 1 ){
                    name = [items objectAtIndex:1];
                }
            } else if( [[items objectAtIndex:0] isEqualToString:@"_VARIABLE"] ){
                
                if( [items count] > 1 ){
                    [items removeObjectAtIndex:0];
                    variableName = [items componentsJoinedByString:@" "];
                }
            } else if( [[items objectAtIndex:0] isEqualToString:@"_VARIABLE_UNIT"] ){
                
                if( [items count] > 1 ){
                    variableUnit = [items objectAtIndex:1];
                }
            } else if( [[items objectAtIndex:0] isEqualToString:@"_FILENAME"] ){
                
                if( [items count] > 1 ){
                    NSString *urlString = [ovaFile absoluteString];
                    NSRange ovisNameRange = [urlString rangeOfString:[ovaFile lastPathComponent] options:NSBackwardsSearch];
                    
                    if (ovisNameRange.location != NSNotFound) {
                        // Chop the fragment.
                        NSString *newURLString = [urlString substringToIndex:ovisNameRange.location];
                        rawFileUrl = [NSURL URLWithString:[newURLString stringByAppendingString:[items objectAtIndex:1]]];
                    } else {
                        rawFileUrl = nil;
                    }
                }
            } else if( [[items objectAtIndex:0] isEqualToString:@"_INVALID_VALUE"]){
                
                if( [items count] > 1 ){
                    invalidValue = [[items objectAtIndex:1] floatValue];
                    invalidAvailable = YES;
                }
                
            } else if( [[items objectAtIndex:0] isEqualToString:@"_DIMENSIONS"] ){
                
                if( [items count] == 3 ){
                    dim_x = 1;
                    dim_y = 1;
                    dim_z = 1;
                    dim_m = [[items objectAtIndex:1] integerValue];
                    dim_t = [[items objectAtIndex:2] integerValue];
                    
                } else if( [items count] == 5 ){
                    dim_x = [[items objectAtIndex:1] integerValue];
                    dim_y = [[items objectAtIndex:2] integerValue];
                    dim_z = 1;
                    dim_m = [[items objectAtIndex:3] integerValue];
                    dim_t = [[items objectAtIndex:4] integerValue];
                
                } else if( [items count] == 6 ){
                    dim_x = [[items objectAtIndex:1] integerValue];
                    dim_y = [[items objectAtIndex:2] integerValue];
                    dim_z = [[items objectAtIndex:3] integerValue];
                    dim_m = [[items objectAtIndex:4] integerValue];
                    dim_t = [[items objectAtIndex:5] integerValue];
                }
                
                isTStatic = ( dim_t == 1 );
                isMStatic = ( dim_m == 1 );
                
            } else if( [[items objectAtIndex:0] isEqualToString:@"_POSITION_LONLAT"] ){
                
                if( [items count] > 2 ){
                    position.x = [[items objectAtIndex:1] floatValue];
                    position.y = [[items objectAtIndex:2] floatValue];
                }
            } else if( [[items objectAtIndex:0] isEqualToString:@"_OFFSET_LONLAT"] ){
                
                if( [items count] > 2 ){
                    lon_off = [[items objectAtIndex:1] floatValue];
                    lat_off = [[items objectAtIndex:2] floatValue];
                }
            }
        }
        
        position.x += lon_off;
        position.y += lat_off;
        
        // Sanity Check
        if( version_major > 1 || ( version_major == 1 && version_minor > 5 ) ){
            
            NSLog( @"Fileversion = %ld.%ld. This version of Ovis only supports ova files up to version 1.5.\n ", version_major, version_minor );
            return;
        }
        
        if( version_major < 1 || ( version_major == 1 && version_minor < 5 ) ){
            
            NSLog( @"Fileversion = %ld.%ld. This version of Ovis only supports files greater or equal to version 1.5. Please update your files.\n ", version_major, version_minor );
            return;
        }
        
        if( rawFileUrl && ( dim_x < 0 || dim_y < 0 || dim_z < 0 || dim_t < 0 || dim_m < 0 ) ){
            
			NSLog( @"At least one of the file dimensions is not set. Make sure that all dimensions are defined.\n " );
			return;
		}
        
		if( [type isEqualToString:@"well"] && (position.x > 180.0 || position.y > 90.0 || position.x < -180.0 || position.y < -90.0) ){
            
			NSLog( @"At least one of the lat/lon dimensions is not set (correctly). Make sure that all dimensions are defined between -180.0 and 180.\n " );
			return;
		}
        
        if( ![type isEqualToString:@"well"] && ![type isEqualToString:@"field"] ){
            
            NSLog( @"Data kind is unknown.\n " );
            return;
        }
        
        NSData *nsdata = nil;
        if( rawFileUrl )
        {
            // Register raw file for sandboxing
            [NSFileCoordinator addFilePresenter:[[OVRawFilePresenter alloc] initWithPrimaryURL: ovaFile secondaryURL: rawFileUrl]];
            // addFilePresenter is not synchronous so we call [NSFileCoordinator filePresenters] to make sure they exist
            [NSFileCoordinator filePresenters];
            
            NSError *error = nil;
            nsdata = [NSData dataWithContentsOfURL:rawFileUrl
                                                   options:NSDataReadingUncached
                                                     error:&error];
            
            if( error )
            {
                NSLog( @"%@", error );
                return;
            }
        }
    
        if( [type isEqualToString:@"well"] )
        {
            
            OVVariable1D* variable = nil;
            // only create variable data if raw data file is attached
            if( rawFileUrl )
            {
                assert( dim_m == _ensembleDimension->m );
                assert( dim_t == _ensembleDimension->t );
                
                NSInteger size = dim_m * dim_t;
                
                variable = [[OVVariable1D alloc] init];
                [_variables1D addObject: variable];
                
                variable.data = new float[size];
                [nsdata getBytes:variable.data length:size * sizeof(float)];
                
                variable.name = variableName;
                variable.unit = variableUnit;
                
                variable.position = position;
                variable.identifier = name;
                
                [variable setDimensionsX:1 Y:1 Z:1 M:dim_m T:dim_t];
                [variable scanRange];
            }
            
            OVOffShorePlatform* platform = [self getPlatformWithName:name];
            // If well with this name already exists add this variable
            if( variable && platform && platform.longitude == position.x && platform.latitude == position.y )
            {
                [platform addVariable:variable];
            }
            else
            {
                [self addPlatformWithName:name lat:position.y lon:position.x fixed:YES variable:variable];
            }
        }
        
        if( [type isEqualToString:@"field"] )
        {
            if( structured != _isStructured )
            {
                NSLog( @"Data not compatible with currently loaded ensemble.\n " );
                return;
            }
            
            if( !rawFileUrl ){
                
                NSLog( @"Data file is not specified correctly. Make sure that raw file is defined.\n " );
                return;
            }
            
            NSInteger dataSize = [nsdata length];
            
            NSInteger ensembleSize = _ensembleDimension->x * _ensembleDimension->y * ( isMStatic ? 1 : _ensembleDimension->m ) * ( isTStatic ? 1 : _ensembleDimension->t );
            
            
            OVVariable2D* variable = [[OVVariable2D alloc] init];
            [_variables2D addObject:variable];
            
            variable.data = new float[ensembleSize];
            if( !_isStructured )
            {
                assert( dim_x == 1 );
                assert( dim_y == 1 );
                assert( dim_z == 1 );
                assert( isMStatic || dim_m == _ensembleDimension->m );
                assert( isTStatic || dim_t == _ensembleDimension->t );
                
                if( !structured && invalidAvailable )
                {
                    assert( dataSize % sizeof(float) == 0 );
                    float* tmp = new float[ dataSize/sizeof(float) ];
                    
                    [nsdata getBytes:tmp];
                    
                    assert( ( dataSize/sizeof(float) ) % ( dim_t * dim_m ) == 0 );
                    NSInteger memberSize = ( dataSize/sizeof(float) ) / ( dim_t * dim_m );
                    
                    int x = 0;
                    for( int t = 0; t < dim_t; t++ )
                    {
                        for( int m = 0; m < dim_m; m++ )
                        {
                            for( int i = 0; i < memberSize; i++ )
                            {
                                if( [self isValid:tmp[i]] )
                                {
                                    assert( x < ensembleSize );
                                    variable.data[x++] = tmp[ t * dim_m * memberSize + m * memberSize + i ];
                                }
                            }
                        }
                    }
                    assert( x == ensembleSize );
                    
                } else {
                    
                    assert( ensembleSize*sizeof(float) == dataSize );
                    [nsdata getBytes:variable.data length:ensembleSize*sizeof(float)];
                }
            }
            
            variable.name = variableName;
            [variable setDimensionsX: _ensembleDimension->x Y: _ensembleDimension->y Z: dim_z M: dim_m T: dim_t];
            
            [self scanRangeForVariable:variable];
            
            [_appDelegate.ensembleData initRangesForVariable:variable];
            [_appDelegate.ensembleData updateStatisticsForVariable:variable];
        }
    }
}

// Usable AlmostEqual function
- (BOOL) isValid: (float) A
{
    if( A == _invalidValue ) return NO;
    
    //NSLog(@"Invalid: %f, Value: %f.", A, _invalidValue );
    
    int maxUlps = 5;
    
    int aInt = *(int*)&A;
    // Make aInt lexicographically ordered as a twos-complement int
    if (aInt < 0)
        aInt = 0x80000000 - aInt;
    
    // Make bInt lexicographically ordered as a twos-complement int
    int bInt = *(int*)&_invalidValue;
    if (bInt < 0)
        bInt = 0x80000000 - bInt;
    
    //NSLog(@"Invalid: %d, Value: %d.", aInt, bInt );
    
    int intDiff = abs(aInt - bInt);
    
    //NSLog(@"Diff: %d.", intDiff );
    
    if (intDiff <= maxUlps)
        return NO;
    
    return YES;
}

- (void) createValidEntriesTableWithSize: (size_t) size
{
    assert( [self isStructured] );
    
    if( _validEntries ){
        delete[] _validEntries;
        _validEntries = nil;
    }
    _validEntries = new BOOL[ size ];
    memset(_validEntries, 0, size*sizeof(BOOL));
    
    OVVariable2D* variable = _variables2D[0];
    
    _numberValids = 0;
    for( int i = 0; i < size; i++ ){
        if( [self isValid:variable.data[i]] ){
            _numberValids++;
            _validEntries[i] = YES;
        } else {
            _validEntries[i] = NO;
        }
    }
}

- (void) scanRangeForVariable:(OVVariable2D*) variable
{
    assert( !_isStructured || _validEntries );
    
    size_t surfaceSize = _ensembleDimension->x * _ensembleDimension->y;
    size_t numberOfSurfaces = ( variable.isTimeStatic ? 1 : _ensembleDimension->t ) *  ( variable.isMemberStatic ? 1 : _ensembleDimension->m );
    
   variable.dataRange[0] = -99999.9f;
   variable.dataRange[1] = 99999.9f;
    for( int i = 0; i < surfaceSize; i++ ){
        if( !_isStructured || _validEntries[i] ){
            for( int j = 0; j < numberOfSurfaces; j++ ){
                
                if( [self isValid:variable.data[i + j * surfaceSize]] ){
                    variable.dataRange[0] = MAX(variable.data[i + j * surfaceSize], variable.dataRange[0]);
                    variable.dataRange[1] = MIN(variable.data[i + j * surfaceSize], variable.dataRange[1]);
                } else {
                    //NSLog(@"invalid value found at %d, %d.", i, j);
                }
            }
        }
    }
    NSLog(@"Min Value is %f, Max Value is %f.", variable.dataRange[1], variable.dataRange[0]);
}

- (void) updateMetaDataForDimensionX: (size_t)dimX Y: (size_t)dimY Z: (size_t)dimZ T: (size_t)dimT M: (size_t)dimM
{
    _ensembleDimension->x = dimX;
    _ensembleDimension->y = dimY;
    _ensembleDimension->z = dimZ;
    _ensembleDimension->t = dimT;
    _ensembleDimension->m = dimM;
    _ensembleDimension->size = dimX * dimY * dimZ * dimT * dimM;
    
    _memberRangeMax = (int)dimM - 1;
    _timeRangeMax = (int)dimT - 1;
}

- (void) updateMetaDataForMinLat: (float)minLat maxLat: (float)maxLat minLon: (float)minLon maxLon: (float)maxLon
{
    _ensembleLonLat->lon_min = minLon;
    _ensembleLonLat->lon_max = maxLon;
    _ensembleLonLat->lat_min = minLat;
    _ensembleLonLat->lat_max = maxLat;
}

#pragma mark NSAlert

- (void) fileOpenAlertWithText: (NSString*) text
{
    NSAlert *alert = [[NSAlert alloc] init];
    
    [alert setMessageText:@"Error loading Ovis File."];
    [alert addButtonWithTitle:@"OK"];
    [alert setInformativeText:text];
    
    [alert runModal];
}


#pragma mark NSFilePresenter Protocoll



@end
