#!/bin/bash

PATH=${PWD}/oss-cad-suite/bin/:$PATH
OSS_CAD_SUITE_DATE="2024-04-16"
OSS_CAD_SUITE_STAMP="${OSS_CAD_SUITE_DATE//-}"

OPENROAD_VERSION=2024-04-25
OPENROAD_FLOW_ORGA=KrzysztofHerman
# https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts/pull/2002
OPENROAD_FLOW_VERSION=f919e604b94d7673ba2a5b0227a515dc8eac4700
KLAYOUT_VERSION=0.29.0

ZEPHYR_SDK_RELEASE=0.16.5

NAFARR_VERSION=072bf1ed3125a92e6f09c876c9040179b8d698a0
ZIBAL_VERSION=6d3c9b406c102cf7dfa8b3210aa90104651952a9

function fetch_elements {
	mkdir -p modules/elements
	cd modules/elements/
	git clone git@github.com:SpinalHDL/SpinalCrypto.git
	cd SpinalCrypto
	git checkout 27e0ceb430ac
	cd ../
	git clone git@github.com:aesc-silicon/elements-nafarr.git nafarr
	cd nafarr
	git checkout ${NAFARR_VERSION}
	cd ../
	git clone git@github.com:aesc-silicon/elements-zibal.git zibal
	cd zibal
	git checkout ${ZIBAL_VERSION}
	cd ../
	git clone git@github.com:aesc-silicon/elements-vexriscv.git vexriscv
	cd vexriscv
	git checkout 15e5d08322ef
	cd ../
	cd ../../
}

function fetch_elemrv {
	mkdir -p tools/OpenROAD-flow-scripts/flow/designs/ihp-sg13g2/
	cd tools/OpenROAD-flow-scripts/flow/designs/ihp-sg13g2/
	git clone git@github.com:SteffenReith/ElemRV.git
	cd -
}

function fetch_oss_cad_suite_build {
	wget https://github.com/YosysHQ/oss-cad-suite-build/releases/download/${OSS_CAD_SUITE_DATE}/oss-cad-suite-linux-x64-${OSS_CAD_SUITE_STAMP}.tgz
	tar -xvf oss-cad-suite-linux-x64-${OSS_CAD_SUITE_STAMP}.tgz
	rm oss-cad-suite-linux-x64-${OSS_CAD_SUITE_STAMP}.tgz
}

function fetch_zephyr_sdk {
	wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_SDK_RELEASE}/zephyr-sdk-${ZEPHYR_SDK_RELEASE}_linux-x86_64.tar.xz
	wget -O - https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_SDK_RELEASE}/sha256.sum | shasum --check --ignore-missing
	tar xvf zephyr-sdk-${ZEPHYR_SDK_RELEASE}_linux-x86_64.tar.xz
	rm zephyr-sdk-${ZEPHYR_SDK_RELEASE}_linux-x86_64.tar.xz
}

function install_pdk {
	mkdir -p pdks
	cd pdks/
	git clone git@github.com:IHP-GmbH/IHP-Open-PDK.git
	cd IHP-Open-PDK
	git checkout -t origin/dev
	cd ../../
}

function install_openroad {
	sudo add-apt-repository -y ppa:deadsnakes/ppa
	sudo apt-get update
	sudo apt-get install -y python3.9 python3.9-dev python3-pip libpython3.9
	mkdir -p tools
	cd tools
	wget https://github.com/Precision-Innovations/OpenROAD/releases/download/${OPENROAD_VERSION}/openroad_2.0_amd64-ubuntu22.04-${OPENROAD_VERSION}.deb
	sudo apt install -y ./openroad_2.0_amd64-ubuntu22.04-${OPENROAD_VERSION}.deb
	wget https://www.klayout.org/downloads/Ubuntu-22/klayout_${KLAYOUT_VERSION}-1_amd64.deb
	sudo apt install -y ./klayout_${KLAYOUT_VERSION}-1_amd64.deb
	rm ./*.deb
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
	cd modules
	git clone git@github.com:SteffenReith/IHP-Open-DesignLib.git
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
if ! test -d "zephyr-sdk-${ZEPHYR_SDK_RELEASE}"; then
	fetch_zephyr_sdk
fi
if ! test -d "oss-cad-suite"; then
	fetch_oss_cad_suite_build
fi
if ! test -d "pdks"; then
	install_pdk
fi
if ! test -d "tools/OpenROAD-flow-scripts"; then
	install_openroad
	fetch_elemrv
fi
if ! test -d "tools/gdsiistl"; then
	install_gdsiistl
fi
if ! test -d "modules/IHP-Open-DesignLib"; then
	clone_release_repro
fi

