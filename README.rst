ElemRV
======

Fully Open Source RISC-V Microcontroller written in SpinalHDL. The chip layout was done with the IHP SG13G2 PDK and the open RTL-to-GDSII tool OpenROAD.

Installation
############

ElemRV-init comes with a container image which has all required host dependencies installed. Therefore, only the sources have to be locally installed and you keep your host system clean.

- Install podman::

        sudo apt install podman

- Build the podman container::

        podman build -t elemrv:v1.0 .

        podman run \
            -v $XAUTHORITY:$XAUTHORITY:ro \
            -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
            -e "DISPLAY" \
            -v $PWD:/srv/elemrv \
            --workdir=/srv/elemrv \
            --detach \
            --name elemrv_container \
            -it elemrv:v1.0 \
            sleep infinity

- Download all sources::

        ./init.sh

Container
#########

This chapter is a quick introduction into container handling. After the installation, you should
have a container called `elemrv_container` running on your system.

.. code-block:: text

    $ podman ps
    CONTAINER ID  IMAGE                    COMMAND         CREATED        STATUS            PORTS       NAMES
    6a4bc5082aeb  localhost/elemrv:v1.0    sleep infinity  5 minutes ago  Up 5 minutes ago              elemrv_container

If it's not running, you can check if the container exists.

.. code-block:: text

    $ podman container ls -a
    CONTAINER ID  IMAGE                    COMMAND         CREATED        STATUS            PORTS       NAMES
    6a4bc5082aeb  localhost/elemrv:v1.0    sleep infinity  7 minutes ago  Up 7 minutes ago              elemrv_container

When you're finished and you want to stop the container, run the following command to stop the
ElemRV container.

.. code-block:: text

    podman stop elemrv_container

Obviously, before the next session, start the container again.

.. code-block:: text

    podman start elemrv_container

The next chapter guides through the ASIC flow. However, you can also go into the container and run
all make targets there.

.. code-block:: text

    podman exec -it elemenrv_container bash

ASIC Flow
#########

First, create a layout from the Verilog file.

.. code-block:: text

    podman exec -it elemenrv_container bash -c 'make sg13g2-synthesize'

Please check Known Issues in case the chip layout failed.

Next, open the chip yout and inspect it.

.. code-block:: text

    podman exec -it elemenrv_container bash -c 'make sg13g2-klayout'

Alternatively, run Design Rule Checks to verify the chip is good.

.. code-block:: text

    podman exec -it elemenrv_container bash -c 'make sg13g2-drc'

Use the `make sg13g2-drc-gui` target to show all DRC issues.

Known Issues
############

-

License
#######

Copyright (c) 2024 Steffen Reith and Daniel Schultz. Released under the `Apache License`_.

.. _Apache License: LICENSE

