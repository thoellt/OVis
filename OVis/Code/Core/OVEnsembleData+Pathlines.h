/*!	@header		OVEnsembleData+Pathlines.h
	@discussion	Pathlines Category for OVEnsembleData. Handles pathline computation.
	@author		Thomas Höllt
	@updated	2013-08-07 */

#import "general.h"
#import "OVEnsembleData.h"

@interface OVEnsembleData (Pathlines)

/*!	@method		computePathlineFromX
	@discussion	Computes the ensemble of pathlines starting with the given position.
	@param	x	X coordinate of starting position in non normalized object space.
	@param	y	Y coordinate of starting position in non normalized object space.
	@param	z	Z coordinate of starting position in non normalized object space.*/
- (void) computePathlineFromX: (int) x Y:(int) y Z:(int) z;

/*!	@method		computePathline
    @discussion	Computes the ensemble of pathlines starting with previously defined position position.*/
- (void) computePathline;

/*!	@method		computePathlineBruteForce
    @discussion	Computes the ensemble of pathlines starting with previously defined position position using brute force recursive algorithm.
    @param	x	X coordinate of starting position in non normalized object space.
    @param	y	Y coordinate of starting position in non normalized object space.
    @param	z	Z coordinate of starting position in non normalized object space.*/
- (void) computePathlineBruteForce;

/*!	@method		computePathlineBruteForceFromX
	@discussion	Advances a single pathline starting to the next timestep from a
				given position and for a given member in the ensemble.
	@param	x	X coordinate of starting position in non normalized object space.
	@param	y	Y coordinate of starting position in non normalized object space.
	@param	z	Z coordinate of starting position in non normalized object space.
	@param	t	The timestep to use for advancing the pathline.
	@param	m	The ensemble member used for computation.
	@param	s	Stepsize for advancing, i.e. 0.5 for the halfstep using Runge Kutta*/
- (void) advancePathlineFromX: (float) x Y:(float) y Z:(float) z inTimestep:(int) t forMember: (int) m withStepSize: (float) s;

/*!	@method		computePathlineBinned
    @discussion	Computes the ensemble of pathlines starting with previously defined position position using binning and weighted segments as well as early out.*/
- (void) computePathlineBinned;

/*!	@method		velocityForX
    @discussion	Get the interpolated velocity for a given 5D position
    @param	x	X coordinate of starting position in non normalized object space.
    @param	y	Y coordinate of starting position in non normalized object space.
    @param	z	Z coordinate of starting position in non normalized object space.
    @param	t	The timestep to use for advancing the pathline.
    @param	m	The ensemble member used for computation.*/
-(Vector2) velocityForX: (float) x  Y:(float) y Z:(float) z inTimestep:(int) t forMember: (int) m;

/*!	@method		renderPathlines
    @discussion	Render pathlines in an offscreen buffer.*/
- (void) renderPathlines;

@end
