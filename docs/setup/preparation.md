# Preparation

Go to the directory where you've checked out the project.

## Prepare data structure

Before Docker Compose can be used, you must create directories to mount SSH key pairs
for user authentication to [OCR-D Controller](https://github.com/bertsky/ocrd_controller)
and [OCR-D Manager](https://github.com/markusweigelt/ocrd_manager).

Moreover, for testing we need example data (e.g. users, authorities, workflows etc.) set up in the database of Kitodo.Production.

 Finally, you need to install some OCR models in the Controller with OCR-D Resource Manager.


The fastest way to get all that is by using the Makefile via the following command:

    make prepare

> Note: This may not meet your exact scenario. To customize, have a look at the [rules](./Makefile#L21-L64),
> or simulate running them via `make -n prepare`, or modify the results afterwards.
> (For example, if you have set up the [OCR-D Controller](https://github.com/bertsky/ocrd_controller) _externally_,
> you will have to manually append to its `authorized_keys` the file generated under `./ocrd/manager/.ssh/id_rsa.pub`,
> or copy the existing private key into `./ocrd/manager/.ssh/id_rsa`.)

Alternatively, perform the following steps manually:

- Create directories to host SSH key pair files:

        mkdir ./kitodo/.ssh/
        mkdir ./ocrd/manager/.ssh/
        mkdir ./ocrd/controller/.ssh/

- Generate SSH key pairs in `./kitodo/.ssh/` and `./ocrd/manager/.ssh/`. 
- After that, register the public keys on the other side, respectively:

        mv ./kitodo/.ssh/id_rsa.pub ./ocrd/manager/authorized_keys
        mv ./ocrd/manager/id_rsa.pub ./ocrd/controller/authorized_keys

- Unzip `./_resources/data.zip` to `./_resources/data` to provide the examples and Kitodo.Production configuration files.

- Follow the instructions in [the next section](#install-models-on-the-ocr-d-controller) to install OCR models on the OCR-D Controller.

## Install models on the OCR-D Controller

For practical workflows, you first have to install models for various processors on the OCR-D Controller.
Since all processor resources are mounted under the `CONTROLLER_MODELS` volume, resources will persist
and thus only have to be installed once.

Installation could be done by downloading the respective files into the filesystem (see `make prepare`),
or dynamically:

1. Start interactive shell on the Controller.

        docker exec -it kitodo_production_ocrd_ocrd-controller_1 bash
        su - ocrd

2. Use the OCR-D Resource Manager to query and install models:

        wget -O frak2021.traineddata https://ub-backup.bib.uni-mannheim.de/~stweil/tesstrain/frak2021/tessdata_best/frak2021-0.905.traineddata
        ocrd resmgr download -n ocrd-tesserocr-recognize frak2021.traineddata
        ocrd resmgr download ocrd-eynollah-segment default
        ocrd resmgr list-installed
        ocrd resmgr list-available
        ocrd resmgr --help

## Building Docker images

Unless you want to run with prebuilt images from Dockerhub
(in which case make sure you have [configured](#configuration)
the right version tags in your `.env`), you first need to
build Docker images for all modules.

For the [Kitodo.Production application](https://github.com/markusweigelt/kitodo-production-docker/tree/main/kitodo),
prior to building the app container itself, one needs to compile the app from source
(the result of which will be provided in the submodule `kitodo-production-docker` under folder `build-resources`).
From there, all runtime module images can be built:

    make build

(or equivalently:)

    docker-compose -f ./docker-compose.kitodo-builder.yml up --abort-on-container-exit --build
    docker-compose -f ./docker-compose.kitodo-builder.yml down
    docker-compose build