#!/bin/bash

#------------------------------------
echo "Step 0: check that the needed libraries are available on the current system"
# a function to check the installation
check_config() {
  local cmd="$1"
  local name="$2"

  if ! command -v "$cmd" &>/dev/null; then
    echo "❌ Error: $cmd not found. Please install $name."
    exit 1
  fi

  local prefix=$($cmd --prefix 2>/dev/null)
  if [ -z "$prefix" ]; then
    echo "❌ Error: $cmd --prefix returned nothing. Check $name installation."
    exit 1
  fi

  local libdir=$($cmd --libdir 2>/dev/null)
  if [ -z "$libdir" ]; then
    echo "❌ Error: $cmd --libdir returned nothing. Check $name installation."
    exit 1
  fi

  local includedir=$($cmd --includedir 2>/dev/null)
  if [ -z "$libdir" ]; then
    echo "❌ Error: $cmd --includedir returned nothing. Check $name installation."
    exit 1
  fi

  echo "✅ $name found at: $prefix"
}

check_config nf-config "NetCDF-Fortran"
check_config nc-config "NetCDF-C"
check_config pnetcdf-config "PnetCDF"

# Check MPI compilers
for compiler in mpifort mpicc mpicxx; do
  if ! command -v $compiler &>/dev/null; then
    echo "❌ Error: $compiler not found. Please ensure MPI is installed and loaded."
    exit 1
  else
    echo "✅ Found $compiler: $($compiler --version | head -n 1)"
  fi
done

#------------------------------------

echo "Step 1: build ParallelIO from GitHub repo locally"

cd route/build/lib

# remove previous builds of libraries
if [ -d pio-build ]; then
    rm -rf pio-build
fi
if [ -d piolib ]; then
    rm -rf piolib
fi
if [ -d ParallelIO ]; then
    rm -rf ParallelIO
fi


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
mkdir piolib

cd pio-build

# set the environment variables for the compilers
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
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DCMAKE_INSTALL_PREFIX=../piolib
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
  -DCMAKE_INSTALL_PREFIX=../piolib
fi



# build
make -j4
make install

###############

echo "Step 2: compile mizuRoute"

cd ../..

make clean

make

echo "If you enconter erros compiling mizuRoute, most likely it comes from the ParallelIO build. Check it individually"