/*
 * Author: Carlos Fonseca
 *         Unversity of Sheffield
 *         10 March 1995
 */

#include <math.h>
#include "mex.h"

#define max(x,y) ( ((x)>(y)) ? (x) : (y) )

#define NIND1 mxGetM(prhs[0])
#define NOBJ1 mxGetN(prhs[0])
#define OBJV1 mxGetPr(prhs[0])

#define NIND2 mxGetM(prhs[1])
#define NOBJ2 mxGetN(prhs[1])
#define OBJV2 mxGetPr(prhs[1])

#define IX1_OUT plhs[0]
#define IX1 mxGetPr(plhs[0])
#define IX2_OUT plhs[1]
#define IX2 mxGetPr(plhs[1])

void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    int    i, j, k, ix, jx;
	char            j_leq_i, i_leq_j, i_eq_j;

	/* Validate inputs */
	if (nrhs > 2)
		nrhs = 2;
	switch (nrhs) {
	case 2:
		if (NOBJ1 != NOBJ2)
		    mexErrMsgTxt("The number of columns must agree");
	case 1:
		break;
	default:
		mexErrMsgTxt("Not enough input arguments.");
	}

	if (nlhs > 2)
		mexErrMsgTxt("Too many output arguments.");

	/* Create Matrix to return result in */
	IX1_OUT = mxCreateDoubleMatrix(NIND1, 1, mxREAL);
	for (i = 0; i < NIND1; IX1[i++] = 1);

	/* Perform calculations */
	for (i = 0; i < NIND1-1; i++) {
		for (j = i+1; j < NIND1; j++) {
			if (IX1[i] == 0) break;
			if (IX1[j] == 0) continue;
			i_leq_j = j_leq_i = i_eq_j = 1;
			for (k = 0; k < NOBJ1; k++) {
				jx = j + NIND1 * k;
				ix = i + NIND1 * k;
				j_leq_i *= (OBJV1[jx] <= OBJV1[ix]);
				i_eq_j *= (OBJV1[ix] == OBJV1[jx]);
				i_leq_j *= (OBJV1[ix] <= OBJV1[jx]);
			}
			IX1[i] *= (!j_leq_i || i_eq_j);
			IX1[j] *= (!i_leq_j);

		}
	}

	/* If only one input matrix then finish here */
	if (nrhs == 1)
		return;

	/* else create new Matrix to return the second result in */
	IX2_OUT = mxCreateDoubleMatrix(NIND2, 1, mxREAL);
	for (i = 0; i < NIND2; IX2[i++] = 1);

	/* Perform calculations */
	for (i = 0; i < NIND1; i++) {
		for (j = 0; j < NIND2; j++) {
			if (IX1[i] == 0) break;
			if (IX2[j] == 0) continue;
			i_leq_j = j_leq_i = i_eq_j = 1;
			for (k = 0; k < NOBJ1; k++) {
				jx = j + NIND2 * k;
				ix = i + NIND1 * k;
				j_leq_i *= (OBJV2[jx] <= OBJV1[ix]);
				i_eq_j *= (OBJV1[ix] == OBJV2[jx]);
				i_leq_j *= (OBJV1[ix] <= OBJV2[jx]);
			}
			IX1[i] *= (!j_leq_i || i_eq_j);
			IX2[j] *= (!i_leq_j);

		}
	}

}

