############################################################
## This file is generated automatically by Vivado HLS.
## Please DO NOT edit it.
## Copyright (C) 2015 Xilinx Inc. All rights reserved.
############################################################
set_directive_interface -mode m_axi -depth 100 -offset slave -bundle y "spmv" y
set_directive_interface -mode m_axi -depth 200 -offset slave -bundle ptr "spmv" ptr
set_directive_interface -mode m_axi -depth 200 -offset slave -bundle valArray "spmv" valArray
set_directive_interface -mode m_axi -depth 200 -offset slave -bundle indArray "spmv" indArray
set_directive_interface -mode m_axi -depth 200 -offset slave -bundle xvec "spmv" xvec
set_directive_interface -mode s_axilite -register "spmv" dim
set_directive_interface -mode s_axilite -register "spmv"
set_directive_pipeline "spmv/spmv_label0"
