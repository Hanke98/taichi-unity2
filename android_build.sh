#!/bin/sh
set -e

# build taichi_c_api lib
if [[ -z "${TAICHI_REPO_DIR}" ]]; then
    echo "Please set TAICHI_REPO_DIR env variable"
    exit
else
    echo "TAICHI_REPO_DIR is set to ${TAICHI_REPO_DIR}"
fi

if [[ -z "${ANDROID_NDK_ROOT}" ]]; then
    echo "Please set ANDROID_NDK_ROOT env variable"
    exit
else
    echo "ANDROID_NDK_ROOT is set to ${ANDROID_NDK_ROOT}"
fi

build_dir="build-taichi-android-aarch64"
if [ ! -d "$build_dir" ]; then 
mkdir $build_dir
fi

CLANG_EXECUTABLE=$(find $ANDROID_NDK_ROOT -name "clang++")

pushd $build_dir
cmake $TAICHI_REPO_DIR \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="./install" \
    -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake" \
    -DCLANG_EXECUTABLE=$CLANG_EXECUTABLE \
    -DANDROID_ABI="arm64-v8a" \
    -DANDROID_PLATFORM=android-26 \
    -G "Ninja" \
    -DTI_WITH_CC=OFF \
    -DTI_WITH_CUDA=OFF \
    -DTI_WITH_CUDA_TOOLKIT=OFF \
    -DTI_WITH_C_API=ON \
    -DTI_WITH_DX11=OFF \
    -DTI_WITH_LLVM=OFF \
    -DTI_WITH_METAL=OFF \
    -DTI_WITH_OPENGL=OFF \
    -DTI_WITH_PYTHON=OFF \
    -DTI_WITH_VULKAN=ON

cmake --build . -t taichi_c_api
cmake --build . -t install
popd

# build taichi_unity lib
unity_build_dir="build-taichi-unity"
if [ ! -d "$unity_build_dir" ]; then 
mkdir $unity_build_dir
fi

pushd $unity_build_dir
cmake -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI="arm64-v8a" \
    -DANDROID_PLATFORM=android-26 \
    -G "Ninja" \
    -DTAICHI_C_API_INSTALL_DIR="../build-taichi-android-aarch64/install/c_api" \
    ..
cmake --build . -t taichi_unity
popd