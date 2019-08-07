/*!	@header		OVNetCDFLoader.h
    @discussion	This class wraps functions for inquiring and loading netCDF data.
    @author		Thomas Höllt
    @updated	2013-10-27 */

// System Headers
#import <Foundation/Foundation.h>

// Custom Headers
#import "netcdf.h"

@class OVVariable2D;

typedef struct
{
    int id;
    char name[NC_MAX_NAME + 1];
    char longName[NC_MAX_NAME + 1];
    size_t size;
    
} netCDFDimension;

typedef struct
{
    char name[NC_MAX_NAME + 1];
    nc_type type;
    size_t size;
    
} netCDFAttribute;

typedef struct
{
    int id;
    char name[NC_MAX_NAME + 1];
    char longName[NC_MAX_NAME + 1];
    nc_type type;
    int numAttributes;
    int numDimensions;
    int dimensionIDs[NC_MAX_VAR_DIMS];
    
} netCDFVariable;

@interface OVNetCDFLoader : NSObject {
    
    NSArray *_fileList;
    const char *_file;
    int _ncdHandle;
    
    int _numDimensions;
    int _numVariables;
    int _numAttributes;
    int _unlimitedDimension;
    
    NSMutableArray *_dimensions;
    NSMutableArray *_variables;
    
    int _sshVariableId;
    
    BOOL _isFlowEnabled;
    int _uVariableId;
    int _vVariableId;
    
    float _invalidValue;
    
    char* _xDimName;
    char* _yDimName;
    
    BOOL _isTFromFileList;
    
    EnsembleDimension _lowerBounds;
    EnsembleDimension _upperBounds;
    EnsembleDimension _fullDataUpper;
}

/*!	@property	dimensions
    @brief		NSArray containing all dimensions as netCDFDimension.*/
@property (nonatomic, readonly) NSMutableArray* dimensions;

/*!	@property	sshVariableId
    @brief		ID of the ssh variable to load.*/
@property (nonatomic) int sshVariableId;

/*!	@property	isFlowEnabled
    @brief		falg that decides wether to load the flow field or not.*/
@property (nonatomic) BOOL isFlowEnabled;

/*!	@property	uVariableId
    @brief		ID of the u variable to load.*/
@property (nonatomic) int uVariableId;

/*!	@property	vVariableId
    @brief		ID of the v variable to load.*/
@property (nonatomic) int vVariableId;

/*!	@property	xDimName
    @brief		ID of the x dimension.*/
@property (nonatomic) char* xDimName;

/*!	@property	yDimName
    @brief		ID of the y dimension.*/
@property (nonatomic) char* yDimName;

/*!	@property	isTFromFileList
    @brief		flag whether time dimension is loaded from single or multiple ncd files.*/
@property (nonatomic) BOOL isTFromFileList;

/*!	@property	invalidValue
    @brief		Value for invalid data entries.*/
@property (nonatomic) float invalidValue;

/*!	@property	lowerBounds
    @brief		Lower boundaries for target data.*/
@property (nonatomic) EnsembleDimension lowerBounds;

/*!	@property	upperBounds
    @brief		Upper boundaries for target data.*/
@property (nonatomic) EnsembleDimension upperBounds;

/*!	@property	fullDataUpper
    @brief		Upper boundaries for original complete data.*/
@property (nonatomic) EnsembleDimension fullDataUpper;

- (id) initWithFileList: (NSArray *) list;

- (int) createNcdHandle: (NSURL*) file;
- (void) openFile: (NSURL*) file;
- (void) closeFile;

- (void) readDimensions;

- (void) readVariables;

- (NSMutableArray*) inquireVariablesWithDimensionality: (int) numDimensions;

- (NSMutableArray*) inquireDimensionsByVariableID: (int) variableID;

- (NSMutableArray*) inquireAttributesByVariableID: (int) variableID;

- (size_t) inquireLengthForDimension: (int) dimensionID;

- (float) loadFloatAttribute:(netCDFAttribute) attribute forVariable:(netCDFVariable) variable;
- (BOOL) loadVariables;
- (OVVariable2D*) addVariable: (int) varID withinLower: (EnsembleDimension) lowerBounds upper: (EnsembleDimension) upperBounds originalSize: (EnsembleDimension) inputSize;
- (BOOL) loadVariable: (int) varID toDataField: (int) dataFieldId withinLower: (EnsembleDimension) lowerBounds upper: (EnsembleDimension) upperBounds originalSize: (EnsembleDimension) inputSize;
@end
