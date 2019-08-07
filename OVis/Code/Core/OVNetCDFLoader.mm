//
//  OVNetCDFLoader.m
//  OVis
//
//  Created by Thomas Höllt on 27/10/13.
//  Copyright (c) 2013 Thomas Höllt. All rights reserved.
//

// Custom Headers
#import "OVAppDelegateProtocol.h"
#import "OVEnsembleData.h"
#import "OVEnsembleData+Loader.h"
#import "OVEnsembleData+Statistics.h"
#import "OVVariable2D.h"

// Local Header
#import "OVNetCDFLoader.h"

@implementation OVNetCDFLoader

@synthesize dimensions = _dimensions;
@synthesize sshVariableId = _sshVariableId;
@synthesize uVariableId = _uVariableId;
@synthesize vVariableId = _vVariableId;
@synthesize isFlowEnabled = _isFlowEnabled;
@synthesize invalidValue = _invalidValue;
@synthesize lowerBounds = _lowerBounds;
@synthesize upperBounds = _upperBounds;
@synthesize fullDataUpper = _fullDataUpper;
@synthesize xDimName = _xDimName;
@synthesize yDimName = _yDimName;
@synthesize isTFromFileList = _isTFromFileList;


NSString* _typeNames[13] = {
    @"NC_NAT - Not A Type",
    @"NC_BYTE - signed 1 byte integer",
    @"NC_CHAR - ISO/ASCII character",
    @"NC_SHORT - signed 2 byte integer",
    @"NC_INT/NC_LONG - signed 4 byte integer",
    @"NC_FLOAT - single precision floating point number",
    @"NC_DOUBLE - double precision floating point number",
    @"NC_UBYTE - unsigned 1 byte int",
    @"NC_USHORT - unsigned 2 byte int",
    @"NC_UINT - unsigned 4 byte int",
    @"NC_INT64 - signed 8-byte int",
    @"NC_UINT64 - unsigned 8-byte int",
    @"NC_STRING - string",
};

- (id) init
{
    return [self initWithFileList:nil];
}

- (id) initWithFileList: (NSArray *) list
{
    self = [super init];
    
    if( !self ) return nil;
    
    _fileList = list;
    _file = nil;
    _ncdHandle = 0;
    
    _numDimensions = 0;
    _numVariables = 0;
    _numAttributes = 0;
    _unlimitedDimension = 0;
    
    _dimensions = [[NSMutableArray alloc] init];
    _variables = [[NSMutableArray alloc] init];
    
    _sshVariableId = 0;
    
    _isFlowEnabled = NO;
    _uVariableId = 0;
    _vVariableId = 0;
    
    _invalidValue = 0.0;
    
    _lowerBounds = {.x = 0, .y = 0, .z = 0, .m = 0, .t = 0 };
    _upperBounds = {.x = 0, .y = 0, .z = 0, .m = 0, .t = 0 };
    _fullDataUpper = {.x = 0, .y = 0, .z = 0, .m = 0, .t = 0 };
       
    [self openFile:[_fileList firstObject]];
    
    return self;
}

- (int) createNcdHandle: (NSURL*) file
{
    int handle = -1;
    
    NSString* fileName = [file path];
    _file = [fileName cStringUsingEncoding:NSUTF8StringEncoding];
    
    int success = nc_open (_file, NC_NOWRITE, &handle);
    
    if( success != NC_NOERR )
    {
        _file = nil;
        _ncdHandle = 0;
        NSLog(@"An error occured opening %@. Error code: %d", fileName, success);
        return -1;
    }
    
    return handle;
}

- (void) openFile: (NSURL*) file
{
    if( file == nil ) return;
    
    _ncdHandle = [self createNcdHandle:file];
    
    nc_inq(_ncdHandle, &_numDimensions, &_numVariables, &_numAttributes, &_unlimitedDimension);
    
    NSLog( @"Dataset contains %d dimensions, %d variables, %d attributes and unlimited dimension is %d",
          _numDimensions, _numVariables, _numAttributes, _unlimitedDimension );
    
    [self scanMetaData];
    [self readVariables];
    [self readDimensions];
}

- (void) closeFile
{
    nc_close(_ncdHandle);
}

- (void) scanMetaData
{
    char **names = new char*[_numDimensions];
    size_t *dimSizes = new size_t[_numDimensions];
    for( int dimension = 0; dimension < _numDimensions; dimension++ )
    {
        names[dimension] = new char[NC_MAX_NAME + 1];
        memset(names[dimension], 0, sizeof(char)*(NC_MAX_NAME + 1));
        int success = nc_inq_dim( _ncdHandle, dimension, names[dimension], &dimSizes[dimension] );
        
        if( success != NC_NOERR ){
            NSLog( @"Error reading Dimension %d, Error Code %d.", dimension, success );
            continue;
        }
        
        NSLog( @"Dimension %d is %s. Size is %ld", dimension, names[dimension], dimSizes[dimension] );
    }
    NSLog( @" " ); NSLog( @" " );
    
    for( int variable = 0; variable < _numVariables; variable++ )
    {
        netCDFVariable ncdVar;
        ncdVar.id = variable;
        
		int success = nc_inq_var( _ncdHandle, variable, ncdVar.name, &ncdVar.type, &ncdVar.numDimensions, ncdVar.dimensionIDs, &ncdVar.numAttributes );
        
        if( success != NC_NOERR ){
            NSLog( @"Error reading Variable %d, Error Code %d.", variable, success );
            continue;
        }
        
        NSLog( @"Variable %d is %s. Consisting of %d Attributes and %d Dimensions. It is of type %@", variable, ncdVar.name, ncdVar.numAttributes, ncdVar.numDimensions, _typeNames[ncdVar.type] );
        NSLog( @" " );
        
        if( ncdVar.numDimensions > 0 )
        {
            NSString *dimensions = [NSString stringWithFormat:@"Dimensions are %s", names[ncdVar.dimensionIDs[0]]];
            for( int d = 1; d < ncdVar.numDimensions; d++ ){
                NSString *dName = [NSString stringWithFormat:@", %s", names[ncdVar.dimensionIDs[d]]];
                dimensions = [dimensions stringByAppendingString:dName];
            }
            NSLog( @"%@.", dimensions );
        }
        
        NSLog( @"Attributes are:" );
        char **attNames = new char*[ncdVar.numAttributes];
        nc_type *attTypes = new nc_type[ncdVar.numAttributes];
        size_t *attSizes = new size_t[ncdVar.numAttributes];
        for( int attribute = 0; attribute < ncdVar.numAttributes; attribute++ )
        {
            attNames[attribute] = new char[ NC_MAX_NAME + 1];
            memset(attNames[attribute], 0, sizeof(char)*(NC_MAX_NAME + 1));
            success = nc_inq_attname(_ncdHandle, variable, attribute, attNames[attribute]);
            if( success != NC_NOERR ){
                NSLog( @"Error accessing Attribute Name %d, Error Code %d.", attribute, success );
                continue;
            }
            
            success =  nc_inq_att( _ncdHandle, variable, attNames[attribute], &attTypes[attribute], &attSizes[attribute]);
            if( success != NC_NOERR ){
                NSLog( @"Error accessing Attribute %s, Error Code %d.", attNames[attribute], success );
                continue;
            }
            
            NSLog( @"Attribute %d is %s. It is of type %@ and size %ld.", attribute, attNames[attribute], _typeNames[attTypes[attribute]], attSizes[attribute] );
            
            if( attTypes[attribute] == NC_CHAR )
            {
                char *attValue = new char[attSizes[attribute]];
                memset(attValue, 0, sizeof(char)*attSizes[attribute]);
                success =  nc_get_att_text(_ncdHandle, variable, attNames[attribute], attValue);
                if( success != NC_NOERR ){
                    NSLog( @"Error reading Attribute %s, Error Code %d.", attNames[attribute], success );
                    continue;
                }
                NSLog( @"Value of %s is: %s.", attNames[attribute], attValue );
                delete[] attValue;
            }
            else if( attTypes[attribute] == NC_FLOAT )
            {
                float *attValue = new float[attSizes[attribute]];
                success =  nc_get_att_float(_ncdHandle, variable, attNames[attribute], attValue);
                if( success != NC_NOERR ){
                    NSLog( @"Error reading Attribute %s, Error Code %d.", attNames[attribute], success );
                    continue;
                }
                NSString *valuesAsString = [NSString stringWithFormat:@"[%f", attValue[0]];
                for( int i = 1; i < attSizes[attribute]; i++)
                {
                    NSString *tempName = [NSString stringWithFormat:@", %f", attValue[i]];
                    valuesAsString = [valuesAsString stringByAppendingString:tempName];
                }
                NSLog( @"Value of %s is: %@].", attNames[attribute], valuesAsString );
                delete[] attValue;
            }
            else if( attTypes[attribute] == NC_DOUBLE )
            {
                double *attValue = new double[attSizes[attribute]];
                success =  nc_get_att_double(_ncdHandle, variable, attNames[attribute], attValue);
                if( success != NC_NOERR ){
                    NSLog( @"Error reading Attribute %s, Error Code %d.", attNames[attribute], success );
                    continue;
                }
                NSString *valuesAsString = [NSString stringWithFormat:@"[%f", attValue[0]];
                for( int i = 1; i < attSizes[attribute]; i++)
                {
                    NSString *tempName = [NSString stringWithFormat:@", %f", attValue[i]];
                    valuesAsString = [valuesAsString stringByAppendingString:tempName];
                }
                NSLog( @"Value of %s is: %@].", attNames[attribute], valuesAsString );
                delete[] attValue;
            }
            else if( attTypes[attribute] == NC_INT || attTypes[attribute] == NC_LONG )
            {
                int *attValue = new int[attSizes[attribute]];
                success =  nc_get_att_int(_ncdHandle, variable, attNames[attribute], attValue);
                if( success != NC_NOERR ){
                    NSLog( @"Error reading Attribute %s, Error Code %d.", attNames[attribute], success );
                    continue;
                }
                NSString *valuesAsString = [NSString stringWithFormat:@"[%d", attValue[0]];
                for( int i = 1; i < attSizes[attribute]; i++)
                {
                    NSString *tempName = [NSString stringWithFormat:@", %d", attValue[i]];
                    valuesAsString = [valuesAsString stringByAppendingString:tempName];
                }
                NSLog( @"Value of %s is: %@].", attNames[attribute], valuesAsString );
                delete[] attValue;
            }
        }
        
        // cleanup
        for( int a = 0; a < ncdVar.numAttributes; a++ )
            delete[] attNames[a];
        delete [] attNames;
        delete [] attTypes;
        delete [] attSizes;
        
         NSLog( @" " );NSLog( @" " );
    }
    
    // cleanup
    for( int d = 0; d < _numDimensions; d++ )
        delete[] names[d];
    delete [] names;
    delete [] dimSizes;
}

- (void) readDimensions
{
    assert( _ncdHandle );
    
	for( int dimension = 0; dimension < _numDimensions; dimension++ )
    {
        netCDFDimension ncdDim;
        ncdDim.id = dimension;
        
		int success = nc_inq_dim( _ncdHandle, dimension, ncdDim.name, &ncdDim.size );
        
        if( success != NC_NOERR ){
            NSLog( @"Error reading Dimension %d.", dimension );
            continue;
        }
        
        NSLog( @"Dimension %d is %s. Size is %ld", dimension, ncdDim.name, ncdDim.size );
        
        memcpy(ncdDim.longName, ncdDim.name, sizeof(char)*(NC_MAX_NAME + 1));
        
        // try to find long names in matching variables
        NSString *name = [NSString stringWithFormat:@"%s", ncdDim.name];
        
        // scan for long name in variables
        for( int i = 0; i < [_variables count]; i++ )
        {
            netCDFVariable ncdVar;
            [[_variables objectAtIndex:i] getValue:&ncdVar];
            
            NSString *varName = [NSString stringWithFormat:@"%s", ncdVar.name];
            
            if( [varName isEqualToString:name] )
            {
                memcpy(ncdDim.longName, ncdVar.longName, sizeof(char)*(NC_MAX_NAME + 1));
            }
        }
  
        [_dimensions addObject:[NSValue valueWithBytes:&ncdDim objCType:@encode(netCDFDimension)]];
	}
}

- (void) readVariables
{
    assert( _ncdHandle );
    
    for( int variable = 0; variable < _numVariables; variable++ )
    {
        netCDFVariable ncdVar;
        ncdVar.id = variable;
        
		int success = nc_inq_var( _ncdHandle, variable, ncdVar.name, &ncdVar.type, &ncdVar.numDimensions, ncdVar.dimensionIDs, &ncdVar.numAttributes );
        
        if( success != NC_NOERR ){
            NSLog( @"Error reading Variable %d.", variable );
            continue;
        }
        
        NSLog( @"Variable %d is %s. Consisting of %d Attributes and %d Dimensions. It is of type %@", variable, ncdVar.name, ncdVar.numAttributes, ncdVar.numDimensions, _typeNames[ncdVar.type] );
        
/*        for( int i = 0; i < ncdVar.numDimensions; i++){
            
            netCDFDimension ncdDim;
            [[_dimensions objectAtIndex:ncdVar.dimensionIDs[i]] getValue:&ncdDim];

            NSLog(@"Dimension %d is %s.", i, ncdDim.name);
        }
*/
        // try to find long name
        memcpy(ncdVar.longName, ncdVar.name, sizeof(char)*(NC_MAX_NAME + 1));
        for( int attribute = 0; attribute < ncdVar.numAttributes; attribute++ )
        {
            char *attributeName = new char[NC_MAX_NAME + 1];
            memset(attributeName, 0, sizeof(char)*(NC_MAX_NAME + 1));
            nc_type attributeType;
            size_t numVals;
            
            success = nc_inq_attname( _ncdHandle, variable, attribute, attributeName);
            
            NSString* attName = [NSString stringWithFormat:@"%s", attributeName];
            
            if( [attName isEqualToString:@"long_name"] )
            {
                success = nc_inq_att( _ncdHandle, variable, attributeName, &attributeType, &numVals);
                
                if( attributeType == NC_CHAR )
                {
                    NSLog( @"Attribute %d is %s. Consisting of %ld Values of type %@", attribute, attributeName, numVals, _typeNames[attributeType]);
                    
                    assert( numVals <= NC_MAX_NAME );
                    success = nc_get_att_text( _ncdHandle, variable, attributeName, ncdVar.longName );
                    ncdVar.longName[ numVals ] = '\0';
                    
                    //NSLog( @"LongName is %s.", ncdVar.longName );
                    NSLog( @"Attribute %d is %s.", attribute, ncdVar.longName );
                    
                    break;
                }
            }
        }
        
        [_variables addObject:[NSValue valueWithBytes:&ncdVar objCType:@encode(netCDFVariable)]];
	}
}

- (NSMutableArray*) inquireVariablesWithDimensionality: (int) numDimensions
{
    NSMutableArray *variables = [[NSMutableArray alloc] init];
    
    for( int v = 0; v < _numVariables; v++ )
    {
        netCDFVariable variable;
        [[_variables objectAtIndex:v] getValue:&variable];
        
        if( variable.numDimensions == numDimensions )
        {
            [variables addObject:[_variables objectAtIndex:v]];
        }
    }
    
    return variables;
}

- (NSMutableArray*) inquireDimensionsByVariableID: (int) variableID
{
    NSMutableArray *dimensions = [[NSMutableArray alloc] init];
    
    netCDFVariable variable;
    [[_variables objectAtIndex:variableID] getValue:&variable];
    
    for( int i = 0; i < variable.numDimensions; i++ )
    {
        int dimensionID = variable.dimensionIDs[ i ];
        
        netCDFDimension dimension;
        [[_dimensions objectAtIndex:dimensionID] getValue:&dimension];
        
        [dimensions addObject:[NSValue valueWithBytes:&dimension objCType:@encode(netCDFDimension)]];
    }
    
    return dimensions;
}

- (NSMutableArray*) inquireAttributesByVariableID: (int) variableID
{
    NSMutableArray *attributes = [[NSMutableArray alloc] init];
    
    netCDFVariable variable;
    [[_variables objectAtIndex:variableID] getValue:&variable];
    
    for( int i = 0; i < variable.numAttributes; i++ )
    {
        netCDFAttribute attribute;
        
        int success = nc_inq_attname(_ncdHandle, variable.id, i, attribute.name);
        if( success != NC_NOERR ){
            NSLog( @"Error accessing Attribute Name %d, Error Code %d.",  i, success );
            continue;
        }
        
        success =  nc_inq_att( _ncdHandle, variable.id, attribute.name, &(attribute.type), &(attribute.size));
        if( success != NC_NOERR ){
            NSLog( @"Error accessing Attribute %s, Error Code %d.", attribute.name, success );
            continue;
        }
        
        [attributes addObject:[NSValue valueWithBytes:&attribute objCType:@encode(netCDFAttribute)]];
    }
    
    return attributes;
}

- (size_t) inquireLengthForDimension: (int) dimensionID
{
    size_t dimLength;
    
	nc_inq_dimlen( _ncdHandle, dimensionID, &dimLength );
    
    return dimLength;
}

- (float) loadFloatAttribute:(netCDFAttribute) attribute forVariable:(netCDFVariable) variable
{
    if( attribute.type != NC_FLOAT ) return 0.0f;
    if( attribute.size != 1 ) return 0.0f;
    
    float value;
    int success = nc_get_att_float(_ncdHandle, variable.id, attribute.name, &value);
    if( success != NC_NOERR ){
        NSLog( @"Error reading Attribute %s, Error Code %d.", attribute.name, success );
        return 0.0f;
    }
    
    return value;
}
    
- (BOOL) loadVariables
{
    id<OVAppDelegateProtocol> appDelegate = (id<OVAppDelegateProtocol>) [NSApplication sharedApplication].delegate;
    OVEnsembleData* ensemble = [appDelegate ensembleData];
    [ensemble setInvalidValue:_invalidValue];
    
    EnsembleDimension sshInputSize = { .x = _fullDataUpper.x + 1, .y = _fullDataUpper.y + 1, .z = 1, .m = _fullDataUpper.m + 1 , .t = _fullDataUpper.t + 1};
    EnsembleDimension sshLower = { .x = _lowerBounds.x, .y = _lowerBounds.y, .z = 0, .m = _lowerBounds.m, .t = _lowerBounds.t };
    EnsembleDimension sshUpper = { .x = _upperBounds.x, .y = _upperBounds.y, .z = 0, .m = _upperBounds.m, .t = _upperBounds.t };
    EnsembleDimension sshSize = { .x = sshUpper.x-sshLower.x+1, .y = sshUpper.y-sshLower.y+1, .z = 1, .m = sshUpper.m-sshLower.m+1, .t = sshUpper.t-sshLower.t+1 };
    
    OVVariable2D* variable = [self addVariable:_sshVariableId withinLower:sshLower upper:sshUpper originalSize:sshInputSize];
    
    [ensemble setIsStructured:YES];
    
    [ensemble createValidEntriesTableWithSize:sshSize.x * sshSize.y];
    
    [ensemble updateMetaDataForDimensionX: sshSize.x Y: sshSize.y Z: 1 T: sshSize.t M: sshSize.m];
    
    [ensemble scanRangeForVariable:variable];
    
    
    // TODO VAR
    if( _isFlowEnabled )
    {
        EnsembleDimension flowInputSize = { .x = _fullDataUpper.x + 1, .y = _fullDataUpper.y + 1, .z = _fullDataUpper.z + 1, .m = _fullDataUpper.m + 1 , .t = _fullDataUpper.t + 1};
        EnsembleDimension flowLower = { .x = _lowerBounds.x, .y = _lowerBounds.y, .z = 0, .m = _lowerBounds.m, .t = _lowerBounds.t };
        EnsembleDimension flowUpper = { .x = _upperBounds.x, .y = _upperBounds.y, .z = 0, .m = _upperBounds.m, .t = _upperBounds.t };
        
        BOOL success = YES;
        
        success *= [self loadVariable:_uVariableId toDataField:-1 withinLower:flowLower upper:flowUpper originalSize:flowInputSize];
        
        success *= [self loadVariable:_vVariableId toDataField:-2 withinLower:flowLower upper:flowUpper originalSize:flowInputSize];
        
        [ensemble setIsVectorFieldAvailable:success];
    }
    

    // TODO: get Lon Lat infor from dataset
    NSMutableArray* vars = [self inquireVariablesWithDimensionality:1];
    
    assert( [vars count] > 1 );
    
    int xId = 0;
    int yId = 0;
    
    // try to find variables automatically
    for( int i = 0; i < [vars count]; i++ )
    {
        netCDFVariable ncdVar;
        [[vars objectAtIndex:i] getValue:&ncdVar];
        NSString *variableName = [NSString stringWithFormat:@"%s", ncdVar.name];
        
        if( [variableName isEqualToString:[NSString stringWithFormat:@"%s",_xDimName]] )
        {
            xId = ncdVar.id;
        }
        
        if( [variableName isEqualToString:[NSString stringWithFormat:@"%s",_yDimName]] )
        {
            yId = ncdVar.id;
        }
    }
    
    float* lat = new float[sshInputSize.y]; //y
    int success = nc_get_var_float( _ncdHandle, yId, lat );

    float* lon = new float[sshInputSize.x]; //x
    success = nc_get_var_float( _ncdHandle, xId, lon );
    
    float latMin, latMax, lonMin, lonMax;
    latMin = lat[_lowerBounds.y];
    latMax = lat[_upperBounds.y];
    lonMin = lon[_lowerBounds.x];
    lonMax = lon[_upperBounds.x];
    
    NSLog( @"Lat: [%f..%f], Lon: [%f..%f].", latMin, latMax, lonMin, lonMax);
    
    // TODO: find out if this is somewhere in the ncd
    if( latMin > 90.0 || latMax > 90.0 )
    {
        latMin = -180.0 + latMin;
        latMax = -180.0 + latMax;
    }
    
    if( lonMin > 180.0 || lonMax > 180.0 )
    {
        lonMin = -360.0 + lonMin;
        lonMax = -360.0 + lonMax;
    }
    
    NSLog( @"Corrected Lat: [%f..%f], Lon: [%f..%f].", latMin, latMax, lonMin, lonMax);
    
    [ensemble updateMetaDataForMinLat: latMin maxLat: latMax minLon: lonMin maxLon: lonMax];
    
    return YES;
}

- (OVVariable2D*) addVariable: (int) varID withinLower: (EnsembleDimension) lowerBounds upper: (EnsembleDimension) upperBounds originalSize: (EnsembleDimension) inputSize
{
    id<OVAppDelegateProtocol> appDelegate = (id<OVAppDelegateProtocol>) [NSApplication sharedApplication].delegate;
    OVEnsembleData* ensemble = [appDelegate ensembleData];
    
    // allocate memory for loading the complete data from nc file
    size_t fullSize = (inputSize.x * inputSize.y * inputSize.z * inputSize.t * inputSize.m);
    float *inputData = new float[ fullSize ];
	memset( inputData, 0, fullSize * sizeof( float ) );
    
	int success = 0;
    
    if( _isTFromFileList )
    {
        size_t tSize = (inputSize.x * inputSize.y * inputSize.z * inputSize.m);
        size_t offset = 0;
        
        for( size_t t = lowerBounds.t; t <= upperBounds.t; t++ ){
            
            success = nc_get_var_float( [self createNcdHandle:[_fileList objectAtIndex:t]], varID, &inputData[offset] );
            
            if( success != NC_NOERR ){
                NSLog( @"Failed to load NetCDF data. Error %d occured while reading Variable %d in file %@.", success, varID, [_fileList objectAtIndex:t]);
                delete[] inputData;
                return nil;
            }
            offset += tSize;
        }
    }
    else
    {
        success = nc_get_var_float( _ncdHandle, varID, inputData );
        
        if( success != NC_NOERR ){
            NSLog( @"Failed to load NetCDF data. Error %d occured while reading Variable %d in file %@.", success, varID,[_fileList objectAtIndex:0] );
            delete[] inputData;
            return nil;
        }
    }
    
    EnsembleDimension outputSize = { .x = upperBounds.x-lowerBounds.x+1,
                                     .y = upperBounds.y-lowerBounds.y+1,
                                     .z = upperBounds.z-lowerBounds.z+1,
                                     .m = upperBounds.m-lowerBounds.m+1,
                                     .t = upperBounds.t-lowerBounds.t+1 };
    size_t dataSize = outputSize.x * outputSize.y * outputSize.z * outputSize.t * outputSize.m;
    
    OVVariable2D* variable = [ensemble add2DVariable];
    variable.data = new float[dataSize];
    memset( variable.data, 0, dataSize * sizeof( float ) );
    
    NSString* nameString = @"long_name"; nc_type nctype; size_t ncsize;
    success =  nc_inq_att( _ncdHandle, varID, [nameString UTF8String], &nctype, &ncsize);
    if( success != NC_NOERR ){
        variable.name = @"Variable";
        NSLog( @"Error accessing Attribute %@, Error Code %d.", nameString, success );
    } else {
        char *attValue = new char[ncsize];
        memset(attValue, 0, sizeof(char)*ncsize);
        success =  nc_get_att_text(_ncdHandle, varID, [nameString UTF8String], attValue);
        if( success != NC_NOERR ){
            variable.name = @"Variable";
            NSLog( @"Error reading Attribute %@, Error Code %d.", nameString, success );
        } else {
            variable.name = [NSString stringWithCString:attValue encoding:NSASCIIStringEncoding];
        }
        delete[] attValue; attValue = nil;
    }
    
    nameString = @"units";
    success =  nc_inq_att( _ncdHandle, varID, [nameString UTF8String], &nctype, &ncsize);
    if( success != NC_NOERR ){
        variable.unit = @"Unit";
        NSLog( @"Error accessing Attribute %@, Error Code %d.", nameString, success );
    } else {
        char *attValue = new char[ncsize];
        memset(attValue, 0, sizeof(char)*ncsize);
        success =  nc_get_att_text(_ncdHandle, varID, [nameString UTF8String], attValue);
        if( success != NC_NOERR ){
            variable.unit = @"Unit";
            NSLog( @"Error reading Attribute %@, Error Code %d.", nameString, success );
        } else {
         variable.unit = [NSString stringWithCString:attValue encoding:NSASCIIStringEncoding];
        }
        delete[] attValue; attValue = nil;
    }
    
    [variable setDimensionsX:outputSize.x Y:outputSize.y Z:outputSize.z M:outputSize.m T:outputSize.t];
    
    //float minVal =  99999.9f, maxVal = -99999.9f;
    for( size_t t = lowerBounds.t; t <= upperBounds.t; t++ ){
		for( size_t m = lowerBounds.m; m <= upperBounds.m; m++ ){
            for( size_t z = lowerBounds.z; z <= upperBounds.z; z++ ){
                for( size_t y = lowerBounds.y; y <= upperBounds.y; y++ ){
                    for( size_t x = lowerBounds.x; x <= upperBounds.x; x++)
                    {
                        size_t idx = x
                        + y * inputSize.x
                        + z * inputSize.x * inputSize.y
                        + m * inputSize.x * inputSize.y * inputSize.z
                        + t * inputSize.x * inputSize.y * inputSize.z * inputSize.m;
                        size_t newIdx = (x - lowerBounds.x)
                        + (y - lowerBounds.y) * outputSize.x
                        + (z - lowerBounds.z) * outputSize.x * outputSize.y
                        + (m - lowerBounds.m) * outputSize.x * outputSize.y * outputSize.z
                        + (t - lowerBounds.t) * outputSize.x * outputSize.y * outputSize.z * outputSize.m;
                        
                        float val = inputData[idx];
                        variable.data[newIdx] = val;
                    }
                }
            }
        }
    }
    
    delete[] inputData;
    
    return variable;
}

- (BOOL) loadVariable: (int) varID toDataField: (int) dataFieldId withinLower: (EnsembleDimension) lowerBounds upper: (EnsembleDimension) upperBounds originalSize: (EnsembleDimension) inputSize
{
    id<OVAppDelegateProtocol> appDelegate = (id<OVAppDelegateProtocol>) [NSApplication sharedApplication].delegate;
    OVEnsembleData* ensemble = [appDelegate ensembleData];
    
    // allocate memory for loading the complete data from nc file
    size_t fullSize = (inputSize.x * inputSize.y * inputSize.z * inputSize.t * inputSize.m);
    float *inputData = new float[ fullSize ];
	memset( inputData, 0, fullSize * sizeof( float ) );
    
	int success = 0;
    
    if( _isTFromFileList )
    {
        size_t tSize = (inputSize.x * inputSize.y * inputSize.z * inputSize.m);
        size_t offset = 0;
        
        for( size_t t = lowerBounds.t; t <= upperBounds.t; t++ ){
            
            success = nc_get_var_float( [self createNcdHandle:[_fileList objectAtIndex:t]], varID, &inputData[offset] );
            
            if( success != NC_NOERR ){
                NSLog( @"Failed to load NetCDF data. Error %d occured while reading Variable %d in file %@.", success, varID, [_fileList objectAtIndex:t]);
                delete[] inputData;
                return NO;
            }
            
            offset += tSize;
        }
    }
    else
    {
        success = nc_get_var_float( _ncdHandle, varID, inputData );
        
        if( success != NC_NOERR ){
            NSLog( @"Failed to load NetCDF data. Error %d occured while reading Variable %d in file %@.", success, varID,[_fileList objectAtIndex:0] );
            delete[] inputData;
            return NO;
        }
    }
    
    EnsembleDimension outputSize = { .x = upperBounds.x-lowerBounds.x+1,
                                     .y = upperBounds.y-lowerBounds.y+1,
                                     .z = upperBounds.z-lowerBounds.z+1,
                                     .m = upperBounds.m-lowerBounds.m+1,
                                     .t = upperBounds.t-lowerBounds.t+1 };
    
    float *data = [ensemble allocateMemoryFor:dataFieldId withNumValues:outputSize.x * outputSize.y * outputSize.z * outputSize.t * outputSize.m];

    //float minVal =  99999.9f, maxVal = -99999.9f;
    for( size_t t = lowerBounds.t; t <= upperBounds.t; t++ ){
		for( size_t m = lowerBounds.m; m <= upperBounds.m; m++ ){
            for( size_t z = lowerBounds.z; z <= upperBounds.z; z++ ){
                for( size_t y = lowerBounds.y; y <= upperBounds.y; y++ ){
                    for( size_t x = lowerBounds.x; x <= upperBounds.x; x++)
                    {
                        size_t idx      = x
                                        + y * inputSize.x
                                        + z * inputSize.x * inputSize.y
                                        + m * inputSize.x * inputSize.y * inputSize.z
                                        + t * inputSize.x * inputSize.y * inputSize.z * inputSize.m;
                        size_t newIdx   = (x - lowerBounds.x)
                                        + (y - lowerBounds.y) * outputSize.x
                                        + (z - lowerBounds.z) * outputSize.x * outputSize.y
                                        + (m - lowerBounds.m) * outputSize.x * outputSize.y * outputSize.z
                                        + (t - lowerBounds.t) * outputSize.x * outputSize.y * outputSize.z * outputSize.m;
                        
                        float val = inputData[idx];
                        data[newIdx] = val;
                        /*
                        if( val != _invalidValue ){
                            if( val > maxVal ) maxVal = val;
                            if( val < minVal ) minVal = val;
                        }
                        */
                    }
                }
            }
        }
    }
    
    delete[] inputData;
    
    return YES;
}

@end