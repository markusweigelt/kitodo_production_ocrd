# Prerequisites

## Docker

1. [Install Docker Engine](https://docs.docker.com/get-docker/)
2. [Install Docker Compose](https://docs.docker.com/compose/install/)
3. [Install Nvidia Container Runtime](https://github.com/NVIDIA/nvidia-container-runtime) (needed for Controller – even if no GPU is available)

## Git

Either clone recursively in the first place:

    git clone --recurse-submodules https://github.com/markusweigelt/kitodo_production_ocrd
    cd kitodo_production_ocrd

Or, after cloning and entering the repository normally, clone all submodules:

    git submodule update --init --recursive