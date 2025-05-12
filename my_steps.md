# Steps to compile mizuRoute

# MacOS

This assumes you have a mac with apple silicon chip (M series) and homebrew installed

- install the following using homebrew:
    ```
    brew install cmake
    brew install gcc
    brew install gfortran
    brew install open-mpi
    brew install netcdf
    brew install netcdf-fortran
    brew install pnetcdf
    ```

- Run `install_mizuRoute.sh` to install the needed dependencies (i.e., `ParallelIO` with `GPTL` support) and compile `mizuRoute.exe`.
____________________

# compiling on an Ubuntu machine:

- Make sure you have the following libraries installed
    ```
    sudo apt install cmake
    sudo apt install gcc
    sudo apt install gfortran
    sudo apt install build-essential
    sudo apt install libopenmpi-dev openmpi-bin
    sudo apt install libnetcdf-dev libnetcdff-dev netcdf-bin
    sudo apt install libpnetcdf-dev pnetcdf-bin
    ```
- Run `install_mizuRoute.sh` to install the needed dependencies (i.e., `ParallelIO` with `GPTL` support) and compile `mizuRoute.exe`.
____________________

# compiling on ARC

- Load the `2024v5` module stack:
    ```
    . /work/comphyd_lab/local/modules/spack/2024v5/lmod-init-bash
    module unuse $MODULEPATH
    module use /work/comphyd_lab/local/modules/spack/2024v5/modules/linux-rocky8-x86_64/Core/
    ```

- compile mizuRoute:

    - Building from scratch:
    mizuRoute can be compiled by building ParallelIO from scratch (similar to the above).
        - load the following modules
            ```
            module load openmpi netcdf-fortran netcdf-c parallel-netcdf cmake
            ```
            Note: `openmpi` needs to be loaded first to be able to load `parallel-netcdf` successfully.
        - run the `install_mizuRoute.sh` file.
    - Use pre-built ParallelIO on the `2024v5` module stack:
        - load the needed modules:
            ```
            module load openmpi/4.1.6 parallelio-mpi/2.6.2
            ```
        - Change the following in the makefile
            ```
            PIO_PATH = $(PARALLELIO_ROOT)
            ```

