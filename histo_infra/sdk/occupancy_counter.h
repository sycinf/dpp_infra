/*
 * occupancy_counter.h
 *
 *  Created on: Dec 1, 2015
 *      Author: chengs
 */

#ifndef OCCUPANCY_COUNTER_H_
#define OCCUPANCY_COUNTER_H_
#include "xil_types.h"
#include "xil_assert.h"
#include "xstatus.h"
#include "xil_io.h"

#define DATAWIDTH_D32 		1
// these are for modifying the counter state
#define CNTRESET_ADDR 		0
#define CNTCAPTR_ADDR 		1<<(DATAWIDTH_D32+1)
#define CNTADDRSET_ADDR 	1<<(DATAWIDTH_D32+2)
// these are for make reading
#define CNTADDRGET_ADDR 	1<<(DATAWIDTH_D32+1)
#define CNTVALUEGET_ADDR	0

#define XOccupancy_Counter_WriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define XOccupancy_Counter_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))




typedef struct {
    u32 Axilites_BaseAddress;
    u8 bin_bits;
    u32 IsReady;
    u32 Captured;
} XOccupancy_Counter;

void XOccupancy_Counter_Initialize(XOccupancy_Counter *InstancePtr, u32 address, u8 binBits)
{
	InstancePtr->Axilites_BaseAddress = address;
	InstancePtr->bin_bits = binBits;
	InstancePtr->IsReady = XIL_COMPONENT_IS_READY;
	InstancePtr->Captured = 0;
}
void XOccupancy_Counter_Reset(XOccupancy_Counter *InstancePtr)
{
	Xil_AssertVoid(InstancePtr != NULL);
	Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);
	XOccupancy_Counter_WriteReg(InstancePtr->Axilites_BaseAddress, CNTRESET_ADDR, 0);
	InstancePtr->Captured=0;
}
void XOccupancy_Counter_Capture(XOccupancy_Counter *InstancePtr)
{
	Xil_AssertVoid(InstancePtr != NULL);
	Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);
	XOccupancy_Counter_WriteReg(InstancePtr->Axilites_BaseAddress, CNTCAPTR_ADDR, 0);
	InstancePtr->Captured=1;
}
void XOccupancy_Counter_SetBinNum(XOccupancy_Counter *InstancePtr, u32 binNum )
{
	Xil_AssertVoid(InstancePtr != NULL);
	Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);
	Xil_AssertVoid(binNum < (1<<InstancePtr->bin_bits ) );
	XOccupancy_Counter_WriteReg(InstancePtr->Axilites_BaseAddress, CNTADDRSET_ADDR, binNum);
}
unsigned int XOccupancy_Counter_GetValue(XOccupancy_Counter *InstancePtr)
{
	Xil_AssertVoid(InstancePtr != NULL);
	Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);
	u32 binValue = XOccupancy_Counter_ReadReg(InstancePtr->Axilites_BaseAddress, CNTVALUEGET_ADDR);
	return binValue;
}

void populateOccupancyHistogram(XOccupancy_Counter *InstancePtr, u32* histo, u32 histoSize)
{
	Xil_AssertVoid(InstancePtr != NULL);
	Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);
	if(InstancePtr->Captured == 0)
		XOccupancy_Counter_Capture(InstancePtr);
	unsigned populateInd;
	unsigned numOfBins = 1<<InstancePtr->bin_bits;
	for(populateInd = 0; populateInd < histoSize; populateInd++)
	{
		if(populateInd >= numOfBins)
			histo[populateInd] = 0;
		else
		{
			XOccupancy_Counter_SetBinNum(InstancePtr,populateInd);
			histo[populateInd] = XOccupancy_Counter_GetValue(InstancePtr);
		}
	}
}

#endif /* OCCUPANCY_COUNTER_H_ */
