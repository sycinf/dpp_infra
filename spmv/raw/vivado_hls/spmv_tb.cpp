#include <stdlib.h>
#include <stdio.h>
#include "spmv.h"

void spmvsw(float *y, int* ptr, float* valArray,
		int* indArray, float* xvec, int dim)
{
        int s;
        int kbegin = 0;
        for(s =0; s<dim; s++)
        {
                int kend = ptr[s];

                int k;
                float curY = y[s];
                for(k = kbegin; k<kend; k++)
                {
                        int curInd = indArray[k];
                        curY = curY + valArray[k]* xvec[curInd];

                }
                y[s] = curY;
                kbegin = kend;

        }
        return;
}


int main()
{

	// init stub
	int dim = 32;
	int sparsity = 8;
	// pointer array
	int* ptr = (int*)malloc(dim*sizeof(int));
	int totalNum = 0;
	for(int i=0; i < dim; i++)
	{
		// number of element in this row
		int numEle = rand()%(dim/sparsity);
		totalNum+= numEle;
		ptr[i]=totalNum;
	}
	float* xvec = (float*)malloc(dim*sizeof(float));
	for(int i=0; i<dim; i++)
		xvec[i] = (float)(i);
	int* indArray;
	float* valArray;
	valArray = (float*) malloc(totalNum*sizeof(float));
	for(int j =0; j<totalNum; j++)
		valArray[j] = (float)(rand()%dim);
	// the values in ind should be between 0 and dim
	indArray = (int*) malloc(totalNum*sizeof(int));
	for(int k =0; k<totalNum; k++)
		indArray[k] = rand()%dim;
	float* y = (float*) malloc(dim*sizeof(float));
	for(int k =0; k<dim; k++)
		y[k] = 0.0;
	spmvsw(y,ptr,valArray,indArray,xvec,dim );
	float* y2 = (float*) malloc(dim*sizeof(float));
	spmv(y2,ptr,valArray,indArray,xvec,dim);
	for(int k =0; k<dim; k++)
	{
		if(y[k]!=y2[k])
			return 1;
	}
	return 0;
}
