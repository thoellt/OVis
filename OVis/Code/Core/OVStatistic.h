//
//  OVStatistic.h
//  Ovis
//
//  Created by Thomas Höllt on 14/09/14.
//  Copyright (c) 2014 Thomas Höllt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OVStatistic : NSObject
{
    float* _data;
	float* _dataNormalized;
	size_t _size;
	float* _range;
	float* _limits;
	BOOL _isDirty;
}

/*!	@property	data
    @brief		c style float pointer to raw data.*/
@property (nonatomic, readonly) float* data;

/*!	@property	dataNormalized
    @brief		c style float pointer to normalized raw data.*/
@property (nonatomic, readonly) float* dataNormalized;

/*!	@property	size
    @brief		size of the raw data field.*/
@property (nonatomic, readonly) size_t size;

/*!	@property	range
    @brief		range of the data (upper lower limit).*/
@property (nonatomic, readonly) float* range;

/*!	@property	limits
    @brief		limits of the data (upper lower limit).*/
@property (nonatomic, readonly) float* limits;

/*!	@property	isDirty
    @brief		flag to indicate if data needs to be refreshed.*/
@property (nonatomic) BOOL isDirty;

- (void) rebuildDataWithSize: (size_t) size;

- (void) normalize;

@end
