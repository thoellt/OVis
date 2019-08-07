//
//	general.h
//	OVis
//
//	Created by Thomas Höllt on 16/06/13.
//	Copyright (c) 2013 Thomas Höllt. All rights reserved.
//

#ifndef __GENERAL_H__
#define __GENERAL_H__

// ----------------------------------------------------------------------------

#define PI 3.1415926535f
#define EULER 2.718281828459f

#ifdef __cplusplus

// ----------------------------------------------------------------------------
template <typename T>
const T OVClamp( const T lower_bound, const T value, const T upper_bound )
{ return MAX( lower_bound, MIN( value, upper_bound ) ); }

// ----------------------------------------------------------------------------
template <typename T>
const T OVFrac( const T val ) { return ( val - (int)(val) ); }

#endif // __cplusplus

typedef NS_ENUM(NSInteger, OVEnsembleProperty) {
	EnsemblePropertyNone = -1,
	EnsemblePropertyMean,
	EnsemblePropertyMedian,
	EnsemblePropertyMaximumLikelihood,
	EnsemblePropertyRange,
	EnsemblePropertyStandardDeviation,
	EnsemblePropertyVariance,
	EnsemblePropertyRisk,
	EnsemblePropertyBathymetry
};

typedef NS_ENUM(NSInteger, OVViewId) {
	ViewId2D,
	ViewId3D,
	ViewIdTS,
    ViewIdHistogram,
	
	ViewIdCount
};

typedef struct
{
	float x,y;
} Vector2;

typedef struct
{
	float x,y,z;
} Vector3;

typedef struct
{
	float x,y,z,w;
} Vector4;

typedef struct
{
	int x,y;
} iVector2;

typedef struct
{
	int x,y,z;
} iVector3;

typedef struct
{
	int x,y,z,w;
} iVector4;

typedef struct {
	
	long x, y, z, m, t, size, texX, texY;
	
}EnsembleDimension;

typedef struct {
	
	long x, y, z, m, t;
	
}VariableDimension;

typedef struct {
	
	float lon_min, lon_max, lat_min, lat_max;
	
}EnsembleLonLat;


typedef struct
{
	Byte r,g,b;
} RGB;

#endif // __GENERAL_H__