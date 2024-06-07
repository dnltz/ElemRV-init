SHELL := /bin/bash

.EXPORT_ALL_VARIABLES:

INSTALL_PATH=/opt/elements/
PATH=${INSTALL_PATH}/oss-cad-suite/bin/:${INSTALL_PATH}/tools/magic/build/bin/:$(shell printenv PATH)
OPENROAD_FLOW_ROOT=${PWD}/tools/OpenROAD-flow-scripts/flow
CAD_ROOT=${INSTALL_PATH}/tools/magic/build/lib/
OPENROAD_EXE=/usr/bin/openroad
YOSYS_CMD=${INSTALL_PATH}/oss-cad-suite/bin/yosys

KLAYOUT_HOME=${INSTALL_PATH}/pdks/IHP-Open-PDK/ihp-sg13g2/libs.tech/klayout/
XILINX_HOME=/opt/xilinx/Vivado/2020.2/

BOARD=SG13G2
SOC=ElemRV
FPGA_FAMILY=ecp5
FPGA_DEVICE=um5g-45k
FPGA_PACKAGE=CABGA554
FPGA_FREQUENCY=50
OPENFPGALOADER_BOARD=ecpix5_r03
NAFARR_BASE=${PWD}/modules/elements/nafarr/
ZIBAL_BASE=${PWD}/modules/elements/zibal/
BUILD_ROOT=${ZIBAL_BASE}/build/
ELEMENTS_BASE=${ZIBAL_BASE}
GCC=${INSTALL_PATH}/zephyr-sdk-0.16.5/riscv64-zephyr-elf/bin/riscv64-zephyr-elf

tapeout: sg13g2-synthesize sg13g2-drc sg13g2-drc-gui
.PHONY: tapeout

ecpix5-generate:
	cd modules/elements/zibal && BOARD=ECPIX5 sbt "runMain elements.soc.elemrv.ECPIX5Generate"

ecpix5-synthesize:
	BOARD=ECPIX5 ${ZIBAL_BASE}/eda/Lattice/fpga/syn.sh

ecpix5-flash:
	openFPGALoader -b ${OPENFPGALOADER_BOARD} ${BUILD_ROOT}/${SOC}/ECPIX5/fpga/ECPIX5Top.bit

sg13g2-generate:
	cd modules/elements/zibal && sbt "runMain elements.soc.elemrv.SG13G2Generate"

sg13g2-compile:
	make -C ${ZIBAL_BASE}/software/bootrom
	mkdir -p ${ZIBAL_BASE}/build/zephyr
	cp ${ZIBAL_BASE}/build/${SOC}/${BOARD}/bootrom/kernel.img ${ZIBAL_BASE}/build/zephyr/zephyr.bin

sg13g2-simulate:
	cd modules/elements/zibal && sbt "runMain elements.soc.elemrv.SG13G2Simulate simulate 100"
	gtkwave -o modules/elements/zibal/build/${SOC}/${BOARD}/zibal/${BOARD}Board/simulate/wave.vcd

sg13g2-synthesize:
	source ${OPENROAD_FLOW_ROOT}/../env.sh && make -C ${OPENROAD_FLOW_ROOT} DESIGN_CONFIG=${OPENROAD_FLOW_ROOT}/designs/ihp-sg13g2/ElemRV/config.mk

sg13g2-clean-synth:
	source ${OPENROAD_FLOW_ROOT}/../env.sh && make -C ${OPENROAD_FLOW_ROOT} DESIGN_CONFIG=${OPENROAD_FLOW_ROOT}/designs/ihp-sg13g2/ElemRV/config.mk clean_synth

sg13g2-clean-floorplan:
	source ${OPENROAD_FLOW_ROOT}/../env.sh && make -C ${OPENROAD_FLOW_ROOT} DESIGN_CONFIG=${OPENROAD_FLOW_ROOT}/designs/ihp-sg13g2/ElemRV/config.mk clean_floorplan

sg13g2-clean-place:
	source ${OPENROAD_FLOW_ROOT}/../env.sh && make -C ${OPENROAD_FLOW_ROOT} DESIGN_CONFIG=${OPENROAD_FLOW_ROOT}/designs/ihp-sg13g2/ElemRV/config.mk clean_place

sg13g2-clean-cts:
	source ${OPENROAD_FLOW_ROOT}/../env.sh && make -C ${OPENROAD_FLOW_ROOT} DESIGN_CONFIG=${OPENROAD_FLOW_ROOT}/designs/ihp-sg13g2/ElemRV/config.mk clean_cts

sg13g2-clean-route:
	source ${OPENROAD_FLOW_ROOT}/../env.sh && make -C ${OPENROAD_FLOW_ROOT} DESIGN_CONFIG=${OPENROAD_FLOW_ROOT}/designs/ihp-sg13g2/ElemRV/config.mk clean_route

sg13g2-clean-finish:
	source ${OPENROAD_FLOW_ROOT}/../env.sh && make -C ${OPENROAD_FLOW_ROOT} DESIGN_CONFIG=${OPENROAD_FLOW_ROOT}/designs/ihp-sg13g2/ElemRV/config.mk clean_finish

sg13g2-simulate-post-layout:
	iverilog -o elemrv_tb \
		${OPENROAD_FLOW_ROOT}/designs/ihp-sg13g2/ElemRV/test/elemrv_tb.v \
		${OPENROAD_FLOW_ROOT}/results/ihp-sg13g2/ElemRV/base/6_final.v \
		${OPENROAD_FLOW_ROOT}/platforms/ihp-sg13g2/verilog/sg13g2_stdcell.v \
		${OPENROAD_FLOW_ROOT}/platforms/ihp-sg13g2/verilog/sg13g2_io.v
	./elemrv_tb
	# Don't use gtkwave from oss-cad-suite
	/usr/bin/gtkwave -F elemrv_tb.vcd

sg13g2-simulate-post-layout-xilinx:
	$(XILINX_HOME)/bin/xvlog ${OPENROAD_FLOW_ROOT}/designs/ihp-sg13g2/ElemRV/test/elemrv_tb.v
	$(XILINX_HOME)/bin/xvlog ${OPENROAD_FLOW_ROOT}/results/ihp-sg13g2/ElemRV/base/6_final.v
	$(XILINX_HOME)/bin/xvlog ${OPENROAD_FLOW_ROOT}/platforms/ihp-sg13g2/verilog/sg13g2_stdcell.v
	$(XILINX_HOME)/bin/xvlog ${OPENROAD_FLOW_ROOT}/platforms/ihp-sg13g2/verilog/sg13g2_stdcell.v
	$(XILINX_HOME)/bin/xelab -debug typical -top elemrv_tb -snapshot elemrv_tb_snapshot
	$(XILINX_HOME)/bin/xsim elemrv_tb_snapshot --tclbatch ${OPENROAD_FLOW_ROOT}/designs/ihp-sg13g2/ElemRV/test/xsim_cfg.tcl
	$(XILINX_HOME)/bin/xsim --gui elemrv_tb_snapshot.wdb

sg13g2-openroad:
	openroad -gui <(echo read_db ${OPENROAD_FLOW_ROOT}/results/ihp-sg13g2/ElemRV/base/6_final.odb)

sg13g2-klayout:
	klayout -e -n sg13g2 ${OPENROAD_FLOW_ROOT}/results/ihp-sg13g2/ElemRV/base/6_final.gds

sg13g2-drc:
	(cd ${OPENROAD_FLOW_ROOT}/results/ihp-sg13g2/ElemRV/base && klayout -b -r ${KLAYOUT_HOME}/tech/drc/sg13g2.lydrc -rd cell=ElemRVTop ${OPENROAD_FLOW_ROOT}/results/ihp-sg13g2/ElemRV/base/6_final.gds)

sg13g2-drc-gui:
	(cd ${OPENROAD_FLOW_ROOT}/results/ihp-sg13g2/ElemRV/base && klayout 6_final.gds -m sg13g2_ElemRVTop.lyrdb)

sg13g2-release:
	mkdir -p modules/IHP-Open-DesignLib/ElemRV/OpenROAD-flow-scripts/results/ihp-13g2/ElemRV/base/
	mkdir -p modules/IHP-Open-DesignLib/ElemRV/OpenROAD-flow-scripts/designs/ihp-13g2/ElemRV/
	cp -r ${OPENROAD_FLOW_ROOT}/designs/ihp-sg13g2/ElemRV/* modules/IHP-Open-DesignLib/ElemRV/OpenROAD-flow-scripts/designs/ihp-13g2/ElemRV/
	cp ${OPENROAD_FLOW_ROOT}/results/ihp-sg13g2/ElemRV/base/1_synth.sdc modules/IHP-Open-DesignLib/ElemRV/OpenROAD-flow-scripts/results/ihp-13g2/ElemRV/base/
	cp ${OPENROAD_FLOW_ROOT}/results/ihp-sg13g2/ElemRV/base/1_synth.v modules/IHP-Open-DesignLib/ElemRV/OpenROAD-flow-scripts/results/ihp-13g2/ElemRV/base/
	cp ${OPENROAD_FLOW_ROOT}/results/ihp-sg13g2/ElemRV/base/6_final.def modules/IHP-Open-DesignLib/ElemRV/OpenROAD-flow-scripts/results/ihp-13g2/ElemRV/base/
	cp ${OPENROAD_FLOW_ROOT}/results/ihp-sg13g2/ElemRV/base/6_final.sdc modules/IHP-Open-DesignLib/ElemRV/OpenROAD-flow-scripts/results/ihp-13g2/ElemRV/base/
	cp ${OPENROAD_FLOW_ROOT}/results/ihp-sg13g2/ElemRV/base/6_final.spef modules/IHP-Open-DesignLib/ElemRV/OpenROAD-flow-scripts/results/ihp-13g2/ElemRV/base/

# Misc.
clean:
	rm -rf build/
	rm -rf ${OPENROAD_FLOW_ROOT}/results/ihp-sg13g2/ElemRV/base
	rm -rf ${OPENROAD_FLOW_ROOT}/reports/ihp-sg13g2/ElemRV/base
	rm -rf ${OPENROAD_FLOW_ROOT}/logs/ihp-sg13g2/ElemRV/base
	rm -rf elemrv_tb elemrv_tb.vcd elemrv_tb.vcd.fst
	rm -rf xsim* xvlog* xelab* webtalk* elemrv_tb_snapshot.wdb
	rm -rf *lyrdb
