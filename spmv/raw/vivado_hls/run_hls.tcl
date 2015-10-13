############################################################
## This file is generated automatically by Vivado HLS.
## Please DO NOT edit it.
## Copyright (C) 2015 Xilinx Inc. All rights reserved.
############################################################
open_project spmv
set_top spmv
add_files spmv.h
add_files spmv.cpp
add_files -tb spmv_tb.cpp
open_solution "solution1"
set_part {xc7z020clg484-1}
create_clock -period 8 -name default
set_clock_uncertainty 0.5
source "./directives.tcl"
csim_design -clean
csynth_design
export_design -format ip_catalog
