set histo_common_anc_dir /tools/designs/chengs/everything/dpp_manual/iplib/
create_project project_1 $histo_common_anc_dir/vivado/FIFO_write_conn/project_1 -part xc7z020clg484-1
set_property board_part em.avnet.com:zed:part0:1.3 [current_project]
add_files -norecurse $histo_common_anc_dir/src/FIFO_write_conn.v
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
ipx::package_project -root_dir $histo_common_anc_dir/ip_depo/FIFO_write_conn -vendor WireleSuns -library user -taxonomy /UserIP -force
set_property core_revision 1 [ipx::current_core]

ipx::add_bus_interface write_to_fifo_rtl [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:interface:fifo_write_rtl:1.0 [ipx::get_bus_interfaces write_to_fifo_rtl -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:interface:fifo_write:1.0 [ipx::get_bus_interfaces write_to_fifo_rtl -of_objects [ipx::current_core]]
set_property interface_mode master [ipx::get_bus_interfaces write_to_fifo_rtl -of_objects [ipx::current_core]]
ipx::add_port_map WR_DATA [ipx::get_bus_interfaces write_to_fifo_rtl -of_objects [ipx::current_core]]
set_property physical_name din [ipx::get_port_maps WR_DATA -of_objects [ipx::get_bus_interfaces write_to_fifo_rtl -of_objects [ipx::current_core]]]
ipx::add_port_map WR_EN [ipx::get_bus_interfaces write_to_fifo_rtl -of_objects [ipx::current_core]]
set_property physical_name wr_en [ipx::get_port_maps WR_EN -of_objects [ipx::get_bus_interfaces write_to_fifo_rtl -of_objects [ipx::current_core]]]
ipx::add_port_map FULL [ipx::get_bus_interfaces write_to_fifo_rtl -of_objects [ipx::current_core]]
set_property physical_name full [ipx::get_port_maps FULL -of_objects [ipx::get_bus_interfaces write_to_fifo_rtl -of_objects [ipx::current_core]]]



ipx::add_bus_interface write_from_hls_acc [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:interface:acc_fifo_write_rtl:1.0 [ipx::get_bus_interfaces write_from_hls_acc -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:interface:acc_fifo_write:1.0 [ipx::get_bus_interfaces write_from_hls_acc -of_objects [ipx::current_core]]
ipx::add_port_map WR_DATA [ipx::get_bus_interfaces write_from_hls_acc -of_objects [ipx::current_core]]
set_property physical_name dout_src [ipx::get_port_maps WR_DATA -of_objects [ipx::get_bus_interfaces write_from_hls_acc -of_objects [ipx::current_core]]]
ipx::add_port_map WR_EN [ipx::get_bus_interfaces write_from_hls_acc -of_objects [ipx::current_core]]
set_property physical_name wr_en_src [ipx::get_port_maps WR_EN -of_objects [ipx::get_bus_interfaces write_from_hls_acc -of_objects [ipx::current_core]]]
ipx::add_port_map FULL_N [ipx::get_bus_interfaces write_from_hls_acc -of_objects [ipx::current_core]]
set_property physical_name full_n [ipx::get_port_maps FULL_N -of_objects [ipx::get_bus_interfaces write_from_hls_acc -of_objects [ipx::current_core]]]


ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
set_property  ip_repo_paths  $histo_common_anc_dir/ip_depo/FIFO_write_conn [current_project]
update_ip_catalog
