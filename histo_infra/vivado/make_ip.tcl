set histo_common_anc_dir /tools/designs/chengs/everything/dpp_manual/histo_infra
create_project project_1 $histo_common_anc_dir/vivado/project_1 -part xc7z020clg484-1
set_property board_part em.avnet.com:zed:part0:1.3 [current_project]
add_files -norecurse $histo_common_anc_dir/src/occupancy_counter.v
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
ipx::package_project -root_dir $histo_common_anc_dir/ip_depo -vendor WireleSuns -library user -taxonomy /UserIP -force
set_property core_revision 1 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
set_property  ip_repo_paths  $histo_common_anc_dir/ip_depo [current_project]
update_ip_catalog
