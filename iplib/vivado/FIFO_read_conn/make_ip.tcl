set histo_common_anc_dir /tools/designs/chengs/everything/dpp_manual/iplib/
create_project project_1 $histo_common_anc_dir/vivado/FIFO_read_conn/project_1 -part xc7z020clg484-1
set_property board_part em.avnet.com:zed:part0:1.3 [current_project]
add_files -norecurse $histo_common_anc_dir/src/FIFO_read_conn.v
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
ipx::package_project -root_dir $histo_common_anc_dir/ip_depo -vendor WireleSuns -library user -taxonomy /UserIP -force
set_property core_revision 1 [ipx::current_core]
ipx::add_bus_interface read_from_fifo_rtl [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:interface:fifo_read_rtl:1.0 [ipx::get_bus_interfaces read_from_fifo_rtl -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:interface:fifo_read:1.0 [ipx::get_bus_interfaces read_from_fifo_rtl -of_objects [ipx::current_core]]
set_property interface_mode master [ipx::get_bus_interfaces read_from_fifo_rtl -of_objects [ipx::current_core]]
ipx::add_port_map RD_DATA [ipx::get_bus_interfaces read_from_fifo_rtl -of_objects [ipx::current_core]]
set_property physical_name din_src [ipx::get_port_maps RD_DATA -of_objects [ipx::get_bus_interfaces read_from_fifo_rtl -of_objects [ipx::current_core]]]
ipx::add_port_map RD_EN [ipx::get_bus_interfaces read_from_fifo_rtl -of_objects [ipx::current_core]]
set_property physical_name rd_en_src [ipx::get_port_maps RD_EN -of_objects [ipx::get_bus_interfaces read_from_fifo_rtl -of_objects [ipx::current_core]]]
ipx::add_port_map EMPTY [ipx::get_bus_interfaces read_from_fifo_rtl -of_objects [ipx::current_core]]
set_property physical_name empty_src [ipx::get_port_maps EMPTY -of_objects [ipx::get_bus_interfaces read_from_fifo_rtl -of_objects [ipx::current_core]]]
ipx::add_bus_interface read_to_hls_acc [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:interface:acc_fifo_read_rtl:1.0 [ipx::get_bus_interfaces read_to_hls_acc -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:interface:acc_fifo_read:1.0 [ipx::get_bus_interfaces read_to_hls_acc -of_objects [ipx::current_core]]
ipx::add_port_map RD_DATA [ipx::get_bus_interfaces read_to_hls_acc -of_objects [ipx::current_core]]
set_property physical_name din [ipx::get_port_maps RD_DATA -of_objects [ipx::get_bus_interfaces read_to_hls_acc -of_objects [ipx::current_core]]]
ipx::add_port_map RD_EN [ipx::get_bus_interfaces read_to_hls_acc -of_objects [ipx::current_core]]
set_property physical_name rd_en [ipx::get_port_maps RD_EN -of_objects [ipx::get_bus_interfaces read_to_hls_acc -of_objects [ipx::current_core]]]
ipx::add_port_map EMPTY_N [ipx::get_bus_interfaces read_to_hls_acc -of_objects [ipx::current_core]]
set_property physical_name empty_n [ipx::get_port_maps EMPTY_N -of_objects [ipx::get_bus_interfaces read_to_hls_acc -of_objects [ipx::current_core]]]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
set_property  ip_repo_paths  $histo_common_anc_dir/ip_depo [current_project]
update_ip_catalog
