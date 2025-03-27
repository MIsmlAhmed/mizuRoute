#!/bin/bash

echo "Step 1: build ParallelIO from GitHub repo locally"

if [ -d libraries ]; then
    rm -rf libraries
fi

mkdir -p libraries

cd libraries
#create a direcrory anywhere you want
# clone the repo
echo "Clone ParallelIO repo"

git clone https://github.com/NCAR/ParallelIO.git
# cd to ParallelIO
cd ParallelIO
# clone another fortran lib
git clone https://github.com/PARALLELIO/genf90.git bin
# cd to the new repo 'bin'
cd bin
# clone another library
git clone https://github.com/CESM-Development/CMake_Fortran_utils.git cmake
cd ../..
mkdir pio-build
cd pio-build
mkdir piolib



#Ubuntu (added DNetCDF_C_INCLUDE_DIR and DNetCDF_C_LIBRARY) to explicility mention netcdf c
# Detect platform for the extension of the shared libraries
if [[ $(uname) == "Darwin" ]]; then
  #MACOS
cmake ../ParallelIO \
  -DPIO_ENABLE_FORTRAN=ON \
  -DPIO_ENABLE_TIMING=ON \
  -DCMAKE_C_COMPILER=mpicc \
  -DCMAKE_Fortran_COMPILER=mpifort \
  -DCMAKE_CXX_COMPILER=mpicxx \
  -DCMAKE_INSTALL_PREFIX=./piolib
else
  # Linux machine
  cmake ../ParallelIO \
  -DPIO_ENABLE_FORTRAN=ON \
  -DPIO_ENABLE_TIMING=ON \
  -DNetCDF_C_INCLUDE_DIR=$(nc-config --includedir) \
  -DNetCDF_C_LIBRARY=$(nc-config --libdir)/libnetcdf.so \
  -DPnetCDF_C_INCLUDE_DIR=$(pnetcdf-config --includedir) \
  -DPnetCDF_C_LIBRARY=$(pnetcdf-config --libdir)/libpnetcdf.so \
  -DCMAKE_C_COMPILER=mpicc \
  -DCMAKE_Fortran_COMPILER=mpifort \
  -DCMAKE_CXX_COMPILER=mpicxx \
  -DCMAKE_INSTALL_PREFIX=./piolib
fi



# build
make -j4
make install

###############

echo "Step 2: compile mizuRoute"

cd ../../route/build

make clean

make

echo "If you enconter erros compiling mizuRoute, most likely it comes from the ParallelIO build. Check it individually"