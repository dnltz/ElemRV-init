#!/bin/bash

INSTALL_PATH=/opt/elements/
PATH=${INSTALL_PATH}/oss-cad-suite/bin/:$PATH
OSS_CAD_SUITE_DATE="2024-04-16"
OSS_CAD_SUITE_STAMP="${OSS_CAD_SUITE_DATE//-}"

OPENROAD_VERSION=2024-05-15
OPENROAD_FLOW_ORGA=dnltz
OPENROAD_FLOW_VERSION=53a9b78f1f8e851c45d5e3cfa90e3bd854ca0cd7
KLAYOUT_VERSION=0.29.0
ZEPHYR_SDK_RELEASE=0.16.5
IHP_PDK_VERSION=5a42d03194e8c98558f4e34538338a60550f89b9

function fetch_oss_cad_suite_build {
	mkdir -p ${INSTALL_PATH}
	cd ${INSTALL_PATH}
	wget https://github.com/YosysHQ/oss-cad-suite-build/releases/download/${OSS_CAD_SUITE_DATE}/oss-cad-suite-linux-x64-${OSS_CAD_SUITE_STAMP}.tgz
	tar -xvf oss-cad-suite-linux-x64-${OSS_CAD_SUITE_STAMP}.tgz
	rm oss-cad-suite-linux-x64-${OSS_CAD_SUITE_STAMP}.tgz
}

function fetch_zephyr_sdk {
	mkdir -p ${INSTALL_PATH}
	cd ${INSTALL_PATH}
	wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_SDK_RELEASE}/zephyr-sdk-${ZEPHYR_SDK_RELEASE}_linux-x86_64.tar.xz
	wget -O - https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_SDK_RELEASE}/sha256.sum | shasum --check --ignore-missing
	tar xvf zephyr-sdk-${ZEPHYR_SDK_RELEASE}_linux-x86_64.tar.xz
	rm zephyr-sdk-${ZEPHYR_SDK_RELEASE}_linux-x86_64.tar.xz
}

function install_pdk {
	mkdir -p ${INSTALL_PATH}
	cd ${INSTALL_PATH}
	mkdir -p pdks
	cd pdks/
	git clone https://github.com/IHP-GmbH/IHP-Open-PDK.git
	cd IHP-Open-PDK
	git checkout ${IHP_PDK_VERSION}
	cd ../../
}

function install_openroad_deps {
	mkdir -p ${INSTALL_PATH}
	cd ${INSTALL_PATH}
	mkdir -p tools
	cd tools
	sudo add-apt-repository -y ppa:deadsnakes/ppa
	sudo apt-get update
	sudo apt-get install -y python3.9 python3.9-dev python3-pip libpython3.9
	wget https://github.com/Precision-Innovations/OpenROAD/releases/download/${OPENROAD_VERSION}/openroad_2.0_amd64-ubuntu20.04-${OPENROAD_VERSION}.deb
	sudo apt install -y ./openroad_2.0_amd64-ubuntu20.04-${OPENROAD_VERSION}.deb
	wget https://www.klayout.org/downloads/Ubuntu-22/klayout_${KLAYOUT_VERSION}-1_amd64.deb
	sudo apt install -y ./klayout_${KLAYOUT_VERSION}-1_amd64.deb
	rm ./*.deb
	cd ../
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

if ! test -d "zephyr-sdk-${ZEPHYR_SDK_RELEASE}"; then
	fetch_zephyr_sdk
fi
if ! test -d "oss-cad-suite"; then
	fetch_oss_cad_suite_build
fi
if ! test -d "pdks"; then
	install_pdk
fi
if ! test -d "tools"; then
	install_openroad_deps
fi
