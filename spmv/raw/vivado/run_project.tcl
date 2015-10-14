set common_anc_dir /tools/designs/chengs/everything/dpp_manual/spmv/raw
create_project project_1 $common_anc_dir/vivado/project_1 -part xc7z020clg484-1
set_property board_part em.avnet.com:zed:part0:1.3 [current_project]
create_bd_design "design_1"
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
endgroup
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]
set_property  ip_repo_paths  $common_anc_dir/vivado_hls [current_project]
update_ip_catalog
startgroup
create_bd_cell -type ip -vlnv xilinx.com:hls:spmv:1.0 spmv_0
endgroup
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins spmv_0/s_axi_AXILiteS]
startgroup
set_property -dict [list CONFIG.PCW_USE_S_AXI_ACP {1} CONFIG.PCW_USE_DEFAULT_ACP_USER_VAL {1}] [get_bd_cells processing_system7_0]
endgroup
startgroup
set_property -dict [list CONFIG.C_M_AXI_Y_CACHE_VALUE {"1111"} CONFIG.C_M_AXI_PTR_CACHE_VALUE {"1111"} CONFIG.C_M_AXI_VALARRAY_CACHE_VALUE {"1111"} CONFIG.C_M_AXI_INDARRAY_CACHE_VALUE {"1111"} CONFIG.C_M_AXI_XVEC_CACHE_VALUE {"1111"}] [get_bd_cells spmv_0]
endgroup
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/spmv_0/m_axi_y" Clk "Auto" }  [get_bd_intf_pins processing_system7_0/S_AXI_ACP]
startgroup
set_property -dict [list CONFIG.NUM_SI {5} CONFIG.STRATEGY {2} CONFIG.ENABLE_ADVANCED_OPTIONS {0} CONFIG.NUM_MI {1} CONFIG.S00_HAS_DATA_FIFO {2} CONFIG.S01_HAS_DATA_FIFO {2} CONFIG.S02_HAS_DATA_FIFO {2} CONFIG.S03_HAS_DATA_FIFO {2} CONFIG.S04_HAS_DATA_FIFO {2}] [get_bd_cells axi_mem_intercon]
endgroup
connect_bd_intf_net [get_bd_intf_pins spmv_0/m_axi_ptr] -boundary_type upper [get_bd_intf_pins axi_mem_intercon/S01_AXI]
connect_bd_intf_net [get_bd_intf_pins spmv_0/m_axi_valArray] -boundary_type upper [get_bd_intf_pins axi_mem_intercon/S02_AXI]
connect_bd_intf_net [get_bd_intf_pins spmv_0/m_axi_indArray] -boundary_type upper [get_bd_intf_pins axi_mem_intercon/S03_AXI]
connect_bd_intf_net [get_bd_intf_pins spmv_0/m_axi_xvec] -boundary_type upper [get_bd_intf_pins axi_mem_intercon/S04_AXI]
startgroup
set_property -dict [list CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {125.000000}] [get_bd_cells processing_system7_0]
endgroup
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_mem_intercon/S01_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_mem_intercon/S02_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_mem_intercon/S03_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_mem_intercon/S04_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_mem_intercon/S01_ARESETN] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_mem_intercon/S02_ARESETN] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_mem_intercon/S03_ARESETN] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_mem_intercon/S04_ARESETN] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
assign_bd_address
include_bd_addr_seg [get_bd_addr_segs -excluded spmv_0/Data_m_axi_y/SEG_processing_system7_0_ACP_IOP]
include_bd_addr_seg [get_bd_addr_segs -excluded spmv_0/Data_m_axi_y/SEG_processing_system7_0_ACP_M_AXI_GP0]
include_bd_addr_seg [get_bd_addr_segs -excluded spmv_0/Data_m_axi_ptr/SEG_processing_system7_0_ACP_IOP]
include_bd_addr_seg [get_bd_addr_segs -excluded spmv_0/Data_m_axi_ptr/SEG_processing_system7_0_ACP_M_AXI_GP0]
include_bd_addr_seg [get_bd_addr_segs -excluded spmv_0/Data_m_axi_valArray/SEG_processing_system7_0_ACP_IOP]
include_bd_addr_seg [get_bd_addr_segs -excluded spmv_0/Data_m_axi_valArray/SEG_processing_system7_0_ACP_M_AXI_GP0]
include_bd_addr_seg [get_bd_addr_segs -excluded spmv_0/Data_m_axi_indArray/SEG_processing_system7_0_ACP_IOP]
include_bd_addr_seg [get_bd_addr_segs -excluded spmv_0/Data_m_axi_indArray/SEG_processing_system7_0_ACP_M_AXI_GP0]
include_bd_addr_seg [get_bd_addr_segs -excluded spmv_0/Data_m_axi_xvec/SEG_processing_system7_0_ACP_IOP]
include_bd_addr_seg [get_bd_addr_segs -excluded spmv_0/Data_m_axi_xvec/SEG_processing_system7_0_ACP_M_AXI_GP0]
validate_bd_design
make_wrapper -files [get_files $common_anc_dir/vivado/project_1/project_1.srcs/sources_1/bd/design_1/design_1.bd] -top
add_files -norecurse $common_anc_dir/vivado/project_1/project_1.srcs/sources_1/bd/design_1/hdl/design_1_wrapper.v
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
launch_runs impl_1 -to_step write_bitstream
wait_on_run -timeout 20 impl_1
#file mkdir $common_anc_dir/vivado/project_1/project_1.sdk
#%file copy -force $common_anc_dir/vivado/project_1/project_1.runs/impl_1/design_1_wrapper.sysdef $common_anc_dir/vivado/project_1/project_1.sdk/design_1_wrapper.hdf
file mkdir $common_anc_dir/sdk/project_1/project_1.sdk
file copy -force $common_anc_dir/vivado/project_1/project_1.runs/impl_1/design_1_wrapper.sysdef $common_anc_dir/sdk/project_1/project_1.sdk/design_1_wrapper.hdf
