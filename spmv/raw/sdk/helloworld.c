/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* XILINX CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include <stdlib.h>
#include "platform.h"
#include "xspmv.h"
#include "xscugic.h"
#include "xscutimer.h"	/* if PS Timer is used */
#include "xparameters.h"	/* parameters for Xilinx device driver environment */

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


#define TIMER_LOAD_VALUE 0xFFFFFFFF
#define TIMER_DEVICE_ID	XPAR_SCUTIMER_DEVICE_ID

XSpmv spmv_dev;

/*XSpmv_Config spmv_config = {
	0,
	XPAR_SPMV_0_S_AXI_AXILITES_BASEADDR
};*/
XScuTimer Timer;	/* Cortex A9 SCU Private Timer Instance */

volatile u32 CntValue1;
XScuTimer_Config *ConfigPtr;
XScuTimer *TimerInstancePtr;
void setupSpMV(float *y, int* ptr, float* valArray,
        int* indArray, float* xvec, int dim)
{
	int status = XSpmv_Initialize(&spmv_dev, 0);
	if(status!=XST_SUCCESS)
		xil_printf("cannot initialize spmv\n\r");
	XSpmv_Set_ptr_offset(&spmv_dev,(u32)ptr);
	XSpmv_Set_y_offset(&spmv_dev,(u32)y);
	XSpmv_Set_valArray_offset(&spmv_dev,(u32)valArray);
	XSpmv_Set_indArray_offset(&spmv_dev,(u32)indArray);
	XSpmv_Set_xvec_offset(&spmv_dev,(u32)xvec);
	XSpmv_Set_dim(&spmv_dev,(u32)dim);

	// we would need to write whole bunch of stuff into the addresssetting
	// we would write one value, then write vld, then read ack
	//u32 Data;

	//XSpmv_WriteReg((&spmv_dev)->Axi4lites_BaseAddress, XSPMV_AXI4LITES_ADDR_SETTINGADDRESS_DATA, 0x12);
	//XSpmv_WriteReg((&spmv_dev)->Axi4lites_BaseAddress, XSPMV_AXI4LITES_ADDR_SETTINGADDRESS_CTRL, 0x03);

	//Data = XSpmv_ReadReg((&spmv_dev)->Axi4lites_BaseAddress, XSPMV_AXI4LITES_ADDR_SETTINGADDRESS_CTRL) ;
	//XSpmv_WriteReg(InstancePtr->Axi4lites_BaseAddress, XSPMV_AXI4LITES_ADDR_SETTINGADDRESS_DATA, Data | 0x01);
	//XSpmv_SetSettingaddress(&spmv_dev,0x22);
	//XSpmv_SetSettingaddressVld(&spmv_dev);
	//Data = XSpmv_GetSettingaddress(&spmv_dev);
	//Data = XSpmv_GetSettingaddressVld(&spmv_dev);
	//xil_printf("%d is the response \r\n", Data);

}




int main()
{
    init_platform();
    TimerInstancePtr = &Timer;
	int Status;
	// Initialize timer counter
	ConfigPtr = XScuTimer_LookupConfig(TIMER_DEVICE_ID);
	if(!ConfigPtr)
		xil_printf("scutimer cant be found\n");
	Status = XScuTimer_CfgInitialize(TimerInstancePtr, ConfigPtr,
						 ConfigPtr->BaseAddr);
	if(Status !=XST_SUCCESS)
	{
		xil_printf("scutimer initialization fail");
	}
	XScuTimer_LoadTimer(TimerInstancePtr, TIMER_LOAD_VALUE);
	//CntValue1 = XScuTimer_GetCounterValue(TimerInstancePtr);
	//xil_printf("zero calibrate: %d clock cycles\r\n", TIMER_LOAD_VALUE-CntValue1);


	XScuTimer_Start(TimerInstancePtr);
	XScuTimer_RestartTimer(TimerInstancePtr);

	CntValue1 = XScuTimer_GetCounterValue(TimerInstancePtr);
	printf("calibrate: %d clock cycles\r\n", TIMER_LOAD_VALUE-CntValue1);

    int dim = 32;
	int sparsity = 8;
	// pointer array
	int* ptr = (int*)malloc(dim*sizeof(int));
	int totalNum = 0;
    int i;
    for(i=0; i < dim; i++)
    {
		// number of element in this row
		int numEle = rand()%(dim/sparsity);
		totalNum+= numEle;
		ptr[i]=totalNum;
    }
    float* xvec = (float*)malloc(dim*sizeof(float));
    // populate the xvector with random double

    for(i=0; i<dim; i++)
    {
		xvec[i] = (float)(i);
    }
	int* indArray;
	float* valArray;
		// need to keep track total num of element

	valArray = (float*) malloc(totalNum*sizeof(float));
	int j;
	for(j =0; j<totalNum; j++)
	{
		valArray[j] = (float)(rand()%dim);
	}
	// the values in ind should be between 0 and dim

	indArray = (int*) malloc(totalNum*sizeof(int));
	int k;
	for(k =0; k<totalNum; k++)
	{
		indArray[k] = rand()%dim;
	}

	float* y = (float*) malloc(dim*sizeof(float));
	for(k =0; k<dim; k++)
	{
		y[k] = 0.0;
	}
	XScuTimer_RestartTimer(TimerInstancePtr);
	spmvsw(y,ptr,valArray,indArray,xvec,dim );
	CntValue1 = XScuTimer_GetCounterValue(TimerInstancePtr);
	printf("software: %d clock cycles\r\n", TIMER_LOAD_VALUE-CntValue1);

	for(k =0; k<dim; k++)
	{
		printf("%f ", y[k]);
	}
	float* y2 = (float*) malloc(dim*sizeof(float));
	for(k =0; k<dim; k++)
	{
		y2[k] = 0.0;
	}
	printf("ready to setup hw\n");
	setupSpMV(y2,ptr,valArray,indArray,xvec,dim);
	printf("finish setting up hw\n");
	printf("ready to run hw\n");
	XScuTimer_RestartTimer(TimerInstancePtr);
	XSpmv_Start(&spmv_dev);
	int m=0;
	while(!XSpmv_IsDone(&spmv_dev) && m<50000)
		m++;

	CntValue1 = XScuTimer_GetCounterValue(TimerInstancePtr);
	printf("hardware: %d clock cycles\r\n", TIMER_LOAD_VALUE-CntValue1);
	printf("out of loop\n");
	if(m==50000)
	{
		printf("problematic stuck\n");
	}
	printf("\n");
	for(k =0; k<dim; k++)
	{
		printf("%f ", y2[k]);
	}
	printf("wierd\n");
	//printf("\n%d %d %d %d %d\n",ptrReadCount,indArrayReadCount,valArrayReadCount,xvecReadCount,yReadCount);

    cleanup_platform();
    return 0;
}
