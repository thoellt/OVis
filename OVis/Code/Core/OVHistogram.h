//
//  OVHistogram.h
//  Ovis
//
//  Created by Thomas Höllt on 14/09/14.
//  Copyright (c) 2014 Thomas Höllt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OVHistogram : NSObject
{
    int* _data;
	size_t _size;
	BOOL _isDirty;
    
    float* _kde;
	size_t _kdeSize;
	BOOL _isKdeDirty;
}

/*!	@property	data
    @brief		c style float pointer to raw data.*/
@property (nonatomic, readonly) int* data;

/*!	@property	size
    @brief		size of the raw data field.*/
@property (nonatomic, readonly) size_t size;

/*!	@property	isDirty
    @brief		flag to indicate if data needs to be refreshed.*/
@property (nonatomic) BOOL isDirty;

/*!	@property	kde
    @brief		c style float pointer to raw data.*/
@property (nonatomic, readonly) float* kde;

/*!	@property	kdeSize
    @brief		size of the raw data field.*/
@property (nonatomic, readonly) size_t kdeSize;

/*!	@property	isKdeDirty
    @brief		flag to indicate if data needs to be refreshed.*/
@property (nonatomic) BOOL isKdeDirty;

- (void) rebuildDataWithSize: (size_t) size;

@end
