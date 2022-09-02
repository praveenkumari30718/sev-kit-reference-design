#
# // PFSoC SEV Kit H264 I frame Encoder demo Libero design
#
# // Check Libero version and path lenth to verify project can be created
#

if {[string compare [string range [get_libero_version] 0 end-3] "2022.2.0"]==0} {
	puts "Libero v2022.2 detected."
} else {
	error "Incorrect Libero version. Please use Libero v2022.2 to run these scripts."
}

if { [lindex $tcl_platform(os) 0]  == "Windows" } {
	if {[string length [pwd]] < 90} {
		puts "Project path length ok."
	} else {
		error "Path to project is too long, please reduce the path and try again."
	}
}

#
# // Process arguments
#

if { $::argc > 0 } {
    set i 1
    foreach arg $::argv {
        if {[string match "*:*" $arg]} {
            set temp [split $arg ":"]
            puts "Setting parameter [lindex $temp 0] to [lindex $temp 1]"
            set [lindex $temp 0] "[lindex $temp 1]"
        } else {
            set $arg 1
            puts "set $arg to 1"
        }
        incr i
    }
} else {
    puts "no command line argument passed"
}

#
# // Set required variables and add functions
#

set install_loc [defvar_get -name ACTEL_SW_DIR]
set mss_config_loc "$install_loc/bin64/pfsoc_mss"
set local_dir [pwd]
set src_path ./script_support
set constraint_path ./script_support/constraint
set release_tag "2022.2"
set project_name "SEVPFSOC_H264"
set project_dir "$local_dir/$project_name"

#
# // Create Libero project
#
new_project \
	-location $project_name \
	-name $project_name \
	-project_description {} \
	-block_mode 0 \
	-standalone_peripheral_initialization 0 \
	-instantiate_in_smartdesign 1 \
	-ondemand_build_dh 1 \
	-use_relative_path 0 \
	-linked_files_root_dir_env {} \
	-hdl {VERILOG} \
	-family {PolarFireSoC} \
	-die {MPFS250T_ES} \
	-package {FCG1152} \
	-speed {-1} \
	-die_voltage {1.0} \
	-part_range {EXT} \
	-adv_options {IO_DEFT_STD:LVCMOS 1.8V} \
	-adv_options {RESTRICTPROBEPINS:1} \
	-adv_options {RESTRICTSPIPINS:0} \
	-adv_options {SYSTEM_CONTROLLER_SUSPEND_MODE:0} \
	-adv_options {TEMPR:EXT} \
	-adv_options {VCCI_1.2_VOLTR:EXT} \
	-adv_options {VCCI_1.5_VOLTR:EXT} \
	-adv_options {VCCI_1.8_VOLTR:EXT} \
	-adv_options {VCCI_2.5_VOLTR:EXT} \
	-adv_options {VCCI_3.3_VOLTR:EXT} \
	-adv_options {VOLTR:EXT}

#
# // Download required cores
#

download_core -vlnv {Microsemi:SolutionCore:Bayer_Interpolation:4.2.0} -location {www.microchip-ip.com/repositories/DirectCore}
download_core -vlnv {Actel:DirectCore:CoreAPB3:4.2.100} -location {www.microchip-ip.com/repositories/DirectCore}
download_core -vlnv {Actel:DirectCore:CORERESET_PF:2.3.100} -location {www.microchip-ip.com/repositories/DirectCore}
download_core -vlnv {Actel:DirectCore:CORERXIODBITALIGN:2.2.100} -location {www.microchip-ip.com/repositories/DirectCore}
download_core -vlnv {Microsemi:SolutionCore:Gamma_Correction:4.2.0} -location {www.microchip-ip.com/repositories/DirectCore}
download_core -vlnv {Microsemi:SolutionCore:Image_Enhancement:4.3.0} -location {www.microchip-ip.com/repositories/DirectCore}
download_core -vlnv {Microsemi:SolutionCore:IMAGE_SCALER:4.0.0} -location {www.microchip-ip.com/repositories/DirectCore}
download_core -vlnv {Microsemi:SgCore:PFSOC_INIT_MONITOR:1.0.304} -location {www.microchip-ip.com/repositories/SgCore}
download_core -vlnv {Microsemi:SolutionCore:mipicsi2rxdecoderPF:4.4.0} -location {www.microchip-ip.com/repositories/DirectCore}
download_core -vlnv {Actel:SgCore:PF_CCC:2.2.214} -location {www.microchip-ip.com/repositories/SgCore}
download_core -vlnv {Actel:SgCore:PF_CLK_DIV:1.0.103} -location {www.microchip-ip.com/repositories/SgCore}
download_core -vlnv {Actel:SystemBuilder:PF_IOD_GENERIC_RX:2.1.109} -location {www.microchip-ip.com/repositories/SgCore}
download_core -vlnv {Actel:SgCore:PF_OSC:1.0.102} -location {www.microchip-ip.com/repositories/SgCore}
download_core -vlnv {Microsemi:SolutionCore:RGBtoYCbCr:4.4.0} -location {www.microchip-ip.com/repositories/DirectCore}
download_core -vlnv {Actel:SgCore:PF_XCVR_REF_CLK:1.0.103} -location {www.microchip-ip.com/repositories/SgCore}
download_core -vlnv {Microsemi:SolutionCore:DDR_AXI4_ARBITER_PF:2.1.0} -location {www.microchip-ip.com/repositories/DirectCore}
download_core -vlnv {Microchip:SolutionCore:H264_Iframe_Encoder:1.3.0} -location {www.microchip-ip.com/repositories/DirectCore}


#
# // Generate base design
#
exec $mss_config_loc -GENERATE -CONFIGURATION_FILE:$src_path/MSS_SEV/MSS_SEV.cfg -OUTPUT_DIR:${src_path}/MSS_SEV
import_mss_component -file "$src_path/MSS_SEV/MSS_SEV.cxz"


#This Tcl file sources other Tcl files to build the design(on which recursive export is run) in a bottom-up fashion

#Sourcing the Tcl file in which all the HDL source files used in the design are imported or linked
source ${src_path}/hdl_source.tcl
build_design_hierarchy

#Sourcing the Tcl files in which HDL+ core definitions are created for HDL modules
source ${src_path}/components/video_fifo.tcl 
source ${src_path}/components/apb3_if.tcl
source ${src_path}/components/H264/data_packer_h264.tcl
build_design_hierarchy

#Sourcing the Tcl files for creating individual ${src_path}/components under the top level
source ${src_path}/components/Bayer_Interpolation_C0.tcl
source ${src_path}/components/CoreAPB3_C0.tcl
source ${src_path}/components/CORERESET.tcl
source ${src_path}/components/CORERESET_PF_C1.tcl
source ${src_path}/components/CORERESET_PF_C2.tcl
source ${src_path}/components/CORERESET_PF_C5.tcl
source ${src_path}/components/CORERXIODBITALIGN_C1.tcl
source ${src_path}/components/DDR_AXI4_ARBITER_PF_C0.tcl
source ${src_path}/components/Gamma_Correction_C0.tcl
source ${src_path}/components/Image_Enhancement_C0.tcl
source ${src_path}/components/IMAGE_SCALER_C0.tcl
source ${src_path}/components/INIT_MONITOR.tcl
source ${src_path}/components/mipicsi2rxdecoderPF_C0.tcl
source ${src_path}/components/PF_CCC_C0.tcl
source ${src_path}/components/PF_CCC_C2.tcl
source ${src_path}/components/PF_CLK_DIV_C0.tcl
source ${src_path}/components/PF_OSC_C0.tcl
source ${src_path}/components/H264/RGBtoYCbCr_C0.tcl
source ${src_path}/components/PF_XCVR_REF_CLK_C0.tcl
source ${src_path}/components/CLOCKS_AND_RESETS.tcl
source ${src_path}/components/PF_IOD_GENERIC_RX_C0.tcl
source ${src_path}/components/H264/FIC_CONVERTER.tcl
source ${src_path}/components/CAM_IOD_TIP_TOP.tcl
source ${src_path}/components/IMX334_IF_TOP.tcl
source ${src_path}/components/H264/H264_Iframe_Encoder_C0.tcl
source ${src_path}/components/H264/H264_DDR_WRITE.tcl
source ${src_path}/components/H264/h264_top.tcl
source ${src_path}/components/video_processing.tcl
source ${src_path}/components/H264/Video_Pipeline.tcl
source ${src_path}/components/H264/SEVPFSOC_H264.tcl
build_design_hierarchy
set_root -module {SEVPFSOC_TOP::work}
#
# // Derive timing constraints
#
derive_constraints_sdc
#
# // Import I/O constraints
#

import_files \
	-convert_EDN_to_HDL 0 \
	-io_pdc "${constraint_path}/io/SEV_MAC.pdc" \
	-io_pdc "${constraint_path}/io/SEV_MMUART0.pdc" \
	-io_pdc "${constraint_path}/io/SEV_MMUART1.pdc" \
	-io_pdc "${constraint_path}/io/user.pdc" \

set_as_target -type {io_pdc} -file "${constraint_path}/io/user.pdc"

#
# // Import floor planning constraints
#

import_files -convert_EDN_to_HDL 0 -fp_pdc "${constraint_path}/fp/user.pdc"
#
# // Import timing constraint
#

import_files \
	-convert_EDN_to_HDL 0 \
	-sdc "${constraint_path}/user.sdc"
set_as_target -type {sdc} -file "${constraint_path}/user.sdc"    
#
# // Associate imported constraints with the design flow
#
organize_tool_files -tool {SYNTHESIZE} \
  -file "${project_dir}/constraint/SEVPFSOC_TOP_derived_constraints.sdc" \
  -module {SEVPFSOC_TOP::work} \
  -input_type {constraint} 
  
organize_tool_files -tool {PLACEROUTE} \
    -file "${project_dir}/constraint/io/SEV_MAC.pdc" \
    -file "${project_dir}/constraint/io/SEV_MMUART0.pdc" \
    -file "${project_dir}/constraint/io/SEV_MMUART1.pdc" \
    -file "${project_dir}/constraint/io/user.pdc" \
    -file "${project_dir}/constraint/SEVPFSOC_TOP_derived_constraints.sdc" \
    -file "${project_dir}/constraint/user.sdc" \
    -file "${project_dir}/constraint/fp/user.pdc" \
    -module {SEVPFSOC_TOP::work} \
    -input_type {constraint}

set_as_target -type {io_pdc} -file "${project_dir}/constraint/io/user.pdc"
save_project

organize_tool_files -tool {VERIFYTIMING} \
    -file "${project_dir}/constraint/SEVPFSOC_TOP_derived_constraints.sdc" \
    -file "${project_dir}/constraint/user.sdc" \
    -module {SEVPFSOC_TOP::work} \
    -input_type {constraint}

#
# // Run the design flow and add eNVM clients 
#
if {[info exists SYNTHESIZE]} {
    run_tool -name {SYNTHESIZE}
} 
configure_tool -name {VERIFYTIMING} -params {CONSTRAINTS_COVERAGE:1} -params {FORMAT:XML} -params {MAX_EXPANDED_PATHS_TIMING:1} -params {MAX_EXPANDED_PATHS_VIOLATION:0} -params {MAX_PARALLEL_PATHS_TIMING:1} -params {MAX_PARALLEL_PATHS_VIOLATION:1} -params {MAX_PATHS_INTERACTIVE_REPORT:1000} -params {MAX_PATHS_TIMING:5} -params {MAX_PATHS_VIOLATION:20} -params {MAX_TIMING_FAST_HV_LT:1} -params {MAX_TIMING_MULTI_CORNER:1} -params {MAX_TIMING_SLOW_LV_HT:1} -params {MAX_TIMING_SLOW_LV_LT:1} -params {MAX_TIMING_VIOLATIONS_FAST_HV_LT:1} -params {MAX_TIMING_VIOLATIONS_MULTI_CORNER:1} -params {MAX_TIMING_VIOLATIONS_SLOW_LV_HT:1} -params {MAX_TIMING_VIOLATIONS_SLOW_LV_LT:1} -params {MIN_TIMING_FAST_HV_LT:1} -params {MIN_TIMING_MULTI_CORNER:1} -params {MIN_TIMING_SLOW_LV_HT:1} -params {MIN_TIMING_SLOW_LV_LT:1} -params {MIN_TIMING_VIOLATIONS_FAST_HV_LT:1} -params {MIN_TIMING_VIOLATIONS_MULTI_CORNER:1} -params {MIN_TIMING_VIOLATIONS_SLOW_LV_HT:1} -params {MIN_TIMING_VIOLATIONS_SLOW_LV_LT:1} -params {SLACK_THRESHOLD_VIOLATION:0.0} -params {SMART_INTERACTIVE:1} 
configure_tool -name {PLACEROUTE} -params {DELAY_ANALYSIS:MAX} -params {EFFORT_LEVEL:true} -params {GB_DEMOTION:true} -params {INCRPLACEANDROUTE:false} -params {IOREG_COMBINING:false} -params {MULTI_PASS_CRITERIA:VIOLATIONS} -params {MULTI_PASS_LAYOUT:false} -params {NUM_MULTI_PASSES:5} -params {PDPR:false} -params {RANDOM_SEED:0} -params {REPAIR_MIN_DELAY:false} -params {REPLICATION:true} -params {SLACK_CRITERIA:WORST_SLACK} -params {SPECIFIC_CLOCK:} -params {START_SEED_INDEX:1} -params {STOP_ON_FIRST_PASS:false} -params {TDPR:true} 

if {[info exists PLACEROUTE]} {
    run_tool -name {PLACEROUTE}
} elseif {[info exists VERIFY_TIMING]} {
    run_tool -name {VERIFYTIMING}
}

save_project

if {[info exists GENERATE_PROGRAMMING_DATA]} {
    run_tool -name {GENERATEPROGRAMMINGDATA} 
    configure_envm -cfg_file "${src_path}/ENVM.cfg"
}  elseif {[info exists PROGRAM]} {
    run_tool -name {GENERATEPROGRAMMINGDATA} 
    configure_envm -cfg_file "${src_path}/ENVM.cfg"
    run_tool -name {PROGRAMDEVICE}
} elseif {[info exists EXPORT_FPE]} {   
    run_tool -name {GENERATEPROGRAMMINGDATA} 
    configure_envm -cfg_file "${src_path}/ENVM.cfg" 
    if {$EXPORT_FPE == 1} {
        export_prog_job -job_file_name $project_name -export_dir $local_dir -bitstream_file_components "ENVM FABRIC_SNVM"
    } else {
        export_prog_job -job_file_name $project_name -export_dir $EXPORT_FPE -bitstream_file_components "ENVM FABRIC_SNVM"
    }    
}