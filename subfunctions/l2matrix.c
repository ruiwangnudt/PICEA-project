#include "mex.h"
#include "math.h"

/*
 * l2matrix.c
 *
 * Computes L2 distances between points.
 *
 * This is a MEX-file for MATLAB.
 * Robin Purshouse, 08-Oct-2001
 *
 * Input:  popData   - normalised population data
 *
 * Output: distances - matrix of L2 distances 
 *
 */

void l2matrix(double* popData, int dimSize, int popSize, double* distances)
{
  /* Variable declarations: */
  int individual = 0;
  int at = 0;
  int compareThis = 0;
  double distance = 0.0;
  int dimension = 0;
  double dimD = 0.0;
  double maxDistance = 0.0;
  
  /* Initialise output: */
  for(individual = 0; individual < popSize; individual++)
  {
    for(compareThis = 0; compareThis < popSize; compareThis++)
    {
      *(distances + popSize * compareThis + individual) = 0;
    }
  }

  /* Algorithm: */
  /* For each individual: */
  for(individual = 0; individual < (popSize - 1); individual++)
  {
    /* Avoid unnecessary computations: */
    at++;
    for(compareThis = at; compareThis < popSize; compareThis++)
    {
      /* Compute the Euclidean distance: */
      distance = 0.0;
      for(dimension = 0; dimension < dimSize; dimension++)
      {
	/* Compute the distance for that dimension. */
	dimD = *(popData + popSize * dimension + individual) - 
	  *(popData + popSize * dimension + compareThis);
	
	/* Square it. */
	dimD *= dimD;
	
	/* And add to the running total. */
	distance += dimD;
      }
      
      /* Take the square root to get the L2 distance. */
      distance = sqrt(distance);
      
      /* Fill in the correct elements of the output matrix. */
      *(distances + popSize * compareThis + individual) = distance;
      *(distances + popSize * individual + compareThis) = distance;
    }
  }
}

/* The gateway function */
void mexFunction(int nlhs, mxArray* plhs[],
		 int nrhs, const mxArray* prhs[])
{
  double* popData = NULL;
  double* distances = NULL;
  int dimSize = 0;
  int popSize = 0;

  /* Check for correct number of inputs: */
  if(nrhs != 1)
  {
    mexErrMsgTxt("A single input is required.");
  }

  /* Check for correct number of outputs: */
  if(nlhs > 1)
  {
    mexErrMsgTxt("A single output is required.");
  }

  /* We could add more checks, such as non-complex, numeric, etc. */

  /* Get pointers to the input matrices. */
  popData = mxGetPr(prhs[0]);
  
  /* Get the necessary size information. */
  popSize = mxGetM(prhs[0]);
  dimSize = mxGetN(prhs[0]);

  /* Set the output pointer to the output matrix. */
  plhs[0] = mxCreateDoubleMatrix(popSize, popSize, mxREAL);

  /* Create a (C) pointer to the output matix: */
  distances = mxGetPr(plhs[0]);

  /* Call the subroutine. */
  l2matrix(popData, dimSize, popSize, distances);

} 
