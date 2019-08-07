/*!	@header		OVEnsembleData+Statistics.h
	@discussion	Statistics Category for OVEnsembleData. Handles statistics
				computation based on the ensemble data.
	@author		Thomas Höllt
	@updated	2013-07-26 */

#import "OVEnsembleData.h"

@class OVVariable;
@class OVVariable1D;
@class OVVariable2D;

@interface OVEnsembleData (Statistics)

/*!	@method		invalidateStatisticsWithUpdate
	@discussion	Invalidates all statistics (sets isXDirty to YES) and
				updates all views (forcing recomputation of active
				properties) if desired.
	@param	updateViews	BOOL value that forces the update of views after invalidating
				statistics when set to YES.*/
- (void) invalidateStatisticsWithUpdate:(BOOL) updateViews;

/*!	@method		initRanges
    @discussion	Initializes all statistic ranges for proper normalization.*/
//- (void) initRanges;

/*!	@method		initRangesForVariable
    @discussion	Initializes all statistic ranges for proper normalization.
    @param	statistics	OVVariable2D that needs range initialization*/
- (void) initRangesForVariable:(__weak OVVariable2D*) variable;

/*!	@method		updateStatistics
	@discussion	Updates all statistics. Does not invalidate statistics before, so
				statistics that are not marked as dirty will not be recomputed.*/
//- (void) updateStatistics;
- (void) updateStatisticsForVariable:(__weak OVVariable2D*) variable;

/*!	@method		updateHistogram
    @discussion	Updates the histogram. If the histogram is not set dirty beforehand
                nothing is done.*/
//- (void) updateHistogram;
- (void) updateHistogramForVariable:(__weak OVVariable2D*) variable;

/*!	@method		histogramAtPositionX
    @discussion	Get the 1D part of the histogram for a given x,y-position
    @param	x	x-coordinate of the desired position
    @param	y	y-coordinate of the desired position
    @result		Integer pointer to the 1D hisogram for the desired position.*/
//- (int*) histogramAtPositionX:(int) x Y:(int) y;
- (int*) histogramAtPositionX:(int) x Y:(int) y ForVariable:(__weak OVVariable2D*) variable;

/*!	@method		histogramBinToValue
	@discussion	Computes a data value corresponding to a given histogram bin.
	@param	bin	Integer value corresponding to the bin that shall be converted
				to a data value.
	@result		The data value for the given hiostogram bin.*/
//- (float) histogramBinToValue: (int) bin;
- (float) histogramBinToValue: (int) idx WithRangeMin:(float) min RangMax:(float) max;// ForVariable:(OVVariable2D*) variable

/*!	@method		valueToHistogramBin
	@discussion	Computes a histogram bin corresponding to a given data value.
	@param	val	Float value corresponding to the data value that shall be
				assigned to a histogram bin.
	@result		The histogram bin for the given data value.*/
//- (int)	 valueToHistogramBin: (float) val;
- (int)	 valueToHistogramBin: (float) val WithRangeMin:(float) min RangMax:(float) max;// ForVariable:(OVVariable2D*) variable

/*!	@method		updateKDE
	@discussion	Updates the kde. If the kde is not set dirty beforehand
				nothing is done.*/
//- (void) updateKDE;
- (void) updateKDEForVariable:(__weak OVVariable2D*) variable;

/*!	@method		updateMean
	@discussion	Updates the mean data field. If the mean is not set dirty
				beforehand nothing is done.*/
//- (void) updateMean;
- (void) updateMeanForVariable:(__weak OVVariable2D*) variable;

/*!	@method		updateMedian
	@discussion	Updates the median data field. If the mean is not set dirty
				beforehand nothing is done.*/
//- (void) updateMedian;
- (void) updateMedianForVariable:(__weak OVVariable2D*) variable;

/*!	@method		updateMaximumMode
	@discussion	Updates the maximum mode data field. If the mean is not
				set dirty beforehand nothing is done.*/
//- (void) updateMaximumMode;
- (void) updateMaximumModeForVariable:(__weak OVVariable2D*) variable;

/*!	@method		updateRange
	@discussion	Updates the range data field. If the range is not set dirty
				beforehand nothing is done.*/
//- (void) updateRange;
- (void) updateRangeForVariable:(__weak OVVariable2D*) variable;

/*!	@method		updateStandardDeviation
	@discussion	Updates the standard deviation data field. If the standard
				deviation is not set dirty beforehand nothing is done.*/
//- (void) updateStandardDeviation;
- (void) updateStandardDeviationForVariable:(__weak OVVariable2D*) variable;

/*!	@method		updateVariance
	@discussion	Updates the variance data field. If the variance is not set dirty
				beforehand nothing is done.*/
//- (void) updateVariance;
- (void) updateVarianceForVariable:(__weak OVVariable2D*) variable;

/*!	@method		updateRisk
	@discussion	Updates the risk data field. If the risk is not set dirty
				beforehand nothing is done.*/
//- (void) updateRisk;
- (void) updateRiskForVariable:(__weak OVVariable2D*) variable;

/*!	@method		normalizeMean
    @discussion	Normalizes the mean data field.*/
//- (void) normalizeMean;
- (void) normalizeMeanForVariable:(__weak OVVariable2D*) variable;

/*!	@method		normalizeMedian
    @discussion	Normalizes the median data field.*/
//- (void) normalizeMedian;
- (void) normalizeMedianForVariable:(__weak OVVariable2D*) variable;

/*!	@method		normalizeMaximumModeForVariable
    @discussion	Normalizes the max mode data field.*/
//- (void) normalizeMedian;
- (void) normalizeMaximumModeForVariable:(__weak OVVariable2D*) variable;

/*!	@method		normalizeRange
    @discussion	Normalizes the range data field.*/
//- (void) normalizeRange;
- (void) normalizeRangeForVariable:(__weak OVVariable2D*) variable;

/*!	@method		normalizeStandardDeviation
    @discussion	Normalizes the standard deviation data field.*/
//- (void) normalizeStandardDeviation;
- (void) normalizeStandardDeviationForVariable:(__weak OVVariable2D*) variable;

/*!	@method		normalizeVariance
    @discussion	Normalizes the variance data field.*/
//- (void) normalizeVariance;
- (void) normalizeVarianceForVariable:(__weak OVVariable2D*) variable;

/*!	@method		updateMeansTimeSeriesAt
	@discussion	Updates the mean values for the complete time series at a
				given set of coordinates.
	@param	coords	A set of coordinates, one fore each time step.
	@param	side	The side of the glyph the means shall be computed for.*/
- (void) updateMeansTimeSeriesAt:(float*) coords forGlyphSide:(int) side;

/*!	@method		updateMeansTimeSeriesAtLat
	@discussion	Updates the mean values for the complete time series at a
				single given coordinates.
	@param	lat	The latitude of the desired coordinate.
	@param	lon	The longitude of the desired coordinate.
	@param	side	The side of the glyph the means shall be computed for.*/
- (void) updateMeansTimeSeriesAtLat:(float) lat Lon:(float) lon forGlyphSide:(int) side;

/*!	@method		updateRisksTimeSeriesAt
	@discussion	Updates the risk values for the complete time series at a
				given set of coordinates.
	@param	coords	A set of coordinates, one fore each time step.
	@param	side	The side of the glyph the risks shall be computed for.*/
- (void) updateRisksTimeSeriesAt:(float*) coords forGlyphSide:(int) side;

/*!	@method		updateRisksTimeSeriesAtLat
	@discussion	Updates the risk values for the complete time series at a
				single given coordinates.
	@param	lat	The latitude of the desired coordinate.
	@param	lon	The longitude of the desired coordinate.
	@param	side	The side of the glyph the risks shall be computed for.*/
- (void) updateRisksTimeSeriesAtLat:(float) lat Lon:(float) lon forGlyphSide:(int) side;

/*!	@method		updateKdesTimeSeriesAt
	@discussion	Updates the kdes for the complete time series at a
				given set of coordinates.
	@param	coords	A set of coordinates, one fore each time step.
    @param	side	The side of the glyph the kdes shall be computed for.
    @param	variable    The variable the kdes shall be computed for.*/
- (void) updateKdesTimeSeriesAt:(float *)coords forGlyphSide:(int)side forVariable:(__weak OVVariable*) variable;

/*!	@method		updateKdesTimeSeriesAtLat
	@discussion	Updates the kdes for the complete time series at a
				single given coordinates.
	@param	lat	The latitude of the desired coordinate.
	@param	lon	The longitude of the desired coordinate.
	@param	side	The side of the glyph the kdes shall be computed for.*/
//- (void) updateKdesTimeSeriesAtLat:(float) lat Lon:(float) lon forGlyphSide:(int) side;

/*!	@method		updateKdesTimeSeriesAtLat
    @discussion	Updates the kdes for the complete time series at a
                single given coordinates.
    @param	lat	The latitude of the desired coordinate.
    @param	lon	The longitude of the desired coordinate.
    @param	side	The side of the glyph the kdes shall be computed for.
    @param	variable    The variable the kdes shall be computed for.*/
- (void) updateKdesTimeSeriesAtLat:(float)lat Lon:(float)lon forGlyphSide:(int)side forVariable:(__weak OVVariable*) variable;

@end
