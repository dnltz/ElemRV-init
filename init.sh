#!/bin/bash

PATH=${PWD}/oss-cad-suite/bin/:$PATH
OSS_CAD_SUITE_DATE="2024-04-16"
OSS_CAD_SUITE_STAMP="${OSS_CAD_SUITE_DATE//-}"

OPENROAD_VERSION=2024-04-16
OPENROAD_FLOW_VERSION=5ef5a3ebb51
KLAYOUT_VERSION=0.29.0

function fetch_elements {
	mkdir -p modules/elements
	cd modules/elements/
	git clone git@github.com:SpinalHDL/SpinalCrypto.git
	cd SpinalCrypto
	git checkout 27e0ceb430ac
	cd ../
	git clone git@github.com:aesc-silicon/elements-nafarr.git nafarr
	cd nafarr
	git checkout 281930a5e879
	cd ../
	git clone git@github.com:aesc-silicon/elements-zibal.git zibal
	cd zibal
	git checkout ec5c139b4fe6
	cd ../
	git clone git@github.com:aesc-silicon/elements-vexriscv.git vexriscv
	cd vexriscv
	git checkout 1ea2027464a1
	cd ../
	cd ../../
}

function fetch_oss_cad_suite_build {
	wget https://github.com/YosysHQ/oss-cad-suite-build/releases/download/${OSS_CAD_SUITE_DATE}/oss-cad-suite-linux-x64-${OSS_CAD_SUITE_STAMP}.tgz
	tar -xvf oss-cad-suite-linux-x64-${OSS_CAD_SUITE_STAMP}.tgz
	rm oss-cad-suite-linux-x64-${OSS_CAD_SUITE_STAMP}.tgz
}

function install_pdk {
	mkdir -p pdks
	cd pdks/
	git clone git@github.com:dnltz/IHP-Open-PDK.git
	cd IHP-Open-PDK
	git checkout -t origin/WIP/dnltz/io-verilog
        cd ihp-sg13g2/libs.ref/sg13g2_io/verilog
	cp sg13g2_io.v ../../../../../
        cd ../lef
        cp bondpad_70x70.lef ../../../../../
	cd ../../../../../
	mv IHP-Open-PDK IHP-Open-PDK_Daniel
	git clone git@github.com:IHP-GmbH/IHP-Open-PDK.git
	cd IHP-Open-PDK
	git checkout dev
	cd ../
	mkdir IHP-Open-PDK/ihp-sg13g2/libs.ref/sg13g2_io/verilog
	cp sg13g2_io.v IHP-Open-PDK/ihp-sg13g2/libs.ref/sg13g2_io/verilog
        cp bondpad_70x70.lef IHP-Open-PDK/ihp-sg13g2/libs.ref/sg13g2_io/lef
	cd ../
}

function install_openroad {
        sudo add-apt-repository -y ppa:deadsnakes/ppa
        sudo apt-get update
        sudo apt-get install -y python3.9 python3.9-dev python3-pip libpython3.9
	mkdir -p tools
	cd tools
	wget https://github.com/Precision-Innovations/OpenROAD/releases/download/${OPENROAD_VERSION}/openroad_2.0_amd64-debian11-${OPENROAD_VERSION}.deb
	sudo apt install -y ./openroad_2.0_amd64-debian11-${OPENROAD_VERSION}.deb
	wget https://www.klayout.org/downloads/Ubuntu-22/klayout_${KLAYOUT_VERSION}-1_amd64.deb
	sudo apt install -y ./klayout_${KLAYOUT_VERSION}-1_amd64.deb
	rm ./*.deb
	git clone https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts.git
	cd OpenROAD-flow-scripts/
	git checkout ${OPENROAD_FLOW_VERSION}
	git submodule update --init --recursive
	cd flow/designs/ihp-sg13g2/
	git clone git@github.com:SteffenReith/ElemRV.git
	cd ../../../
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
if ! test -d "oss-cad-suite"; then
	fetch_oss_cad_suite_build
fi
if ! test -d "pdks"; then
	install_pdk
fi
if ! test -d "tools/OpenROAD-flow-scripts"; then
	install_openroad
fi
if ! test -d "tools/gdsiistl"; then
	install_gdsiistl
fi
