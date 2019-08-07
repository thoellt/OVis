//
//	OVEnsembleData+Statistics.mm
//

// Custom Headers
#import "OVStatistic.h"
#import "OVHistogram.h"
#import "OVVariable.h"
#import "OVVariable1D.h"
#import "OVVariable2D.h"

#include <mach/mach_time.h>

// Local Header
#import "OVEnsembleData+Statistics.h"

@implementation OVEnsembleData (Statistics)

#pragma mark - Statistics Handling

- (void) invalidateStatisticsWithUpdate:(BOOL) updateViews
{
    for( OVVariable2D* variable in _variables2D )
    {
        [variable invalidate];
    }
	
	if( updateViews )
    {
        [_appDelegate refreshAllViewsFromData];
    }
}
/*
- (void) initRanges
{
    [self initRangesForStatisticSet:_statisticSet];
}*/

- (void) initRangesForVariable:(__weak OVVariable2D*) variable
{
    BOOL tmpShowSingle[2] = {_timeShowSingle, _memberShowSingle};
    int tmpRanges[3] = {_timeSingleId, _memberRangeMin, _memberRangeMax};
    
    _timeShowSingle = YES;
    _memberShowSingle = NO;
    _memberRangeMin = 0;
    _memberRangeMax = (int)(_ensembleDimension->m) - 1;
    
    _isInitRun = YES;

	variable.mean.range[0] = -9999.9f;
    variable.mean.range[1] = 9999.9f;
	
    variable.median.range[0] = -9999.9f;
    variable.median.range[1] = 9999.9f;
	
    variable.maximumMode.range[0] = -9999.9f;
    variable.maximumMode.range[1] = 9999.9f;
	
    variable.range.range[0] = -9999.9f;
    variable.range.range[1] =	9999.9f;
	
    variable.standardDeviation.range[0] = -9999.9f;
    variable.standardDeviation.range[1] =	9999.9f;
	
    variable.variance.range[0] = -9999.9f;
    variable.variance.range[1] =	9999.9f;
	
    variable.risk.range[0] = 0.0f;
    variable.risk.range[1] = 1.0f;
    
    NSInteger timeSteps = variable.isTimeStatic ? 1 : _ensembleDimension->t;
    for( _timeSingleId = 0; _timeSingleId < timeSteps; _timeSingleId++)
    {
        [self updateStatisticsForVariable:variable];
    }
    
    NSLog(@"Mean Range is [%f .. %f].",variable.mean.range[1],variable.mean.range[0]);
    NSLog(@"Median Range is [%f .. %f].",variable.median.range[1],variable.median.range[0]);
    NSLog(@"Range Range is [%f .. %f].",variable.range.range[1],variable.range.range[0]);
    NSLog(@"Standard Deviation Range is [%f .. %f].",variable.standardDeviation.range[1],variable.standardDeviation.range[0]);
    NSLog(@"Variance Range is [%f .. %f].",variable.variance.range[1],variable.variance.range[0]);
    
    _isInitRun = NO;
    
    _timeShowSingle = tmpShowSingle[0];
    _memberShowSingle = tmpShowSingle[1];
    _timeSingleId = tmpRanges[0];
    _memberRangeMin = tmpRanges[1];
    _memberRangeMax = tmpRanges[2];
}
/*
- (void) updateStatistics
{
    [self updateStatisticsForStatisticSet:_statisticSet];
}*/

- (void) updateStatisticsForVariable:(__weak OVVariable2D *) variable
{
	[self updateHistogramForVariable:variable];
	[self updateKDEForVariable:variable];
	[self updateMeanForVariable:variable];
	[self updateMedianForVariable:variable];
	[self updateMaximumModeForVariable:variable];
	[self updateRangeForVariable:variable];
	[self updateStandardDeviationForVariable:variable];
	[self updateVarianceForVariable:variable];
	[self updateRiskForVariable:variable];
}

#pragma mark - Basic Statistics
/*
- (void) updateHistogram
{
    [self updateHistogramForVariable:_variables2D[0]];
}*/

- (void) updateHistogramForVariable:(__weak OVVariable2D*) variable
{
	// Early out if no update necessary
	if( !variable.histogram.isDirty ) return;
    
    [variable.histogram rebuildDataWithSize:variable.dimension->x * variable.dimension->y * _histogramBins];
	
	// adjust loop variables variables
	int minT = variable.isTimeStatic ? 0 : ( _timeShowSingle ? _timeSingleId : _timeRangeMin );
	int maxT = variable.isTimeStatic ? 0 : ( _timeShowSingle ? _timeSingleId : _timeRangeMax );
	int minM = variable.isMemberStatic ? 0 : ( _memberShowSingle ? _memberSingleId : _memberRangeMin );
	int maxM = variable.isMemberStatic ? 0 : ( _memberShowSingle ? _memberSingleId : _memberRangeMax );
	
    float* data = variable.data;
    float* dataRange = variable.dataRange;
    int* histogram = variable.histogram.data;
    
    size_t surfaceSize = _ensembleDimension->x * _ensembleDimension->y;
    size_t timestepSize = surfaceSize * _ensembleDimension->m;
    
    // parallel call. replaces for loop
    dispatch_apply(surfaceSize, dispatch_get_global_queue(0, 0), ^(size_t i)
    //for( int i = 0; i < surfaceSize; i++ )
    {
        if( !self->_isStructured || self->_validEntries[i] ){
            for( int t = minT; t <= maxT; t++ ){
                for( int m = minM; m <= maxM; m++){
                   
                    float v = data[ t * timestepSize + m * surfaceSize + i ];
                    int idx = [self valueToHistogramBin:v WithRangeMin:dataRange[0] RangMax: dataRange[1]];
                   
                    assert( idx < self->_histogramBins && idx > -1 );
                   
                    histogram[idx + i * self->_histogramBins]++;
                }
            }
        }
    }
    );
    
    
	
	if( !_isInitRun )
    {
        variable.histogram.isKdeDirty = NO;
    }
}

/*- (int*) histogramAtPositionX:(int) x Y:(int) y
{

}*/

- (int*) histogramAtPositionX:(int) x Y:(int) y ForVariable:(__weak OVVariable2D*) variable
{
    [self updateHistogramForVariable:variable];
    
    if( _histogram1D ){
        delete [] _histogram1D;
        _histogram1D = nil;
    }
    _histogram1D = new int[_histogramBins];
    memset( _histogram1D, 0, _histogramBins * sizeof(int) );
    
    size_t offset = 0;
    
    if( _isStructured ){
        offset = _histogramBins * y * _ensembleDimension->x + _histogramBins * x;
    } else {
        offset = _histogramBins * x;
    }
    memcpy(_histogram1D, &variable.histogram.data[offset], _histogramBins * sizeof(int));
    
    return _histogram1D;
}

- (float) histogramBinToValue: (int) idx WithRangeMin:(float) min RangMax:(float) max// ForVariable:(OVVariable2D*) variable
{
	//float absMax = MAX( fabsf(min), fabsf(max));
	//float val = (((float)idx / (float)(_histogramBins-1)) * (2 * absMax)) - absMax;
    float r = max - min;
    float val = (((float)idx+0.5 / (float)(_histogramBins)) * r) + min;

    //NSLog(@"hist idx %d = %f", idx, val);
	return val;
}

- (int) valueToHistogramBin: (float) val WithRangeMin:(float) min RangMax:(float) max// ForVariable:(OVVariable2D*) variable
{
	//float absMax = MAX( fabsf(min), fabsf(max));
    //int idx = MAX(0, MIN(int( ( ( val + absMax ) / (2 * absMax) ) * (_histogramBins-1) ), (_histogramBins-1)));
    float r = max - min;
    int idx = MAX(0, MIN(int( ( ( val - min ) / r ) * (_histogramBins) ), (_histogramBins-1)));
	return idx;
    
    
}

- (void) updateKDEForVariable:(__weak OVVariable2D*) variable
{
	// Early out if no update necessary
	if( !variable.histogram.isKdeDirty ) return;
	
}

#pragma mark - Surface Statistics

- (void) updateMeanForVariable:(__weak OVVariable2D*) variable
{
	// Early out if no update necessary
	if( !variable.mean.isDirty ) return;
    
    [variable.mean rebuildDataWithSize:_isStructured ? variable.dimension->x * variable.dimension->y : _ensembleDimension->texX * _ensembleDimension->texY];
	
	// adjust loop variables variables
	int minT = variable.isTimeStatic ? 0 : ( _timeShowSingle ? _timeSingleId : _timeRangeMin );
	int maxT = variable.isTimeStatic ? 0 : ( _timeShowSingle ? _timeSingleId : _timeRangeMax );
	int minM = variable.isMemberStatic ? 0 : ( _memberShowSingle ? _memberSingleId : _memberRangeMin );
    int maxM = variable.isMemberStatic ? 0 : ( _memberShowSingle ? _memberSingleId : _memberRangeMax );
    
    float* data = variable.data;
    float* mean = variable.mean.data;
    float* meanRange = variable.mean.range;
    
    size_t surfaceSize = _ensembleDimension->x * _ensembleDimension->y;
    size_t timestepSize = surfaceSize * _ensembleDimension->m;
	
	// parallel call. replaces for loop
	dispatch_apply(variable.mean.size, dispatch_get_global_queue(0, 0), ^(size_t i)
	//for( int i = 0; i < variable.mean.size; i++ )
	{
		if( !self->_isStructured || self->_validEntries[i] )
		{
			mean[i] = 0.0f;
			int count = 0;
            
			for( int t = minT; t <= maxT; t++ ){
				for( int m = minM; m <= maxM; m++ ){
				
					mean[i] += data[ t * timestepSize + m * surfaceSize + i ];
					count++;
				}
			}
		
			mean[i] /= (float)count;
		}
		else
			mean[i] = 99999.9f;
	}
	);
	
	// find min max values
    if( _isInitRun )
    {
        for( int i = 0; i < variable.mean.size; i++ )
        {
            if( !_isStructured || _validEntries[i]){
                meanRange[0] = MAX(mean[i], meanRange[0]);
                meanRange[1] = MIN(mean[i], meanRange[1]);
            }
        }
        memcpy(variable.mean.limits, meanRange, 2 * sizeof(float));
    }
    else
    {
        variable.mean.isDirty = NO;
        [variable.mean normalize];
    }
    
}

- (void) normalizeMeanForVariable:(__weak OVVariable2D*) variable
{
    [self updateMeanForVariable:variable];
    [variable.mean normalize];
}

- (void) updateMedianForVariable:(__weak OVVariable2D*) variable
{
	// Early out if no update necessary
	if( !variable.median.isDirty ) return;
	
	// Dependencies
	[self updateHistogramForVariable:variable];
    
    [variable.median rebuildDataWithSize:_isStructured ? variable.dimension->x * variable.dimension->y : _ensembleDimension->texX * _ensembleDimension->texY];
	
	// adjust loop variables variables
	int minT = variable.isTimeStatic ? 0 : ( _timeShowSingle ? _timeSingleId : _timeRangeMin );
	int maxT = variable.isTimeStatic ? 0 : ( _timeShowSingle ? _timeSingleId : _timeRangeMax );
	int minM = variable.isMemberStatic ? 0 : ( _memberShowSingle ? _memberSingleId : _memberRangeMin );
	int maxM = variable.isMemberStatic ? 0 : ( _memberShowSingle ? _memberSingleId : _memberRangeMax );
    int medianIdx = (int)((maxT - minT + 1) * (maxM - minM + 1)) / 2;
    
    int* histogram = variable.histogram.data;
    float* dataRange = variable.dataRange;
    float* median = variable.median.data;
    float* medianRange = variable.median.range;
    
    size_t surfaceSize = _ensembleDimension->x * _ensembleDimension->y;
	
	// parallel call. replaces for loop
	dispatch_apply(surfaceSize, dispatch_get_global_queue(0, 0), ^(size_t i)
	//for( int i = 0; i < surfaceSize; i++ )
	{
		if( !self->_isStructured || self->_validEntries[i] )
		{
			median[i] = 0.0f;
			int count = 0;
			
			for( int h = 0; h < self->_histogramBins; h++ ){
				
				count += histogram[h + i * self->_histogramBins];
				
				if( count > medianIdx )
				{
					median[i] = [self histogramBinToValue:h WithRangeMin:dataRange[0] RangMax: dataRange[1]];
					break;
				}
			}
		}
		else
			median[i] = 99999.9f;
	}
	);
    
	// find min max values
    if( _isInitRun )
    {
        for( int i = 0; i < surfaceSize; i++ )
        {
            if( !_isStructured || _validEntries[i] ){
                medianRange[0] = MAX(median[i], medianRange[0]);
                medianRange[1] = MIN(median[i], medianRange[1]);
            }
        }
        memcpy(variable.median.limits, medianRange, 2 * sizeof(float));
    }
    else
    {
        variable.median.isDirty = NO;
        [variable.median normalize];
    }
}

- (void) normalizeMedianForVariable:(__weak OVVariable2D*) variable
{
    [self updateMedianForVariable:variable];
    [variable.median normalize];
}

- (void) updateMaximumModeForVariable:(__weak OVVariable2D*) variable
{
    // Early out if no update necessary
    if( !variable.maximumMode.isDirty ) return;
    
    // Dependencies
    [self updateHistogramForVariable:variable];
    
    [variable.maximumMode rebuildDataWithSize:_isStructured ? variable.dimension->x * variable.dimension->y : _ensembleDimension->texX * _ensembleDimension->texY];
    
    int* histogram = variable.histogram.data;
    float* dataRange = variable.dataRange;
    float* maximumMode = variable.maximumMode.data;
    float* maximumModeRange = variable.maximumMode.range;
    
    size_t surfaceSize = _ensembleDimension->x * _ensembleDimension->y;
    
    // parallel call. replaces for loop
    dispatch_apply(surfaceSize, dispatch_get_global_queue(0, 0), ^(size_t i)
    //for( int i = 0; i < surfaceSize; i++ )
    {
       if( !self->_isStructured || self->_validEntries[i] )
       {
           int maxMode = 0;
           int index = 0;
           
           for( int h = 0; h < self->_histogramBins; h++ ){
               
               int mode = histogram[h + i * self->_histogramBins];
               if( mode > maxMode )
               {
                   maxMode = mode;
                   index = h;
               }
           }
           
           maximumMode[i] = [self histogramBinToValue:index WithRangeMin:dataRange[0] RangMax: dataRange[1]];
       }
       else
           maximumMode[i] = 99999.9f;
    }
    );
    
    // find min max values
    if( _isInitRun )
    {
        for( int i = 0; i < surfaceSize; i++ )
        {
            if( !_isStructured || _validEntries[i] ){
                maximumModeRange[0] = MAX(maximumMode[i], maximumModeRange[0]);
                maximumModeRange[1] = MIN(maximumMode[i], maximumModeRange[1]);
            }
        }
        memcpy(variable.maximumMode.limits, maximumModeRange, 2 * sizeof(float));
    }
    else
    {
        variable.maximumMode.isDirty = NO;
        [variable.maximumMode normalize];
    }
}

- (void) normalizeMaximumModeForVariable:(__weak OVVariable2D *)variable
{
    [self updateMaximumModeForVariable:variable];
    [variable.maximumMode normalize];
}

- (void) updateRangeForVariable:(__weak OVVariable2D *)variable
{
	// Early out if no update necessary
	if( !variable.range.isDirty ) return;
    
    [variable.range rebuildDataWithSize:_isStructured ? variable.dimension->x * variable.dimension->y : _ensembleDimension->texX * _ensembleDimension->texY];
	
	// adjust loop variables variables
	int minT = variable.isTimeStatic ? 0 : ( _timeShowSingle ? _timeSingleId : _timeRangeMin );
	int maxT = variable.isTimeStatic ? 0 : ( _timeShowSingle ? _timeSingleId : _timeRangeMax );
	int minM = variable.isMemberStatic ? 0 : ( _memberShowSingle ? _memberSingleId : _memberRangeMin );
    int maxM = variable.isMemberStatic ? 0 : ( _memberShowSingle ? _memberSingleId : _memberRangeMax );
    
    float* data = variable.data;
    float* range = variable.range.data;
    float* rangeRange = variable.range.range;
    
    size_t surfaceSize = _ensembleDimension->x * _ensembleDimension->y;
    size_t timestepSize = surfaceSize * _ensembleDimension->m;
    
    // parallel call. replaces for loop
    dispatch_apply(surfaceSize, dispatch_get_global_queue(0, 0), ^(size_t i)
    //for( int i = 0; i < surfaceSize; i++ )
    {
        if( !self->_isStructured || self->_validEntries[i] )
        {
           float maxVal = 0.0f;
           float minVal = 99999.9f;
           
           for( int t = minT; t <= maxT; t++ ){
               for( int m = minM; m <= maxM; m++ ){
                   
                   float v = data[ t * timestepSize + m * surfaceSize + i ];
                   maxVal = MAX(v, maxVal);
                   minVal = MIN(v, minVal);
               }
           }
           
           range[i] = maxVal - minVal;
        }
        else
           range[i] = 99999.9f;
    }
    );
	
	// find min max values
    if( _isInitRun )
    {
        for( int i = 0; i < surfaceSize; i++ )
        {
            if( !_isStructured || _validEntries[i] ){
                rangeRange[0] = MAX(range[i], rangeRange[0]);
                rangeRange[1] = MIN(range[i], rangeRange[1]);
            }
        }
        memcpy(variable.range.limits, rangeRange, 2 * sizeof(float));
    }
    else
	{
        variable.range.isDirty = NO;
        [self normalizeRangeForVariable:variable];
    }
}

- (void) normalizeRangeForVariable:(__weak OVVariable2D *)variable
{
    [self updateRangeForVariable:variable];
    [variable.range normalize];
}

- (void) updateStandardDeviationForVariable:(__weak OVVariable2D *)variable
{
	// Early out if no update necessary
	if( !variable.standardDeviation.isDirty ) return;
	
	// Dependencies
	[self updateVarianceForVariable:variable];
    
    [variable.standardDeviation rebuildDataWithSize:_isStructured ? variable.dimension->x * variable.dimension->y : _ensembleDimension->texX * _ensembleDimension->texY];
    
    float* variance = variable.variance.data;
    float* standardDeviation = variable.standardDeviation.data;
    float* standardDeviationRange = variable.standardDeviation.range;
    
    size_t surfaceSize = _ensembleDimension->x * _ensembleDimension->y;
	
	// parallel call. replaces for loop
	dispatch_apply(surfaceSize, dispatch_get_global_queue(0, 0), ^(size_t i)
	//for( int i = 0; i < surfaceSize; i++ )
	{
		if( !self->_isStructured || self->_validEntries[i] )
		{
			float var = variance[i];
			standardDeviation[i] = sqrtf(var);
		}
		else
			standardDeviation[i] = 99999.9f;
	}
	);
	
	// find min max values
    if( _isInitRun )
    {
        for( int i = 0; i < surfaceSize; i++ )
        {
            if( !_isStructured || _validEntries[i] ){
                standardDeviationRange[0] = MAX(standardDeviation[i], standardDeviationRange[0]);
                standardDeviationRange[1] = MIN(standardDeviation[i], standardDeviationRange[1]);
            }
        }
        memcpy(variable.standardDeviation.limits, standardDeviationRange, 2 * sizeof(float));
    }
    else
    {
        variable.standardDeviation.isDirty = NO;
        [variable.standardDeviation normalize];
    }
}

- (void) normalizeStandardDeviationForVariable:(__weak OVVariable2D *)variable
{
    [self updateStandardDeviationForVariable:variable];
    [variable.standardDeviation normalize];
}

- (void) updateVarianceForVariable:(OVVariable2D *)variable
{
	// Early out if no update necessary
	if( !variable.variance.isDirty ) return;
	
	// Dependencies
	[self updateMeanForVariable:variable];
    
    [variable.variance rebuildDataWithSize:_isStructured ? variable.dimension->x * variable.dimension->y : _ensembleDimension->texX * _ensembleDimension->texY];
	
	int minT = variable.isTimeStatic ? 0 : ( _timeShowSingle ? _timeSingleId : _timeRangeMin );
	int maxT = variable.isTimeStatic ? 0 : ( _timeShowSingle ? _timeSingleId : _timeRangeMax );
	int minM = variable.isMemberStatic ? 0 : ( _memberShowSingle ? _memberSingleId : _memberRangeMin );
    int maxM = variable.isMemberStatic ? 0 : ( _memberShowSingle ? _memberSingleId : _memberRangeMax );
    
    float* data = variable.data;
    float* mean = variable.mean.data;
    float* variance = variable.variance.data;
    float* varianceRange = variable.variance.range;
    
    size_t surfaceSize = _ensembleDimension->x * _ensembleDimension->y;
    size_t timestepSize = surfaceSize * _ensembleDimension->m;
	
	// parallel call. replaces for loop
	dispatch_apply(surfaceSize, dispatch_get_global_queue(0, 0), ^(size_t i)
	//for( int i = 0; i < surfaceSize; i++ )
	{
		if( !self->_isStructured || self->_validEntries[i] )
		{
			variance[i] = 0.0f;
			int count = 0;
			
			float meanVal = mean[i];
			
			for( int t = minT; t <= maxT; t++ ){
				for( int m = minM; m <= maxM; m++ ){
					
					float v = data[ t * timestepSize + m * surfaceSize + i ] - meanVal;
					variance[i] += v*v;
					
					count++;
				}
			}
			
			variance[i] /= count;
		}
		else
			variance[i] = 99999.9f;
	}
	);
	
	// find min max values
    if( _isInitRun )
    {
        for( int i = 0; i < surfaceSize; i++ )
        {
            if( !_isStructured || _validEntries[i] ){
                varianceRange[0] = MAX(variance[i], varianceRange[0]);
                varianceRange[1] = MIN(variance[i], varianceRange[1]);
            }
        }
        memcpy(variable.variance.limits, varianceRange, 2 * sizeof(float));
    }
    else
    {
        variable.variance.isDirty = NO;
        [variable.variance normalize];
    }
}

- (void) normalizeVarianceForVariable:(__weak OVVariable2D *)variable
{
    [self updateVarianceForVariable:variable];
    [variable.variance normalize];
}

- (void) updateRiskForVariable:(__weak OVVariable2D *)variable
{
	// Early out if no update necessary
	if( !variable.risk.isDirty ) return;
    
    [variable.risk rebuildDataWithSize:_isStructured ? variable.dimension->x * variable.dimension->y : _ensembleDimension->texX * _ensembleDimension->texY];
	
	// adjust loop variables variables
	int minT = variable.isTimeStatic ? 0 : ( _timeShowSingle ? _timeSingleId : _timeRangeMin );
	int maxT = variable.isTimeStatic ? 0 : ( _timeShowSingle ? _timeSingleId : _timeRangeMax );
	int minM = variable.isMemberStatic ? 0 : ( _memberShowSingle ? _memberSingleId : _memberRangeMin );
    int maxM = variable.isMemberStatic ? 0 : ( _memberShowSingle ? _memberSingleId : _memberRangeMax );
    
    float* data = variable.data;
    float* risk = variable.risk.data;
    float* riskNorm = variable.risk.dataNormalized;
    
    size_t surfaceSize = _ensembleDimension->x * _ensembleDimension->y;
	size_t timestepSize = surfaceSize * _ensembleDimension->m;
	
	float critHeight = [self riskHeightIsoValue];
	
	// parallel call. replaces for loop
	dispatch_apply(surfaceSize, dispatch_get_global_queue(0, 0), ^(size_t i)
	//for( int i = 0; i < surfaceSize; i++ )
	{
		 if( !self->_isStructured || self->_validEntries[i] )
		 {
			 int count = 0;

			 for( int t = minT; t <= maxT; t++ ){
				 for( int m = minM; m <= maxM; m++ ){
					 
					 float v = data[ t * timestepSize + m * surfaceSize + i ];
					 
					 if( v > critHeight ){
						 count++;
					 }
				 }
			 }
			 
			 // write scaled value
			 risk[ i ] = (float)count / self->_ensembleDimension->m;
             riskNorm[ i ] = variable.risk.data[ i ];
		 }
	}
	);
	
	variable.risk.isDirty = NO;
}

#pragma mark - Time Series Statistics

- (void) updateMeansTimeSeriesAt:(float*) coords forGlyphSide:(int)side
{
}

- (void) updateMeansTimeSeriesAtLat:(float)lat Lon:(float)lon forGlyphSide:(int)side
{
    int numTimesteps = _timeRangeMax - _timeRangeMin + 1;
    float *p = new float[numTimesteps * 2];
	for( int i = 0; i < numTimesteps; i++ )
	{
		p[2*i] = lat;
		p[2*i+1] = lon;
	}
	[self updateMeansTimeSeriesAt:p forGlyphSide:side];
}


- (void) updateRisksTimeSeriesAt:(float *)coords forGlyphSide:(int)side
{
    // TODO VAR
    OVVariable2D* variable = [_variables2D count] > 0 ? _variables2D[0] : nil;
    
    int numTimesteps = _timeRangeMax - _timeRangeMin + 1;
    
	// reset datafield
	if( _tsRisks[side] != NULL ){
		delete[] _tsRisks[side];
		_tsRisks[side] = NULL;
	}
	
	_tsRisks[side] = new float[ numTimesteps ];
	memset( _tsRisks[side], 0, numTimesteps * sizeof(float) );
	
	float critHeight = [self riskHeightIsoValue];
	
	// loop over all runs ...
	size_t surfaceSize = _ensembleDimension->x * _ensembleDimension->y;
	for( int t = 0; t < numTimesteps; t++ ){
		
		assert( coords );
		int x,y;
        if( _isStructured )
        {
            x = [self gridXFromLon:coords[ 2 * t + 1 ]];
            y = [self gridYFromLat:coords[ 2 * t	 ]];
        } else {
            x = [self unstructuredIndexFromLon:coords[ 2 * t + 1 ] Lat:coords[ 2 * t ]];
            y = 0;
        }
		
		if( x >= 0.0f && x < _ensembleDimension->x && y >= 0.0f && y < _ensembleDimension->y ){
			
			// skip positions without entries
			if( !_isStructured || _validEntries[ x + y * _ensembleDimension->x ] ){
				
				int count = 0;
				
				// loop over all ensemble runs ...
				for( int m = 0; m < _ensembleDimension->m; m++ ){
					
					int runIdx = (_timeRangeMin + t) * (int)(_ensembleDimension->m) + m;
					
					assert( x + y * _ensembleDimension->x + runIdx * surfaceSize < _ensembleDimension->size );
					assert( x + y * _ensembleDimension->x + runIdx * surfaceSize >= 0);
					float v = variable.data[ x + y * _ensembleDimension->x + runIdx * surfaceSize ];
					
					if( v > critHeight ){
						count++;
					}
				}
				
				// write scaled value
				_tsRisks[ side ][ t ] = (float)count / _ensembleDimension->m;
			}
		}
	}
}

- (void) updateRisksTimeSeriesAtLat:(float)lat Lon:(float)lon forGlyphSide:(int)side
{
	float *coords = new float[_ensembleDimension->t * 2];
	for( int i = 0; i < _ensembleDimension->t; i++ )
	{
		coords[2*i] = lat;
		coords[2*i+1] = lon;
	}
	[self updateRisksTimeSeriesAt:coords forGlyphSide:side];
    
    delete[] coords;
}

int floatcomp(const void* elem1, const void* elem2)
{
    if(*(const float*)elem1 < *(const float*)elem2)
        return -1;
    return *(const float*)elem1 > *(const float*)elem2;
}

- (void) updateKdesTimeSeriesAt:(float *)coords forGlyphSide:(int)side forVariable:(__weak OVVariable*) variable
{
	assert( side == 0 || side == 1 );
	
	int g = 3;
	float gauss[ 7 ] =	{
		0.00006962652597338441,
		0.010333492677046717,
		0.20755374871030083,
		0.5641895835477563,
		0.20755374871030083,
		0.010333492677046717,
		0.00006962652597338441,
	};
    
    NSInteger numTimeSteps = [self numTimeStepsWithStride];//(_timeRangeMax - _timeRangeMin + 1) / _timeStepStride;
    size_t kdeSize = numTimeSteps* _histogramBins;
	
	// reset datafields
	if( _tsKdes[side] != NULL ){
		delete[] _tsKdes[side];
		_tsKdes[side] = NULL;
    }
    _tsKdes[side] = new float[ kdeSize ];
    memset( _tsKdes[side], 0, kdeSize * sizeof(float) );
    
    if( _tsMeans[side] != NULL ){
        delete[] _tsMeans[side];
        _tsMeans[side] = NULL;
    }
    _tsMeans[side] = new float[ numTimeSteps ];
    memset( _tsMeans[side], 0, numTimeSteps * sizeof(float) );
    
    for( int i = 0; i < 11; i++ )
    {
        if( _tsPercentiles[i][side] != NULL ){
            delete[] _tsPercentiles[i][side];
            _tsPercentiles[i][side] = NULL;
        }
        _tsPercentiles[i][side] = new float[ numTimeSteps ];
        memset( _tsPercentiles[i][side], 0, numTimeSteps * sizeof(float) );
    }

    // Early out if no variable passed
    if( !variable ) return;
    
    NSInteger countTimesteps = [variable isTimeStatic] ? 1 : numTimeSteps;
    NSInteger offsetTimesteps = [variable isTimeStatic] ? 0 : _timeRangeMin;
    NSInteger countMembers = [variable isMemberStatic] ? 1 : _memberRangeMax - _memberRangeMin + 1;
    NSInteger offsetMembers = [variable isMemberStatic] ? 0 : _memberRangeMin;
	
	// full scale histograms
	int* histos = new int[ countTimesteps * _histogramBins ];
	memset( histos, 0, countTimesteps * _histogramBins * sizeof(int) );
	
    float rangeSize = variable.dataRange[0] - variable.dataRange[1];
    size_t surfaceSize = variable.dimension->x * variable.dimension->y;
    float* variableData = variable.data;
    
    // loop over all runs ...
    for( int t = 0; t < numTimeSteps; t++ ){
        
        int tFull = t * _timeStepStride;
        
        assert( coords );
        int x = 0; int y = 0;
        if( variable.dimensionality > 1 )
        {
            if( _isStructured )
            {
                x = [self gridXFromLon:coords[ 2 * tFull + 1 ]];
                y = [self gridYFromLat:coords[ 2 * tFull	 ]];
            } else {
                x = [self unstructuredIndexFromLon:coords[ 2 * tFull + 1 ] Lat:coords[ 2 * tFull ]];
                y = 0;
            }
        }
        
        float mean = 0.0f;
        
        if( x >= 0 && x < variable.dimension->x && y >= 0 && y < variable.dimension->y )
        {
            if( variable.dimensionality < 2 || !_isStructured || _validEntries[ x + y * _ensembleDimension->x ] )
            {
                if( t == 0 || ![variable isTimeStatic] )
                {
                    float* sortedMembers = new float[countMembers];
                    
                    // loop over all ensemble runs ...
                    for( int m = 0; m < countMembers; m++ )
                    {
                        size_t runIdx = (offsetTimesteps + tFull) * variable.dimension->m + (offsetMembers + m);
                        
                        assert( x + y * variable.dimension->x + runIdx * surfaceSize < _ensembleDimension->size );
                        assert( x + y * variable.dimension->x + runIdx * surfaceSize >= 0);
                        float v = variableData[ x + y * variable.dimension->x + runIdx * surfaceSize ];
                        float vNorm = rangeSize != 0 ? (( v - variable.dataRange[1] ) / rangeSize) : 0.0f;
                        
                        mean += vNorm;
                        sortedMembers[m] = vNorm;
                        
                        int idx = vNorm * (_histogramBins - 1) + 0.5;// MIN( v, m_ensemble_dim[0] - 1 );
                        
                        histos[ t * _histogramBins + idx ]++;
                    }
                    
                    // compute percentiles
                    qsort(sortedMembers, countMembers, sizeof(float), floatcomp);
                    for( int p = 0; p < 11; p++ )
                    {
                        _tsPercentiles[p][side][t] = sortedMembers[(int)(p * 0.1 * (countMembers-1))];
                    }

                    mean /= countMembers;
                    _tsMeans[side][t] = mean;
                    
                    int tOff = t * _histogramBins;
                    
                    float maxV = 0.0f;
                    
                    // compute kde
                    for( int h = 0; h < _histogramBins; h++ ){
                        
                        int idx = tOff + h;
                        
                        for( int i = -g; i <= g; i++ ){
                            
                            int hIdx = tOff + OVClamp(0, h+i, _histogramBins - 1);
                            
                            float v = _tsKdes[side][ idx ] + (float)(histos[ hIdx ]) * gauss[ i + g ];
                            
                            _tsKdes[side][ idx ] = v;
                            
                            // track max
                            if( v > maxV ) maxV = v;
                        }
                    }
                    
                    // scale vals to 0..1
                    for( int k = tOff; k < tOff + _histogramBins; k++ ){
                        
                        _tsKdes[side][ k ] /= maxV;
                    }
                }
                else
                {
                    // t is static we can copy from first run
                    _tsMeans[side][t] = mean;
                    memcpy( &_tsKdes[side][t * _histogramBins], &_tsKdes[side][0], _histogramBins * sizeof(float));
                    
                    for( int p = 0; p < 11; p++ )
                    {
                        _tsPercentiles[p][side][t] = _tsPercentiles[p][side][0];
                    }
                }
            }
        }
    }
	
	delete[] histos;
}

- (void) updateKdesTimeSeriesAtLat:(float)lat Lon:(float)lon forGlyphSide:(int)side forVariable:(__weak OVVariable*) variable;
{
    int numTimesteps = _timeRangeMax - _timeRangeMin + 1;
    float *coords = new float[numTimesteps * 2];
	for( int i = 0; i < numTimesteps; i++ )
	{
		coords[2*i] = lat;
		coords[2*i+1] = lon;
	}
	[self updateKdesTimeSeriesAt:coords forGlyphSide:side forVariable:variable];
    
    delete[] coords;
}
/*
- (void) updateKdesTimeSeriesAtLat:(float)lat Lon:(float)lon forGlyphSide:(int)side
{
    [self updateKdesTimeSeriesAtLat:lat Lon:lon forGlyphSide:side forVariable:nil];
}*/

@end
