#!/bin/bash

OPENROAD_FLOW_ORGA=dnltz
OPENROAD_FLOW_VERSION=53a9b78f1f8e851c45d5e3cfa90e3bd854ca0cd7

NAFARR_VERSION=072bf1ed3125a92e6f09c876c9040179b8d698a0
ZIBAL_VERSION=6d3c9b406c102cf7dfa8b3210aa90104651952a9

function fetch_elements {
	mkdir -p modules/elements
	cd modules/elements/
	git clone https://github.com/SpinalHDL/SpinalCrypto.git
	cd SpinalCrypto
	git checkout 27e0ceb430ac
	cd ../
	git clone https://github.com/aesc-silicon/elements-nafarr.git nafarr
	cd nafarr
	git checkout ${NAFARR_VERSION}
	cd ../
	git clone https://github.com/aesc-silicon/elements-zibal.git zibal
	cd zibal
	git checkout ${ZIBAL_VERSION}
	cd ../
	git clone https://github.com/aesc-silicon/elements-vexriscv.git vexriscv
	cd vexriscv
	git checkout 15e5d08322ef
	cd ../
	cd ../../
}

function fetch_elemrv {
	mkdir -p tools/OpenROAD-flow-scripts/flow/designs/ihp-sg13g2/
	cd tools/OpenROAD-flow-scripts/flow/designs/ihp-sg13g2/
	git clone https://github.com/SteffenReith/ElemRV.git
	cd -
}

function install_orfs {
	mkdir -p tools
	cd tools
	git clone https://github.com/${OPENROAD_FLOW_ORGA}/OpenROAD-flow-scripts.git
	cd OpenROAD-flow-scripts/
	git checkout ${OPENROAD_FLOW_VERSION}
	git submodule update --init --recursive --progress
	cd ../../
}

function install_gdsiistl {
	mkdir -p tools
	cd tools
	git clone https://github.com/aesc-silicon/gdsiistl.git
	cd gdsiistl
	virtualenv venv
	source venv/bin/activate
	pip3 install -r requirements.txt
	cd ../../
}

function clone_release_repro {
	mkdir -p modules
	cd modules
	git clone https://github.com/SteffenReith/IHP-Open-DesignLib.git
        cd ..
}

function print_usage {
	echo "init.sh [-h]"
	echo "\t-h: Show this help message"
}

while getopts h flag
do
	case "${flag}" in
		h) print_usage
			exit 1;;
	esac
done

if ! test -d "modules/elements"; then
	fetch_elements
fi
if ! test -d "tools/OpenROAD-flow-scripts"; then
	install_orfs
	fetch_elemrv
fi
if ! test -d "tools/gdsiistl"; then
	install_gdsiistl
fi

if ! test -d "modules/IHP-Open-DesignLib"; then
	clone_release_repro
fi
