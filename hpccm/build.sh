#!/bin/bash
#usage :
# cuda_version="10.0" ubuntu_version="18.04" mpi="mvapich2" mpi_version="2.3" tag="bigdft" ./build.sh

set -e
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

cd "$parent_path"

source ../current_setup.sh

: ${cuda_version:=$BIGDFT_CUDA_VERSION}
: ${ubuntu_version=$BIGDFT_UBUNTU_VERSION}
: ${mpi="ompi"}
: ${mpi_version=$BIGDFT_MVAPICH2_VERSION}
if [ $mpi = "ompi" ]; then
: ${mpi_version=$BIGDFT_OPENMPI_VERSION}
fi
: ${tag="bigdft"}

suffix=ubuntu${ubuntu_version}_cuda${cuda_version}_${mpi}${mpi_version}_${tag}

hpccm --recipe hpccm_lsim-mpi.py --userarg cuda=${cuda_version} ubuntu=${ubuntu_version} mpi=${mpi} mpi_version=${mpi_version} > Dockerfile_sdk_${suffix}
docker build --tag ${tag}/sdk:${suffix} --tag ${tag}/sdk:latest --target sdk - < ./Dockerfile_sdk_${suffix}
docker build --tag ${tag}/sdk_mpi:${suffix} --tag ${tag}/sdk_mpi:latest - < ./Dockerfile_sdk_${suffix}

hpccm --recipe hpccm_lsim-vsim.py --userarg cuda=${cuda_version} ubuntu=${ubuntu_version} mpi=${mpi} mpi_version=${mpi_version} tag=${tag}/sdk:latest > ./Dockerfile_vsim_${suffix}
docker build --tag ${tag}/v_sim:${suffix} --tag ${tag}/v_sim:latest - < ./Dockerfile_vsim_${suffix}

hpccm --recipe hpccm_lsim-bigdft.py --userarg cuda=${cuda_version} ubuntu=${ubuntu_version} mpi=${mpi} mpi_version=${mpi_version} tag=${tag}/sdk:latest > ./Dockerfile_bigdft_${suffix}
docker build --tag ${tag}/runtime:${suffix} --tag ${tag}/runtime:latest - < ./Dockerfile_bigdft_${suffix}


