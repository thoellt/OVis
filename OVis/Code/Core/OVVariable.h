//
//  OVVariable.h
//  Ovis
//
//  Created by Thomas Höllt on 14/09/14.
//  Copyright (c) 2014 Thomas Höllt. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "general.h"

@class OVStatistic;
@class OVHistogram;

@interface OVVariable : NSObject
{
    int _dimensionality;
    
    float* _data;
    float* _dataRange;
    
    NSString* _name;
    NSString* _unit;
    
    VariableDimension* _dimension;
    size_t _size;
    
    OVHistogram* _histogram;
    OVStatistic* _mean;
    OVStatistic* _median;
    OVStatistic* _maximumMode;
    OVStatistic* _range;
    OVStatistic* _standardDeviation;
    OVStatistic* _variance;
    OVStatistic* _risk;
}

/*!	@property	dimensionality
    @brief		the raw data for this variable.*/
@property (nonatomic) int dimensionality;

/*!	@property	data
    @brief		the raw data for this variable.*/
@property (nonatomic) float* data;

/*!	@property	dataRange
    @brief		dataRange.*/
@property (nonatomic) float* dataRange;

/*!	@property	name
    @brief		Name of the variable.*/
@property (nonatomic) NSString* name;

/*!	@property	unit
    @brief		Unit of the variable.*/
@property (nonatomic) NSString* unit;

/*!	@property	dimension
    @brief		Dimensions of the variable.*/
@property (nonatomic, readonly) VariableDimension* dimension;

/*!	@property	histogram
 @brief		histogram.*/
@property (nonatomic) OVHistogram* histogram;

/*!	@property	mean
 @brief		mean.*/
@property (nonatomic) OVStatistic* mean;

/*!	@property	median
 @brief		median.*/
@property (nonatomic) OVStatistic* median;

/*!	@property	maximumMode
 @brief		the largest peak in the histogram.*/
@property (nonatomic) OVStatistic* maximumMode;

/*!	@property	range
 @brief		the distance between the smallest and the biggest value.*/
@property (nonatomic) OVStatistic* range;

/*!	@property	standardDeviation
 @brief		standardDeviation.*/
@property (nonatomic) OVStatistic* standardDeviation;

/*!	@property	variance
 @brief		variance.*/
@property (nonatomic) OVStatistic* variance;

/*!	@property	risk
 @brief		risk.*/
@property (nonatomic) OVStatistic* risk;

-(void) invalidate;

-(BOOL) isTimeStatic;

-(BOOL) isMemberStatic;

-(void) setDimensionsX:(size_t) dim_x Y:(size_t) dim_y Z:(size_t) dim_z M:(size_t) dim_m T:(size_t) dim_t;

-(void) scanRange;

@end
