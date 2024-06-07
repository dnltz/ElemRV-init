ElemRV
======

Fully Open Source RISC-V Microcontroller written in SpinalHDL. The chip layout was done with the IHP SG13G2 PDK and the open RTL-to-GDSII tool OpenROAD.

Installation
############

ElemRV-init comes with a container image which has all required host dependencies installed. Therefore, only the sources have to be locally installed and you keep your host system clean.

- Install podman::

	sudo apt install podman
	pip3 install podman-compose --user

- Build a container::

        podman-compose build

- Download all sources::

	chmod +x init.sh
	./init.sh

Container
#########

Start the ElemRV container in the background with following command:

.. code-block:: text

    podman-compose up -d

ASIC Flow
#########

First, create a layout from the Verilog file.

.. code-block:: text

    podman exec --workdir=$PWD -it elemenrv_container bash -c 'make sg13g2-synthesize'

Please check Known Issues in case the chip layout failed.

Next, open the chip layout and inspect the layout.

.. code-block:: text

    podman exec --workdir=$PWD -it elemenrv_container bash -c 'make sg13g2-klayout'

Alternatively, run Design Rule Checks to verify the chip is good.

.. code-block:: text

    podman exec --workdir=$PWD -it elemenrv_container bash -c 'make sg13g2-drc'

Use the `make sg13g2-drc-gui` target to show all DRC issues.

Known Issues
############

podman-compose is unable to find a container called 'elemrv-init_elemenrv_1'. The `containernetworking-plugins` is too old on some Ubuntu version. Update it manually to a newer version::

    curl -O http://archive.ubuntu.com/ubuntu/pool/universe/g/golang-github-containernetworking-plugins/containernetworking-plugins_1.1.1+ds1-3build1_amd64.deb
    dpkg -i containernetworking-plugins_1.1.1+ds1-3build1_amd64.deb

License
#######

Copyright (c) 2024 Steffen Reith and Daniel Schultz. Released under the `Apache License`_.

.. _Apache License: LICENSE

