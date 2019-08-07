//
//	OVEnsembleData.mm
//

// Custom Headers
#import "OVViewSettings.h"

// Local Headers
#import "OVEnsembleData.h"
#import "OVEnsembleData+Statistics.h"
#import "OVStatistic.h"
#import "OVHistogram.h"
#import "OVVariable2D.h"

@implementation OVEnsembleData

@synthesize isLoaded = _isLoaded;
@synthesize isStructured = _isStructured;

@synthesize isVectorFieldAvailable = _isVectorFieldAvailable;
@synthesize normalizedPathlines = _normalizedPathlines;
@synthesize pathlineColors = _pathlineColors;

@synthesize variables1D = _variables1D;
@synthesize variables2D = _variables2D;

@synthesize validEntries = _validEntries;
@synthesize invalidValue = _invalidValue;

@synthesize uData	= _uData;
@synthesize vData	= _vData;

@synthesize ensembleDimension = _ensembleDimension;
@synthesize ensembleLonLat	= _ensembleLonLat;

@synthesize histogramBins = _histogramBins;

@synthesize platforms = _platforms;

@synthesize riskHeightIsoValue = _riskHeightIsoValue;
@synthesize riskIsoValue		 = _riskIsoValue;

@synthesize nodes		= _nodes;
@synthesize gridIndices	= _gridIndices;
@synthesize indexLookup	= _indexLookup;
@synthesize indexLookupWidth	= _indexLookupWidth;
@synthesize indexLookupHeight	= _indexLookupHeight;
@synthesize numNodes	 = _numNodes;
@synthesize numTriangles = _numTriangles;

@synthesize memberRangeMin	 = _memberRangeMin;
@synthesize memberRangeMax	 = _memberRangeMax;
@synthesize memberShowSingle = _memberShowSingle;
@synthesize memberSingleId	 = _memberSingleId;

@synthesize timeRangeMin	 = _timeRangeMin;
@synthesize timeRangeMax	 = _timeRangeMax;
@synthesize timeShowSingle	 = _timeShowSingle;
@synthesize timeSingleId	 = _timeSingleId;
@synthesize timeStepStride   = _timeStepStride;

@synthesize pathlineResolution  = _pathlineResolution;
@synthesize pathlineAlphaScale  = _pathlineAlphaScale;
@synthesize pathlineStartX      = _pathlineStartX;
@synthesize pathlineStartY      = _pathlineStartY;
@synthesize pathlinepPogressionFactor = _pathlinepPogressionFactor;
@synthesize assimilationCycleLength   = _assimilationCycleLength;
@synthesize pathlineTexture     = _pathlineTexture;

@synthesize startDate       = _startDate;
@synthesize timeStepLength  = _timeStepLength;

#pragma mark Initialization

- (id) init
{
	self = [super init];
	
	if( !self ) return nil;
    
	_appDelegate = (id<OVAppDelegateProtocol>) [NSApplication sharedApplication].delegate;
	
    _isLoaded = NO;
	_isStructured = YES;
    
    _variables2D = [[NSMutableArray alloc] init];
    
	_uData = nil;
	_vData = nil;
	_isVectorFieldAvailable = NO;
	_numberValids = 0;
    _invalidAvailable = NO;
	_validEntries = nil;
	_ensembleDimension = new EnsembleDimension;
	_ensembleDimension->x = 0;
	_ensembleDimension->y = 0;
	_ensembleDimension->t = 0;
	_ensembleDimension->m = 0;
	_ensembleDimension->size = 0;
	_ensembleDimension->texX = 0;
	_ensembleDimension->texY = 0;
	_ensembleLonLat = new EnsembleLonLat;
	_ensembleLonLat->lon_min = -180.0;
	_ensembleLonLat->lon_max =	180.0;
	_ensembleLonLat->lat_min = -180.0;
	_ensembleLonLat->lat_max =	180.0;
	
	_nodes = nil;
	_gridIndices = nil;
    _indexLookup = nil;
    _indexLookupWidth = 0;
    _indexLookupHeight = 0;
	_numNodes = 0;
	_numTriangles = 0;
	
	_memberRangeMin = 0;
	_memberRangeMax = 0;
	_memberShowSingle = NO;
	_memberSingleId = 0;
	_timeRangeMin = 0;
	_timeRangeMax = 0;
	_timeShowSingle = YES;
	_timeSingleId = 0;
    _timeStepStride = 1;
	
	_histogramBins = 100;
    
    _isInitRun = NO;
    _histogram1D = nil;

	[self invalidateStatisticsWithUpdate:NO];
	
	_platforms = [[NSMutableDictionary alloc] init];
	_activePlatform = nil;
	
	_riskHeightIsoValue = 0.17;
	_riskIsoValue = 0.0;
    
    _pathlineResolution = 1.0;
    _pathlineAlphaScale = 1.0;
    _pathlineStartX = 0.0;
    _pathlineStartY = 0.0;
    _pathlineStartZ = 0.0;
    _pathlinepPogressionFactor = 1.0;
    _assimilationCycleLength = 72.0;
    
    _pathlineRenderer = nil;
    _pathlineTexture = 0;
    
    for( int i = 0; i < 2; i++ )
    {
        _tsKdes[i] = nil;
        _tsMeans[i] = nil;
        _tsRisks[i] = nil;
        
        for( int p = 0; p < 11; p++ )
        {
            _tsPercentiles[p][i] = nil;
        }
    }
	
	return self;
}

#pragma mark - Parameter Range

- (void) setTimeRangeMin:(int) val
{
	int v = val > _timeRangeMax ? _timeRangeMax : val;
	_timeRangeMin = v;
	[self invalidateStatisticsWithUpdate:YES];
}

- (void) setTimeRangeMax:(int) val
{
	int v = val < _timeRangeMin ? _timeRangeMin : val;
	_timeRangeMax = v;
	[self invalidateStatisticsWithUpdate:YES];
}

- (void) setTimeShowSingle:(BOOL) val
{
	_timeShowSingle = val;
	[self invalidateStatisticsWithUpdate:YES];
}

- (void) setTimeSingleId:(int) val
{
	_timeSingleId = val;
	[self invalidateStatisticsWithUpdate:YES];
}

- (NSInteger) numTimeStepsWithStride
{
    NSInteger numTotalVisibleTimesteps = _timeRangeMax - _timeRangeMin + 1;
    NSInteger numTimeStepsWithStride = numTotalVisibleTimesteps / _timeStepStride;
    
    if( numTotalVisibleTimesteps % _timeStepStride != 0 ) numTimeStepsWithStride++;
    
    return numTimeStepsWithStride;
}

- (void) setMemberRangeMin:(int) val
{
	int v = val > _memberRangeMax ? _memberRangeMax : val;
	_memberRangeMin = v;
	[self invalidateStatisticsWithUpdate:YES];
}

- (void) setMemberRangeMax:(int) val
{
	int v = val < _memberRangeMin ? _memberRangeMin : val;
	_memberRangeMax = v;
	[self invalidateStatisticsWithUpdate:YES];
}

- (void) setMemberShowSingle:(BOOL) val
{
	_memberShowSingle = val;
	[self invalidateStatisticsWithUpdate:YES];
}

- (void) setMemberSingleId:(int) val
{
	_memberSingleId = val;
	[self invalidateStatisticsWithUpdate:YES];
}

#pragma mark - Statistics

- (float*) dataForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	return variable.data;
}

- (float*) dataRangeForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	return variable.dataRange;
}

- (BOOL) isVariableStaticOverTime:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	return variable.isTimeStatic;
}

- (BOOL) isVariableStaticOverMembers:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	return variable.isMemberStatic;
}

- (BOOL) isVariableStatic:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
    return (variable.isTimeStatic && variable.isMemberStatic);
}

- (NSString*) nameForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	return variable.name;
}

- (NSArray*) allVariableNamesWithDimension:(NSInteger) dimension
{
    NSMutableArray* names;
    
    if( dimension == 1 )
    {
        names = [[NSMutableArray alloc] initWithCapacity:[_variables1D count]];
        
        for( int i = 0; i < [_variables1D count]; i++ )
        {
            names[i] = [_variables1D[i] name];
        }
    }
    else if( dimension == 2 )
    {
        names = [[NSMutableArray alloc] initWithCapacity:[_variables2D count]];
        
        for( int i = 0; i < [_variables2D count]; i++ )
        {
            names[i] = [_variables2D[i] name];
        }
    }
    else if( dimension == 3 )
    {
//        names = [[NSMutableArray alloc] initWithCapacity:[_variables3D count]];
    }
    
    return [[NSArray alloc] initWithArray:names];
}

// custom getters to make sure data is up to date
- (int*) histogramForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	[self updateHistogramForVariable:variable];
	return variable.histogram.data;
}

- (float*) kdeForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	[self updateHistogramForVariable:variable];
	return variable.histogram.kde;
}

- (float*) meanForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	[self updateMeanForVariable:variable];
	return variable.mean.data;
}

- (float*) meanNormalizedForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	[self updateMeanForVariable:variable];
	return variable.mean.dataNormalized;
}

- (float*) meanRangeForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	[self updateMeanForVariable:variable];
	return variable.mean.range;
}

- (float*) meanLimitsForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	return variable.mean.limits;
}

- (void) setMeanLowerLimit: (float) limit ForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
    variable.mean.limits[1] = limit;
    [self normalizeMeanForVariable:variable];
}

- (void) setMeanUpperLimit: (float) limit ForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
    variable.mean.limits[0] = limit;
    [self normalizeMeanForVariable:variable];
}

- (float*) medianForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	[self updateMedianForVariable:variable];
	return variable.median.data;
}

- (float*) medianNormalizedForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	[self updateMedianForVariable:variable];
	return variable.median.dataNormalized;
}

- (float*) medianRangeForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	[self updateMedianForVariable:variable];
	return variable.median.range;
}

- (float*) medianLimitsForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	return variable.median.limits;
}

- (void) setMedianLowerLimit: (float) limit ForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
    variable.median.limits[1] = limit;
    [self normalizeMedianForVariable:variable];
}

- (void) setMedianUpperLimit: (float) limit ForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
    variable.median.limits[0] = limit;
    [self normalizeMedianForVariable:variable];
}

- (float*) maximumModeForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	[self updateMaximumModeForVariable:variable];
	return variable.maximumMode.data;
}

- (float*) maximumModeNormalizedForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	[self updateMaximumModeForVariable:variable];
	return variable.maximumMode.dataNormalized;
}

- (float*) maximumModeRangeForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	[self updateMaximumModeForVariable:variable];
	return variable.maximumMode.range;
}

- (float*) rangeForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	[self updateRangeForVariable:variable];
	return variable.range.data;
}

- (float*) rangeNormalizedForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	[self updateRangeForVariable:variable];
	return variable.range.dataNormalized;
}

- (float*) rangeRangeForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	[self updateRangeForVariable:variable];
	return variable.range.range;
}

- (float*) rangeLimitsForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	return variable.range.limits;
}

- (void) setRangeLowerLimit: (float) limit ForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
    variable.range.limits[1] = limit;
    [self normalizeRangeForVariable:variable];
}

- (void) setRangeUpperLimit: (float) limit ForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
    variable.range.limits[0] = limit;
    [self normalizeRangeForVariable:variable];
}

- (float*) standardDeviationForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	[self updateStandardDeviationForVariable:variable];
	return variable.standardDeviation.data;
}

- (float*) standardDeviationNormalizedForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	[self updateStandardDeviationForVariable:variable];
	return variable.standardDeviation.dataNormalized;
}

- (float*) standardDeviationRangeForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	[self updateStandardDeviationForVariable:variable];
	return variable.standardDeviation.range;
}

- (float*) standardDeviationLimitsForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	return variable.standardDeviation.limits;
}

- (void) setStandardDeviationLowerLimit: (float) limit ForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
    variable.standardDeviation.limits[1] = limit;
    [self normalizeStandardDeviationForVariable:variable];
}

- (void) setStandardDeviationUpperLimit: (float) limit ForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
    variable.standardDeviation.limits[0] = limit;
    [self normalizeStandardDeviationForVariable:variable];
}

- (float*) varianceForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	[self updateVarianceForVariable:variable];
	return variable.variance.data;
}

- (float*) varianceNormalizedForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	[self updateVarianceForVariable:variable];
	return variable.variance.dataNormalized;
}

- (float*) varianceRangeForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	[self updateVarianceForVariable:variable];
	return variable.variance.range;
}

- (float*) varianceLimitsForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	return variable.variance.limits;
}

- (void) setVarianceLowerLimit: (float) limit ForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
    variable.variance.limits[1] = limit;
    [self normalizeVarianceForVariable:variable];
}

- (void) setVarianceUpperLimit: (float) limit ForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
    variable.variance.limits[0] = limit;
    [self normalizeVarianceForVariable:variable];
}

- (void) setRiskHeightIsoValue:(float) isoValue
{
	_riskHeightIsoValue = isoValue;
    
    for( OVVariable2D* variable in _variables2D )
    {
        variable.risk.isDirty = YES;
    }
}

- (float*) riskForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	[self updateRiskForVariable:variable];
	return variable.risk.data;
}

- (float*) riskNormalizedForVariable:(NSInteger) variableId
{
    assert( _variables2D && variableId < [_variables2D count] );
    OVVariable2D* variable = _variables2D[variableId];
    
	[self updateRiskForVariable:variable];
	return variable.risk.dataNormalized;
}

#pragma mark - Properties & Surfaces

- (float*) property:(OVEnsembleProperty) propertyId ForVariable:(NSInteger) variableId
{
	switch (propertyId)
	{
		case EnsemblePropertyMean:
			return [self meanForVariable:variableId];
			break;
		case EnsemblePropertyMedian:
			return [self medianForVariable:variableId];
			break;
		case EnsemblePropertyMaximumLikelihood:
			return [self maximumModeForVariable:variableId];
			break;
		case EnsemblePropertyRange:
			return [self rangeForVariable:variableId];
			break;
		case EnsemblePropertyStandardDeviation:
			return [self standardDeviationForVariable:variableId];
			break;
		case EnsemblePropertyVariance:
			return [self varianceForVariable:variableId];
			break;
		case EnsemblePropertyRisk:
			return [self riskForVariable:variableId];
			break;
		case EnsemblePropertyBathymetry:
            assert( [self isVariableStatic:variableId] );
			return [self dataForVariable:variableId];
			break;
		default:
			return nil;
	}
	
	return nil;
}

- (float*) propertyNormalized:(OVEnsembleProperty) propertyId ForVariable:(NSInteger) variableId
{
	switch (propertyId)
	{
		case EnsemblePropertyMean:
			return [self meanNormalizedForVariable:variableId];
			break;
		case EnsemblePropertyMedian:
			return [self medianNormalizedForVariable:variableId];
			break;
		case EnsemblePropertyMaximumLikelihood:
			return [self maximumModeNormalizedForVariable:variableId];
			break;
		case EnsemblePropertyRange:
			return [self rangeNormalizedForVariable:variableId];
			break;
		case EnsemblePropertyStandardDeviation:
			return [self standardDeviationNormalizedForVariable:variableId];
			break;
		case EnsemblePropertyVariance:
			return [self varianceNormalizedForVariable:variableId];
			break;
		case EnsemblePropertyRisk:
			return [self riskForVariable:variableId];
			break;
		case EnsemblePropertyBathymetry:
            assert( [self isVariableStatic:variableId] );
			return [self dataForVariable:variableId];
			break;
		default:
			return nil;
	}
	
	return nil;
}

- (float*) activeSurfaceForView:(OVViewId) viewId normalized:(BOOL) normalized
{
	if( viewId != ViewId3D ) return nil;
	
	OVEnsembleProperty activeSurface = _appDelegate.viewSettings.activeSurface3D;
	NSInteger activeVariable = _appDelegate.viewSettings.activeSurfaceVariable3D;
	
	if( normalized )
		return [self propertyNormalized:activeSurface ForVariable:activeVariable];
	else
		return [self property:activeSurface ForVariable:activeVariable];
}

- (float*) propertyData:(OVEnsembleProperty) propertyId normalized:(BOOL) normalized ForVariable:(NSInteger) variableId
{
    if( normalized )
		return [self propertyNormalized:propertyId ForVariable:variableId];
	else
		return [self property:propertyId ForVariable:variableId];
}

- (float*) propertyRange:(OVEnsembleProperty) propertyId ForVariable:(NSInteger) variableId
{
    switch (propertyId)
	{
		case EnsemblePropertyMean:
			return [self meanRangeForVariable:variableId];
			break;
		case EnsemblePropertyMedian:
			return [self medianRangeForVariable:variableId];
			break;
		case EnsemblePropertyMaximumLikelihood:
			return [self maximumModeRangeForVariable:variableId];
			break;
		case EnsemblePropertyRange:
			return [self rangeRangeForVariable:variableId];
			break;
		case EnsemblePropertyStandardDeviation:
			return [self standardDeviationRangeForVariable:variableId];
			break;
		case EnsemblePropertyVariance:
			return [self varianceRangeForVariable:variableId];
			break;
		default:
			return nil;
	}
	
	return nil;
}


- (float*) activePropertyForView:(OVViewId) viewId normalized:(BOOL) normalized
{
	OVEnsembleProperty activeProperty;
	NSInteger activeVariable;
    
	switch (viewId)
	{
		case ViewId2D:
			activeProperty = _appDelegate.viewSettings.activeProperty2D;
            activeVariable = _appDelegate.viewSettings.activePropertyVariable2D;
			break;
		case ViewId3D:
			activeProperty = _appDelegate.viewSettings.activeProperty3D;
            activeVariable = _appDelegate.viewSettings.activePropertyVariable3D;
			break;
		default:
			return nil;
	}
    
    return [self propertyData:activeProperty normalized:normalized ForVariable:activeVariable];
}

- (float*) activePropertyRangeForView:(OVViewId) viewId
{
	OVEnsembleProperty activeProperty;
	NSInteger activeVariable;
	
	switch (viewId)
	{
		case ViewId2D:
			activeProperty = _appDelegate.viewSettings.activeProperty2D;
            activeVariable = _appDelegate.viewSettings.activePropertyVariable2D;
			break;
		case ViewId3D:
			activeProperty = _appDelegate.viewSettings.activeProperty3D;
            activeVariable = _appDelegate.viewSettings.activePropertyVariable3D;
			break;
		default:
			return nil;
	}
    
    return [self propertyRange:activeProperty ForVariable:activeVariable];
}


- (float*) activeNoisePropertyForView:(OVViewId) viewId normalized:(BOOL) normalized
{
	OVEnsembleProperty activeProperty;
	NSInteger activeVariable;
	
	switch (viewId)
	{
		case ViewId2D:
			activeProperty = _appDelegate.viewSettings.activeNoiseProperty2D;
            activeVariable = _appDelegate.viewSettings.activeNoisePropertyVariable3D;
			break;
		case ViewId3D:
			activeProperty = _appDelegate.viewSettings.activeNoiseProperty3D;
            activeVariable = _appDelegate.viewSettings.activeNoisePropertyVariable3D;
			break;
		default:
			return nil;
	}
    
    return [self propertyData:activeProperty normalized:normalized ForVariable:activeVariable];
}

- (float*) activeNoisePropertyRangeForView:(OVViewId) viewId
{
	OVEnsembleProperty activeProperty;
	NSInteger activeVariable;
	
	switch (viewId)
	{
		case ViewId2D:
			activeProperty = _appDelegate.viewSettings.activeNoiseProperty2D;
            activeVariable = _appDelegate.viewSettings.activeNoisePropertyVariable3D;
			break;
		case ViewId3D:
			activeProperty = _appDelegate.viewSettings.activeNoiseProperty3D;
            activeVariable = _appDelegate.viewSettings.activeNoisePropertyVariable3D;
			break;
		default:
			return nil;
	}
    
    return [self propertyRange:activeProperty ForVariable:activeVariable];
}

#pragma mark - Glyphs

- (float*) kdesForGlyphSide:(int) side
{
	assert( side ==0 || side == 1 );
	return _tsKdes[side];
}

- (float*) meansForGlyphSide:(int) side
{
    assert( side ==0 || side == 1 );
    return _tsMeans[side];
}

- (float*) percentiles:(int) p ForGlyphSide:(int) side
{
    assert( side ==0 || side == 1 );
    assert( p >= 0 && p <= 10 );
    return _tsPercentiles[p][side];
}

- (float*) risksForGlyphSide:(int) side
{
	assert( side ==0 || side == 1 );
	return _tsRisks[side];
}

#pragma mark - Helpers

- (int) gridYFromLat:(float) latitude
{
	float latMin = _ensembleLonLat->lat_min;
	float latMax = _ensembleLonLat->lat_max;
	
	latitude -= latMin;
	latitude /= (latMax - latMin);
	
	//NSLog(@"Scaled Lat = %f", latitude);
	
	if( latitude > 1.0 || latitude < 0.0 ) return -1;
	
	latitude *= (_ensembleDimension->y);
	
	return (int)(latitude);
}

- (int) gridXFromLon:(float) longitude
{
	float lonMin = _ensembleLonLat->lon_min;
	float lonMax = _ensembleLonLat->lon_max;
	
	longitude -= lonMin;
	longitude /= (lonMax - lonMin);
	
	if( longitude > 1.0 || longitude < 0.0 ) return -1;
	
	longitude *= (_ensembleDimension->x);
	
	return (int)(longitude);
}

- (int) unstructuredIndexFromLon:(float) longitude Lat:(float) latitude
{
    if( !_indexLookup ) return -1;
    
	float latExt = ABS(_ensembleLonLat->lat_max - _ensembleLonLat->lat_min);
	float lonExt = ABS(_ensembleLonLat->lon_max - _ensembleLonLat->lon_min);
    
    float normX = (longitude - _ensembleLonLat->lon_min) / lonExt;
    float normY = (latitude - _ensembleLonLat->lat_min) / latExt;
    
    int x = (int)(normX * _indexLookupWidth);
    int y = (int)(normY * _indexLookupHeight);
    
    if( x < 0 || x >= _indexLookupWidth || y < 0 || y >= _indexLookupHeight )
    {
        //NSLog(@"Warning tried to access coordinate outside of the screen: (%d,%d).", x, y);
        return -1;
    }
    
    size_t offset = (x + y * _indexLookupWidth) * 4;
    
    int r = (int)(_indexLookup[offset]);
    int g = (int)(_indexLookup[offset+1]);
    int b = (int)(_indexLookup[offset+2]);
    
    //NSLog(@"Color: (%d, %d, %d).", r, g, b);
    
    int index = r * 256 * 256 + g * 256 + b;
    
    //NSLog(@"Index: %d.", index);
	
	return (int)(index);
}

- (size_t) numberOfPathlineSegments
{
	return (_normalizedPathlines.size() / 3);
}

- (OVVariable2D*) add2DVariable
{
    OVVariable2D* variable = [[OVVariable2D alloc] init];
    [_variables2D addObject:variable];
    
    return variable;
}

- (float*) allocateMemoryFor: (int) variableId withNumValues: (size_t) numVals
{
    if( variableId >= 0 )
    {
        // TODO VAR this should not be reachable anymore, test and remove
        assert(NO);
        
        if( [_variables2D count] < 1 || !_variables2D[variableId] )
        {
            assert( [_variables2D count] == variableId );
            OVVariable2D* v = [[OVVariable2D alloc] init];
            v.name = @"Sea Surface Height";
            v.unit = @"m";
            [_variables2D addObject:v];
        }
        
        OVVariable2D* variable = _variables2D[variableId];
        
        if( variable.data )
        {
            delete [] variable.data;
            variable.data = nil;
        }
        
        variable.data = new float[ numVals ];
        memset( variable.data, 0, numVals * sizeof( float ) );
        
        return variable.data;
    }
    // TODO VAR
    else if( variableId == -1 )
    {
        if( _uData )
        {
            delete [] _uData;
            _uData = nil;
        }
        
        _uData = new float[ numVals ];
        memset( _uData, 0, numVals * sizeof( float ) );
        
        return _uData;
    }
    // TODO VAR
    else if( variableId == -2 )
    {
        if( _vData )
        {
            delete [] _vData;
            _vData = nil;
        }
        
        _vData = new float[ numVals ];
        memset( _vData, 0, numVals * sizeof( float ) );
        
        return _vData;
    }
    
    return nil;
}

- (void)dealloc
{
	if( _uData ){
		delete [] _uData;
		_uData = nil;
	}
    
	if( _vData ){
		delete [] _vData;
		_vData = nil;
	}
	
	// TODO: dealloc _statistics
	
	if( _ensembleDimension ){
		delete [] _ensembleDimension;
		_ensembleDimension = nil;
	}
	
	if( _ensembleLonLat ){
		delete [] _ensembleLonLat;
		_ensembleLonLat = nil;
	}
}

@end
