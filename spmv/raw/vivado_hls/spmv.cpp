#include "spmv.h"
void spmv(volatile float *y, volatile int* ptr, volatile float* valArray,
		volatile int* indArray, volatile float* xvec, int dim)
{

        int s;
        int kbegin = 0;
        for(s =0; s<dim; s++)
        {
                int kend = ptr[s];
                int k;
                float curY = y[s];
                spmv_label0:for(k = kbegin; k<kend; k++)
                {
                        int curInd = indArray[k];
                        curY = curY + valArray[k]* xvec[curInd];

                }
                y[s] = curY;
                kbegin = kend;
        }
        return;
}
