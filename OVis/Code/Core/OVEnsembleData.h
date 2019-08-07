/*!	@header		OVEnsembleData.h
	@discussion	This class encapsules the ensemble data, including loader,
				statistics computation. Additionaly it is extended to hold off
				shore platforms and paths (tbd).
	@author		Thomas Höllt
	@updated	2013-07-26 */

// System Headers
#import <Foundation/Foundation.h>

#import <vector>

// Custom Headers
#import "general.h"
#import "OVAppDelegateProtocol.h"

// Friend Classes
@class OVPathlineRenderer;
@class OVVariable2D;

/*!	@class		OVEnsembleData
	@discussion	This class encapsules the ensemble data, including loader,
				statistics computation. Additionaly it is extended to hold off
				shore platforms and paths (tbd).*/
@interface OVEnsembleData : NSObject{

@private

	id<OVAppDelegateProtocol> _appDelegate;
	
	// Ensemble
    BOOL    _isLoaded;
	BOOL	_isStructured;
    
    NSMutableArray* _variables1D;
    NSMutableArray* _variables2D;
	
    float   _invalidValue;
    BOOL    _invalidAvailable;
	int		_numberValids;
	BOOL*	_validEntries;
    
    NSDate* _startDate;
    NSDateComponents* _timeStepLength;
	
	// Vector data
	float*	_uData;
	float*	_vData;
	BOOL _isVectorFieldAvailable;
	
	std::vector<Vector3> _normalizedPathlines;
	std::vector<Vector4> _pathlineColors;
    
    int _pathlineResolution;
    float _pathlineAlphaScale;
    
    float _pathlineStartX;
    float _pathlineStartY;
    float _pathlineStartZ;
    
    float _pathlinepPogressionFactor;
    float _assimilationCycleLength;
	
	EnsembleDimension*	_ensembleDimension;
	EnsembleLonLat*		_ensembleLonLat;
	
	// unstructured
	float*			_nodes;
	unsigned int*	_gridIndices;
    
    unsigned char*  _indexLookup;
    int _indexLookupWidth;
    int _indexLookupHeight;
	
	int	_numNodes;
	int	_numTriangles;
	
	// Statistics
	int		_memberRangeMin;
	int		_memberRangeMax;
	BOOL	_memberShowSingle;
	int		_memberSingleId;
	
	int		_timeRangeMin;
	int		_timeRangeMax;
    BOOL	_timeShowSingle;
    int		_timeSingleId;
    
    int		_timeStepStride;
	
	int		_histogramBins;
	
	// Risk
	float	_riskHeightIsoValue;
	float	_riskIsoValue;
	
	// Statistics Data
    BOOL    _isInitRun;
    
	int*	_histogram1D;
    
    float*	_tsMeans[2];
    float*	_tsPercentiles[11][2];
	float*	_tsRisks[2];
	
	float*	_tsKdes[2];
	float*	_tsKdeSizes[2];
    
    OVPathlineRenderer* _pathlineRenderer;
    GLuint _pathlineTexture;
	
	// Platforms
	NSString*				_activePlatform;
	NSMutableDictionary*	_platforms;
}

/*!	@property	isLoaded
    @brief		BOOL flag indicating whether the data was loaded.*/
@property (nonatomic) BOOL isLoaded;

/*!	@property	isStructured
    @brief		BOOL flag indicating whether the data is structured or unstructured.*/
@property (nonatomic) BOOL isStructured;

/*!	@property	isVectorFieldAvailable
	@brief		BOOL flag indicating whether the data contains vector data.*/
@property (nonatomic) BOOL isVectorFieldAvailable;

/*!	@property	normalizedPathlines
	@brief		STL Vector containing the normalized pathlines for rendering.*/
@property (nonatomic) std::vector<Vector3> normalizedPathlines;

/*!	@property	pathlineColors
    @brief		STL Vector containing the pathline colors (and opacity) for rendering.*/
@property (nonatomic) std::vector<Vector4> pathlineColors;

/*!	@property	variables1D
    @brief		The names of the available variables.*/
@property (readonly) NSMutableArray	*variables1D;

/*!	@property	variables2D
    @brief		The names of the available variables.*/
@property (readonly) NSMutableArray	*variables2D;

/*!	@property	invalidValue
    @brief		The original invalid value from the ncdf file.*/
@property   float	invalidValue;

/*!	@property	validEntries
	@brief		BOOL pointer to a grid, representing the original grid, with YES if the
				position contains valid data and NO if not. Only used for structured data.*/
@property (readonly) BOOL	*validEntries;

/*!	@property	startDate
    @brief		The dateand time for the first time step.*/
@property (nonatomic, readonly) NSDate	*startDate;

/*!	@property	timeStepLength
    @brief		The length of one time step.*/
@property (nonatomic, readonly) NSDateComponents *timeStepLength;

/*!	@property	additionalData1D
    @brief		Datafields for additional Data.*/
//@property (nonatomic, readonly) std::vector<float*> additionalData1D;

/*!	@property	additionalData1DRanges
    @brief		Ranges for additional Data.*/
//@property (nonatomic, readonly) std::vector<Vector2> additionalData1DRanges;

/*!	@property	additionalData1DPositions
    @brief		Positions for additional Data.*/
//@property (nonatomic, readonly) std::vector<Vector2> additionalData1DPositions;

/*!	@property	additionalData1DNames
    @brief		The names  for additional Data.*/
//@property (nonatomic, readonly) NSMutableArray	*additionalData1DNames;

/*!	@property	additionalData1DVariableNames
    @brief		The names of the available variables.*/
//@property (nonatomic, readonly) NSMutableArray	*additionalData1DVariableNames;

/*!	@property	uData
	@brief		Float pointer to the u component of the vector field.*/
@property (readonly) float *uData;

/*!	@property	vData
	@brief		Float pointer to the v component of the vector field.*/
@property (readonly) float *vData;

/*!	@property	ensembleDimension
	@brief		Pointer to an EnsembleDimension Struct, containting the dimensions of the data.*/
@property (readonly) EnsembleDimension *ensembleDimension;

/*!	@property	ensembleLonLat
	@brief		Pointer to an EnsembleLonLat struct containg min and max lon and lat values.*/
@property (readonly) EnsembleLonLat *ensembleLonLat;

/*!	@property	histogramBins
	@brief		Integer value containing the number of bins for the histogram.*/
@property (nonatomic) int histogramBins;

/*!	@property	platforms
	@brief		An NSMutableDictionary holding the off shore platforms with the name of
				the platforms as keys.*/
@property (readonly) NSMutableDictionary *platforms;

/*!	@property	riskHeightIsoValue
	@brief		A Float value indicating the sea surface height that is deemed dangerous.*/
@property (nonatomic) float riskHeightIsoValue;

/*!	@property	riskIsoValue
	@brief		A Float value indicating the percentage of surfaces	tha can be above the
				risk value.*/
@property (nonatomic) float riskIsoValue;

/*!	@property	nodes
	@brief		A float pointer to the nodes, each node is defined by two consecutive float
				values indicating lat and lon. Only valid in the unstructured case.*/
@property (readonly) float *nodes;

/*!	@property	gridIndices
	@brief		An int pointer to the indices for the grid. Triangles are stored as
				three consecutive integers with the id of the node bleonging to the
				corners of the triangle. Only valud in the unstructured case.*/
@property (readonly) unsigned int *gridIndices;

/*!	@property	indexLookup
    @brief		An int pointer to the lookup Table for grid indices in domain coordinates.*/
@property (nonatomic) unsigned char *indexLookup;

/*!	@property	indexLookupWidth
    @brief		Width of the indexLookup table.*/
@property (nonatomic) int indexLookupWidth;

/*!	@property	indexLookupHeight
    @brief		Height of the indexLookup table.*/
@property (nonatomic) int indexLookupHeight;

/*!	@property	numNodes
	@brief		Int value holding the number of nodes for the unstructured case.*/
@property (readonly) int numNodes;

/*!	@property	numTriangles
	@brief		Int value holding the number of triangles for the unstructured case.*/
@property (readonly) int numTriangles;

/*!	@property	bathymetry
	@brief		Float pointer to the bathymetry og the area covered by the dataset.
				Currently only available for unstructured data.*/
//@property (readonly) float *bathymetry;

/*!	@property	memberRangeMin
	@brief		Integer value with the index of the lower boundary of the member parameter
				range.*/
@property (nonatomic) int memberRangeMin;

/*!	@property	memberRangeMax
	@brief		Integer value with the index of the upper boundary of the member parameter
				range.*/
@property (nonatomic) int memberRangeMax;

/*!	@property	memberShowSingle
	@brief		BOOL value indicating whether the defined ranged of members shall be
				used, or only a single defined member.*/
@property (nonatomic) BOOL memberShowSingle;

/*!	@property	memberSingleId
	@brief		Int value indicating the id of the single member that can be visualized
				instead of the member range.*/
@property (nonatomic) int memberSingleId;

/*!	@property	timeRangeMin
	@brief		Integer value with the index of the lower boundary of the time parameter
				range.*/
@property (nonatomic) int timeRangeMin;

/*!	@property	timeRangeMax
	@brief		Integer value with the index of the upper boundary of the time parameter
				range.*/
@property (nonatomic) int timeRangeMax;

/*!	@property	timeShowSingle
	@brief		Int value indicating the id of the single time step that can be visualized
				instead of the time range.*/
@property (nonatomic) BOOL timeShowSingle;

/*!	@property	timeSingleId
	@brief		Int value indicating the id of the single time step that can be visualized
				instead of the time range.*/
@property (nonatomic) int timeSingleId;

/*!	@property	timeStepStride
	@brief		Int value indicating the stride for time steps in thetime series view.*/
@property (nonatomic) int timeStepStride;

/*!	@property	pathline
    @brief		Int value indicating the id of the single time step that can be visualized
    instead of the time range.*/
//@property (nonatomic) int pathline;

/*!	@property	pathlineResolution
    @brief		Int value for pathline binning.*/
@property (nonatomic) int  pathlineResolution;

/*!	@property	pathlineAlphaScale
    @brief		float value for pathline alpha scaling.*/
@property (nonatomic) float  pathlineAlphaScale;

/*!	@property	pathlineStartX
    @brief		float for x component of last pathline trace.*/
@property (nonatomic) float  pathlineStartX;

/*!	@property	pathlineStartY
    @brief		float for y component of last pathline trace.*/
@property (nonatomic) float  pathlineStartY;

/*!	@property	pathlinepPogressionFactor
    @brief		float the step size for pathline computation.*/
@property (nonatomic) float  pathlinepPogressionFactor;

/*!	@property	assimilationCycleLength
    @brief		float for the length (in h) of an assimilation cycle.*/
@property (nonatomic) float  assimilationCycleLength;

/*!	@property	pathlineTexture
    @brief		OpenGL index of the pathline texture.*/
@property (nonatomic) GLuint  pathlineTexture;


/*!	@method		setTimeRangeMin
	@discussion	Sets the lower bound for the time 'parameter' range and
				invalidates all statistics.
	@param	val	Integer value for the lower bound for the time 'parameter'.*/
- (void) setTimeRangeMin:(int) val;

/*!	@method		setTimeRangeMax
	@discussion	Sets the upper bound for the time 'parameter' range and
				invalidates all statistics.
	@param	val	Integer value for the upper bound for the time 'parameter'.*/
- (void) setTimeRangeMax:(int) val;

/*!	@method		setTimeShowSingle
	@discussion	Sets the _timeShowSingle flag indicating whether only a single
				time step shall be used for visualization and statistics
				computation or the range defined by _timeMin and _timeMax.
				Invalidates all statistics.
	@param	val	BOOL value that is written to the _timeShowSingle flag.*/
- (void) setTimeShowSingle:(BOOL) val;

/*!	@method		setTimeSingleId
	@discussion	Sets the id for the current single time step. Is only used when 
				_timeShowSingle = YES.
	@param	val	Int value setting the current single time step id.*/
- (void) setTimeSingleId:(int) val;

- (NSInteger) numTimeStepsWithStride;

/*!	@method		setMemberRangeMin
	@discussion	Sets the lower bound for the member 'parameter' range and
				invalidates all statistics.
	@param	val	Integer value for the lower bound for the member 'parameter'.*/
- (void) setMemberRangeMin:(int) val;

/*!	@method		setMemberRangeMax
	@discussion	Sets the upper bound for the member 'parameter' range and
				invalidates all statistics.
	@param	val	Integer value for the upper bound for the member 'parameter'.*/
- (void) setMemberRangeMax:(int) val;

/*!	@method		setMemberShowSingle
	@discussion	Sets the id for the current single member step. Is only used when
				_memberShowSingle = YES.
	@param	val	Int value setting the current single member id.*/
- (void) setMemberShowSingle:(BOOL) val;

/*!	@method		setMemberSingleId
	@discussion	Sets the id for the current single member. Is only used when
				_memberShowSingle = YES.
	@param	val	Int value setting the current single member id.*/
- (void) setMemberSingleId:(int) val;

- (float*) dataForVariable:(NSInteger) variableId;

- (float*) dataRangeForVariable:(NSInteger) variableId;

- (BOOL) isVariableStaticOverTime:(NSInteger) variableId;

- (BOOL) isVariableStaticOverMembers:(NSInteger) variableId;

- (BOOL) isVariableStatic:(NSInteger) variableId;

- (NSString*) nameForVariable:(NSInteger) variableId;

- (NSArray*) allVariableNamesWithDimension:(NSInteger) dimension;

/*!	@method		histogram
	@discussion	Returns a pointer to integer, pointing to the histogram array.
				If the histogram needs to be updated it will be refreshed
				automatically before returning the data pointer.
				The histogram pointer encapsules a 3D dataset sized
				dimX x dimY x numberOfBins.
				The range of the histogram is zero to the number of members in the
				current parameter range.
	@result		Pointer to an integer array containing the histogram.*/
- (int*) histogramForVariable:(NSInteger) variableId;

/*!	@method		kde
	@discussion	Returns a pointer to float, pointing to the kde array.
				If the kde needs to be updated it will be refreshed
				automatically before returning the data pointer.
				The kde pointer encapsules a 3D dataset sized
				dimX x dimY x numberOfBins.
				The range of the kde is [0..1].
	@result		Pointer to a float array containing the kde.*/
- (float*) kdeForVariable:(NSInteger) variableId;

/*!	@method		mean
	@discussion	Returns a pointer to float, pointing to the mean array.
				If the mean needs to be updated it will be refreshed
				automatically before returning the data pointer.
				The mean pointer encapsules a 2D dataset sized dimX x dimY.
				The range of the mean is dependent on the data and can be read
				from meanRange.
	@result		Pointer to a float array containing the mean values.*/
- (float*) meanForVariable:(NSInteger) variableId;

/*!	@method		meanNormalized
	@discussion	Returns a pointer to float, pointing to a normalized version of
				the mean array.
				If the mean needs to be updated it will be refreshed
				automatically before returning the data pointer.
				The meanNormalized pointer encapsules a 2D dataset sized dimX x dimY.
				The range of meanNormalized is [0..1].
	@result		Pointer to a float array containing the normalized mean values.*/
- (float*) meanNormalizedForVariable:(NSInteger) variableId;

/*!	@method		meanRange
	@discussion	Returns a pointer to float, pointing to an array of size two,
				containing the maximum mean in meanRange[0] and the minimum
				mean in meanRange[1].
	@result		Pointer to a float array containing the max and min mean values.*/
- (float*) meanRangeForVariable:(NSInteger) variableId;

/*!	@method		meanLimits
    @discussion	Returns a pointer to float, pointing to an array of size two,
                containing limits for visualizing the mean.
    @result		Pointer to a float array containing the limits for mean values.*/
- (float*) meanLimitsForVariable:(NSInteger) variableId;

/*!	@method		setMeanLowerLimit
    @discussion	Set the lower limit for visualizing the mean.
    @param  limit   The lower limit.*/
- (void) setMeanLowerLimit: (float) limit ForVariable:(NSInteger) variableId;

/*!	@method		setMeanUpperLimit
    @discussion	Set the upper limit for visualizing the mean.
    @param  limit   The upper limit.*/
- (void) setMeanUpperLimit: (float) limit ForVariable:(NSInteger) variableId;

/*!	@method		median
	@discussion	Returns a pointer to float, pointing to the median array.
				If the median needs to be updated it will be refreshed
				automatically before returning the data pointer.
				The median pointer encapsules a 2D dataset sized dimX x dimY.
				The range of the median is dependent on the data and can be read
				from medianRange.
	@result		Pointer to a float array containing the median values.*/
- (float*) medianForVariable:(NSInteger) variableId;

/*!	@method		medianNormalized
	@discussion	Returns a pointer to float, pointing to a normalized version of
				the median array.
				If the median needs to be updated it will be refreshed
				automatically before returning the data pointer.
				The medianNormalized pointer encapsules a 2D dataset sized dimX x dimY.
				The range of medianNormalized is [0..1].
	@result		Pointer to a float array containing the normalized median values.*/
- (float*) medianNormalizedForVariable:(NSInteger) variableId;

/*!	@method		medianRange
	@discussion	Returns a pointer to float, pointing to an array of size two,
				containing the maximum median in medianRange[0] and the minimum
				median in medianRange[1].
	@result		Pointer to a float array containing the max and min median values.*/
- (float*) medianRangeForVariable:(NSInteger) variableId;

/*!	@method		medianLimits
    @discussion	Returns a pointer to float, pointing to an array of size two,
                containing limits for visualizing the median.
    @result		Pointer to a float array containing the limits for median values.*/
- (float*) medianLimitsForVariable:(NSInteger) variableId;

/*!	@method		setMedianLowerLimit
    @discussion	Set the lower limit for visualizing the median.
    @param  limit   The lower limit.*/
- (void) setMedianLowerLimit: (float) limit ForVariable:(NSInteger) variableId;

/*!	@method		setMedianUpperLimit
    @discussion	Set the upper limit for visualizing the median.
    @param  limit   The upper limit.*/
- (void) setMedianUpperLimit: (float) limit ForVariable:(NSInteger) variableId;

/*!	@method		maximumLikelihood
	@discussion	Returns a pointer to float, pointing to the maximumLikelihood array.
				If the maximumLikelihood needs to be updated it will be refreshed
				automatically before returning the data pointer.
				The maximumLikelihood pointer encapsules a 2D dataset sized dimX x dimY.
				The range of the maximumLikelihood is dependent on the data and can be read
				from maximumLikelihoodRange.
	@result		Pointer to a float array containing the maximum likelihood values.*/
- (float*) maximumModeForVariable:(NSInteger) variableId;

/*!	@method		maximumLikelihoodNormalized
	@discussion	Returns a pointer to float, pointing to a normalized version of
				the maximumLikelihood array.
				If the maximumLikelihood needs to be updated it will be refreshed
				automatically before returning the data pointer.
				The maximumLikelihoodNormalized pointer encapsules a 2D dataset sized dimX x dimY.
				The range of maximumLikelihoodNormalized is [0..1].
	@result		Pointer to a float array containing the normalized maximum likelihood values.*/
- (float*) maximumModeNormalizedForVariable:(NSInteger) variableId;

/*!	@method		maximumLikelihoodRange
	@discussion	Returns a pointer to float, pointing to an array of size two,
				containing the maximum maximumLikelihood value in maximumLikelihoodRange[0]
				and the minimum maximumLikelihood value in maximumLikelihoodRange[1].
	@result		Pointer to a float array containing the max and min maximum likelihood values.*/
- (float*) maximumModeRangeForVariable:(NSInteger) variableId;

/*!	@method		range
	@discussion	Returns a pointer to float, pointing to the range array.
				If the range needs to be updated it will be refreshed
				automatically before returning the data pointer.
				The range pointer encapsules a 2D dataset sized dimX x dimY.
				The range of the range is dependent on the data and can be read
				from rangeRange.
	@result		Pointer to a float array containing the range values.*/
- (float*) rangeForVariable:(NSInteger) variableId;

/*!	@method		rangeNormalized
	@discussion	Returns a pointer to float, pointing to a normalized version of
				the range array.
				If the range needs to be updated it will be refreshed
				automatically before returning the data pointer.
				The rangeNormalized pointer encapsules a 2D dataset sized dimX x dimY.
				The range of rangeNormalized is [0..1].
	@result		Pointer to a float array containing the normalized range values.*/
- (float*) rangeNormalizedForVariable:(NSInteger) variableId;

/*!	@method		rangeRange
	@discussion	Returns a pointer to float, pointing to an array of size two,
				containing the maximum range value in rangeRange[0]
				and the minimum range value in rangeRange[1].
	@result		Pointer to a float array containing the max and min range values.*/
- (float*) rangeRangeForVariable:(NSInteger) variableId;

/*!	@method		rangeLimits
    @discussion	Returns a pointer to float, pointing to an array of size two,
                containing limits for visualizing the Range.
    @result		Pointer to a float array containing the limits for range values.*/
- (float*) rangeLimitsForVariable:(NSInteger) variableId;

/*!	@method		setRangeLowerLimit
    @discussion	Set the lower limit for visualizing the range.
    @param  limit   The lower limit.*/
- (void) setRangeLowerLimit: (float) limit ForVariable:(NSInteger) variableId;

/*!	@method		setRangeUpperLimit
    @discussion	Set the upper limit for visualizing the range.
    @param  limit   The upper limit.*/
- (void) setRangeUpperLimit: (float) limit ForVariable:(NSInteger) variableId;

/*!	@method		standardDeviation
	@discussion	Returns a pointer to float, pointing to the standardDeviation array.
				If the standardDeviation needs to be updated it will be refreshed
				automatically before returning the data pointer.
				The standardDeviation pointer encapsules a 2D dataset sized dimX x dimY.
				The range of the standardDeviation is dependent on the data and can be read
				from standardDeviationRange.
	@result		Pointer to a float array containing the standard deviation values.*/
- (float*) standardDeviationForVariable:(NSInteger) variableId;

/*!	@method		standardDeviationNormalized
	@discussion	Returns a pointer to float, pointing to a normalized version of
				the standardDeviation array.
				If the standardDeviation needs to be updated it will be refreshed
				automatically before returning the data pointer.
				The standardDeviationNormalized pointer encapsules a 2D dataset sized dimX x dimY.
				The range of standardDeviationNormalized is [0..1].
	@result		Pointer to a float array containing the normalized standard deviation values.*/
- (float*) standardDeviationNormalizedForVariable:(NSInteger) variableId;

/*!	@method		standardDeviationRange
	@discussion	Returns a pointer to float, pointing to an array of size two,
				containing the maximum standard deviation value in standardDeviationRange[0]
				and the minimum standard deviation value in standardDeviationRange[1].
	@result		Pointer to a float array containing the max and min standard deviation values.*/
- (float*) standardDeviationRangeForVariable:(NSInteger) variableId;

/*!	@method		standardDeviationLimits
    @discussion	Returns a pointer to float, pointing to an array of size two,
                containing limits for visualizing the Range.
    @result		Pointer to a float array containing the limits for standard deviation values.*/
- (float*) standardDeviationLimitsForVariable:(NSInteger) variableId;

/*!	@method		setStandardDeviationLowerLimit
    @discussion	Set the lower limit for visualizing the standardDeviation.
    @param  limit   The lower limit.*/
- (void) setStandardDeviationLowerLimit: (float) limit ForVariable:(NSInteger) variableId;

/*!	@method		setStandardDeviationUpperLimit
    @discussion	Set the upper limit for visualizing the standardDeviation.
    @param  limit   The upper limit.*/
- (void) setStandardDeviationUpperLimit: (float) limit ForVariable:(NSInteger) variableId;

/*!	@method		variance
	@discussion	Returns a pointer to float, pointing to the variance array.
				If the variance needs to be updated it will be refreshed
				automatically before returning the data pointer.
				The variance pointer encapsules a 2D dataset sized dimX x dimY.
				The range of the variance is dependent on the data and can be read
				from varianceRange.
	@result		Pointer to a float array containing the variance values.*/
- (float*) varianceForVariable:(NSInteger) variableId;

/*!	@method		varianceNormalized
	@discussion	Returns a pointer to float, pointing to a normalized version of
				the variance array.
				If the variance needs to be updated it will be refreshed
				automatically before returning the data pointer.
				The varianceNormalized pointer encapsules a 2D dataset sized dimX x dimY.
				The range of varianceNormalized is [0..1].
	@result		Pointer to a float array containing the normalized variance values.*/
- (float*) varianceNormalizedForVariable:(NSInteger) variableId;

/*!	@method		varianceRange
	@discussion	Returns a pointer to float, pointing to an array of size two,
				containing the maximum variance value in varianceRange[0]
				and the minimum variance value in varianceRange[1].
	@result		Pointer to a float array containing the max and min variance values.*/
- (float*) varianceRangeForVariable:(NSInteger) variableId;

/*!	@method		varianceLimits
    @discussion	Returns a pointer to float, pointing to an array of size two,
                containing limits for visualizing the Range.
    @result		Pointer to a float array containing the limits for variance values.*/
- (float*) varianceLimitsForVariable:(NSInteger) variableId;

/*!	@method		setVarianceLowerLimit
    @discussion	Set the lower limit for visualizing the variance.
    @param  limit   The lower limit.*/
- (void) setVarianceLowerLimit: (float) limit ForVariable:(NSInteger) variableId;

/*!	@method		setVarianceUpperLimit
    @discussion	Set the upper limit for visualizing the variance.
    @param  limit   The upper limit.*/
- (void) setVarianceUpperLimit: (float) limit ForVariable:(NSInteger) variableId;

/*!	@method		risk
	@discussion	Returns a pointer to float, pointing to the risk array.
				If the risk needs to be updated it will be refreshed
				automatically before returning the data pointer.
				The risk pointer encapsules a 2D dataset sized dimX x dimY.
				The is normalized per definition, the range is always [0..1].
	@result		Pointer to a float array containing the risk values.*/
- (float*) riskForVariable:(NSInteger) variableId;

/*!	@method		riskNormalized
	@discussion	Returns a pointer to float. Since the risk is defined to be
				within [0..1] there is no special normalized version. Instead
				this function simply forwards to the risk.
	@result		Pointer to a float array containing the normalized risk values.*/
- (float*) riskNormalizedForVariable:(NSInteger) variableId;

/*!	@method			property
	@discussion		Returns a pointer to float, pointing to the property
					corresponding to the specified propertyId.
	@param	propertyId	OVEnsembleProperty identifiying the statistical
					property that shall be returned.
	@result			Pointer to a float array containing the desired property values.*/
- (float*) property:(OVEnsembleProperty) propertyId ForVariable:(NSInteger) variableId;

/*!	@method			propertyNormalized
	@discussion		Returns a pointer to float, pointing to the normalized
					version of the property	corresponding to the specified
					propertyId.
	@param	propertyId	OVEnsembleProperty identifiying the statistical
					property that shall be returned.
	@result			Pointer to a float array containing the desired normalized property values.*/
- (float*) propertyNormalized:(OVEnsembleProperty) propertyId ForVariable:(NSInteger) variableId;

/*!	@method			activeSurfaceForView
	@discussion		Returns a pointer to float, pointing to the data of the
					active surface (correspoing to a statistical property
					or any surface) for a specified view.
	@param	viewId	OVViewId identifiying the view that requests the active
					surface.
	@param	normalized	BOOL value specifying whether normalized or regular
					version is desired.
	@result			Pointer to a float array containing the surface values
					for the active surface of the given view.*/
- (float*) activeSurfaceForView:(OVViewId) viewId normalized:(BOOL) normalized;

/*!	@method			activePropertyForView
	@discussion		Returns a pointer to float, pointing to the data of the
					active statistical property for a specified view.
	@param	viewId	OVViewId identifiying the view that requests the active
					property.
	@param	normalized	BOOL value specifying whether normalized or regular
					version is desired.
	@result			Pointer to a float array containing the property values
					for the active property of the given view.*/
- (float*) activePropertyForView:(OVViewId) viewId normalized:(BOOL) normalized;

/*!	@method		activePropertyRangeForView
	@discussion	Returns a pointer to float, pointing to the range array of
				the active property for a specified view.
	@param	viewId	OVViewId identifiying the view that requests range for
				the active property.
	@result		Pointer to a float array containing the max and min values
				for the active property of the given view.*/
- (float*) activePropertyRangeForView:(OVViewId) viewId;

/*!	@method			activeNoisePropertyForView
    @discussion		Returns a pointer to float, pointing to the data of the
                    active statistical property used for the noise for a specified view.
    @param	viewId	OVViewId identifiying the view that requests the active property.
    @param	normalized	BOOL value specifying whether normalized or regular
                    version is desired.
    @result			Pointer to a float array containing the property values
                    for the active noise property of the given view.*/
- (float*) activeNoisePropertyForView:(OVViewId) viewId normalized:(BOOL) normalized;

/*!	@method		activeNoisePropertyRangeForView
    @discussion	Returns a pointer to float, pointing to the range array of
                the active property used for the noise for a specified view.
    @param	viewId	OVViewId identifiying the view that requests range for
                the active property.
    @result		Pointer to a float array containing the max and min values
                for the active noise property of the given view.*/
- (float*) activeNoisePropertyRangeForView:(OVViewId) viewId;

/*!	@method		kdesForGlyphSide
	@discussion	Returns a pointer to float, pointing to the kdes for the
				active position defined for the given side of the glyph.
				The size of the underlying array is the number of bins
				multiplied with the number of time steps in the dataset.
				The array contains one 1D kde for each time step.
	@param	side	Integer value identifiying the side of the glyph, 0 for left,
				1 for right.
	@result		Pointer to a float array containing the kdes for the given glyph side.*/
- (float*) kdesForGlyphSide:(int) side;

/*!	@method		risksForGlyphSide
	@discussion	Returns a pointer to float, pointing to the means for the
                active position defined for the given side of the glyph.
                The size of the underlying array corresponds to the number
                of time steps in the dataset. The array contains one float
                value for the mean for each time step.
	@param	side	Integer value identifiying the side of the glyph, 0 for left,
                1 for right.
	@result		Pointer to a float array containing the risk values for the given glyph side.*/
- (float*) meansForGlyphSide:(int) side;


/*!	@method		risksForGlyphSide
	@discussion	Returns a pointer to float, pointing to the given percentiles for the
                active position defined for the given side of the glyph.
                The size of the underlying array corresponds to the number
                of time steps in the dataset. The array contains one float
                value for the mean for each time step.
	@param	side	Integer value identifiying the side of the glyph, 0 for left,
                1 for right.
	@param	p   The id of the percentile to fetch (currently the percentile is fixed to p * 10)
	@result		Pointer to a float array containing the risk values for the given glyph side.*/
- (float*) percentiles:(int) p ForGlyphSide:(int) side;

/*!	@method		risksForGlyphSide
	@discussion	Returns a pointer to float, pointing to the risks for the
				active position defined for the given side of the glyph.
				The size of the underlying array corresponds to the number
				of time steps in the dataset. The array contains one float
				value for the risk for each time step.
	@param	side	Integer value identifiying the side of the glyph, 0 for left,
				1 for right.
	@result		Pointer to a float array containing the risk values for the given glyph side.*/
- (float*) risksForGlyphSide:(int) side;

/*!	@method			gridYFromLat
	@discussion		Converts the given latitude to a position in the grid.
	@param	latitude	The latitude value to convert.
	@result			The Y coordinate for corresponding to the given latitude.*/
- (int) gridYFromLat:(float) latitude;

/*!	@method			gridXFromLon
	@discussion		Converts the given longitude to a position in the grid.
	@param	longitude	The longitude value to convert.
	@result			The X coordinate for corresponding to the given longtude.*/
- (int) gridXFromLon:(float) longitude;

/*!	@method			unstructuredIndexFromLon
    @discussion		Converts the given long/lat position to an index in the unstructured vertices array.
    @param	longitude	The longitude value to convert.
    @param	latidue     The latidue value to convert.
    @result			The index corresponding to the given position.*/
- (int) unstructuredIndexFromLon:(float) longitude Lat:(float) latitude;

/*!	@method		numberOfPathlineSegments
	@discussion	Computes the number of segments for the computed set of pathlines.
	@result		The number of segments in the pathlines array.*/
- (size_t) numberOfPathlineSegments;

- (OVVariable2D*) add2DVariable;

/*!	@method		allocateMemoryFor
    @discussion	Computes the number of segments for the computed set of pathlines.
    @param	dataFieldID	The id of the data field to allocate space for (SSH, U, V).
    @param	numVals     Number of float values to allocate space for.
    @result		Pointer to the allocated Memory.*/
- (float*) allocateMemoryFor: (int) variableId withNumValues: (size_t) numVals;

@end
