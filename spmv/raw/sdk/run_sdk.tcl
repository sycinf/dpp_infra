set common_anc_dir /tools/designs/chengs/everything/dpp_manual/spmv/raw
set proj_name spmv
sdk set_workspace $common_anc_dir/sdk/project_1/project_1.sdk
sdk create_hw_project -name hw_prj -hwspec $common_anc_dir/sdk/project_1/project_1.sdk/design_1_wrapper.hdf
sdk create_bsp_project -name bsp_prj -hwproject hw_prj -proc ps7_cortexa9_0 -os standalone
sdk create_app_project -name $proj_name -hwproject hw_prj -proc ps7_cortexa9_0 -os standalone -lang C -app {Hello World} -bsp bsp_prj
file copy -force $common_anc_dir/sdk/helloworld.c $common_anc_dir/sdk/project_1/project_1.sdk/$proj_name/src/helloworld.c
file copy -force $common_anc_dir/sdk/lscript.ld $common_anc_dir/sdk/project_1/project_1.sdk/$proj_name/src/lscript.ld
sdk build_project -type bsp -name bsp_prj
sdk build_project -type app -name $proj_name

