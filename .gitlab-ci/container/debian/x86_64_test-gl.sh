#!/usr/bin/env bash
# shellcheck disable=SC2086 # we want word splitting

set -e
set -o xtrace

export DEBIAN_FRONTEND=noninteractive

export LLVM_VERSION="${LLVM_VERSION:=15}"

apt-get install -y libelogind0  # this interfere with systemd deps, install separately


# Ephemeral packages (installed for this script and removed again at the end)
STABLE_EPHEMERAL=" \
      bzip2 \
      ccache \

      clang-13 \
      clang-11 \

      clang-${LLVM_VERSION} \

      cmake \
      g++ \
      glslang-tools \
      libasound2-dev \
      libcap-dev \

      libclang-cpp13-dev \
      libclang-cpp11-dev \

      libclang-cpp${LLVM_VERSION}-dev \
      libdrm-dev \

      libgles2-mesa-dev \
      libpciaccess-dev \
      libpng-dev \
      libudev-dev \
      libvulkan-dev \
      libwaffle-dev \
      libwayland-dev \
      libx11-xcb-dev \
      libxcb-dri2-0-dev \
      libxkbcommon-dev \
      libxrandr-dev \
      libxrender-dev \

      llvm-13-dev \
      llvm-11-dev \

      llvm-${LLVM_VERSION}-dev \

      make \
      meson \
      ocl-icd-opencl-dev \
      patch \

      pkg-config \

      pkgconf \

      python3-distutils \
      xz-utils \
      "

apt-get update

apt-get install -y --no-remove \
      $EXTRA_LOCAL_PACKAGES \
      $STABLE_EPHEMERAL \
      clinfo \
      iptables \

      libclang-common-13-dev \
      libclang-common-11-dev \
      libclang-cpp13 \
      libclang-cpp11 \

      libclang-common-${LLVM_VERSION}-dev \
      libclang-cpp${LLVM_VERSION} \

      libcap2 \
      libegl1 \
      libepoxy0 \
      libfdt1 \
      libxcb-shm0 \
      ocl-icd-libopencl1 \
      python3-lxml \
      python3-renderdoc \
      python3-simplejson \
      spirv-tools \

      sysvinit-core \

      weston


. .gitlab-ci/container/container_pre_build.sh

############### Build piglit

PIGLIT_OPTS="-DPIGLIT_BUILD_GLX_TESTS=ON -DPIGLIT_BUILD_CL_TESTS=ON -DPIGLIT_BUILD_DMA_BUF_TESTS=ON" . .gitlab-ci/container/build-piglit.sh

############### Build dEQP GL

DEQP_TARGET=surfaceless . .gitlab-ci/container/build-deqp.sh

############### Build apitrace

. .gitlab-ci/container/build-apitrace.sh

############### Build validation layer for zink

. .gitlab-ci/container/build-vulkan-validation.sh

############### Uninstall the build software

ccache --show-stats

apt-get purge -y \
      $STABLE_EPHEMERAL

apt-get autoremove -y --purge


# hack to remove Debian libdrm (until bookworm), deqp sometimes load old libdrm, we could remove here eventually Mesa too; execute on both GL and VK container
dpkg -r --force-depends "libdrm2" "libdrm-radeon1" "libdrm-nouveau2" "libdrm-intel1" "libdrm-amdgpu1" "libdrm-common"  # "mesa-vulkan-drivers" "mesa-vdpau-drivers" "mesa-va-drivers" "libgl1-mesa-dri" "libglx-mesa0" "vdpau-driver-all" "va-driver-all" "libglx0" "libgl1" "libvdpau-va-gl1" "libglu1-mesa" "libegl-mesa0" "libgl1-mesa-dri" "libglapi-mesa" "libosmesa6"

