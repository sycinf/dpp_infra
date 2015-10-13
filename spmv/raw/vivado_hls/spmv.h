#ifndef SPMV_H
#define SPMV_H
void spmv(volatile float *y, volatile int* ptr, volatile float* valArray,
		volatile int* indArray, volatile float* xvec, int dim);
#endif
