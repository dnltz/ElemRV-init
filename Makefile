SHELL := /bin/bash

.EXPORT_ALL_VARIABLES:

PATH=${PWD}/oss-cad-suite/bin/:${PWD}/tools/magic/build/bin/:$(shell printenv PATH)
OPENROAD_FLOW_ROOT=${PWD}/tools/OpenROAD-flow-scripts/flow
CAD_ROOT=${PWD}/tools/magic/build/lib/
OPENROAD_EXE=/usr/bin/openroad
YOSYS_CMD=${PWD}/oss-cad-suite/bin/yosys

SG13G2_IO_DIR_PATH=${PWD}/pdks/IHP-Open-PDK/

OSS_CAD_SUITE_DATE="2024-04-18"
OSS_CAD_SUITE_STAMP="${OSS_CAD_SUITE_DATE//-}"



sg13g2-synthesize:
	source ${OPENROAD_FLOW_ROOT}/../env.sh && make -C ${OPENROAD_FLOW_ROOT} DESIGN_CONFIG=${OPENROAD_FLOW_ROOT}/designs/ihp-sg13g2/ElemRV/config.mk

sg13g2-gui:
	openroad -gui <(echo read_db ${OPENROAD_FLOW_ROOT}/results/ihp-sg13g2/ElemRV/base/6_final.odb)

# Misc.
clean:
	rm -rf build/
