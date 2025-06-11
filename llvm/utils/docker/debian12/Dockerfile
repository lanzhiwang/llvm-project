#===- llvm/utils/docker/debian12/build/Dockerfile -------------------------===//
#
# Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
#
#===----------------------------------------------------------------------===//
# Stage 1. Check out LLVM source code and run the build.
FROM launcher.gcr.io/google/debian12:latest AS builder
# [builder ] FROM launcher.gcr.io/google/debian12:latest@sha256:12e5f5b44ddf1814696b7814c4d3a180a58b34cdcbde554b57150468f3023c61

LABEL maintainer="LLVM Developers"

# Install build dependencies of llvm.
# First, Update the apt's source list and include the sources of the packages.
RUN grep deb /etc/apt/sources.list | \
    sed 's/^deb/deb-src /g' >> /etc/apt/sources.list
# [builder ] RUN grep deb /etc/apt/sources.list | sed 's/^deb/deb-src /g' >> /etc/apt/sources.list

# Install compiler, python and subversion.
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates gnupg \
           build-essential cmake make python3 zlib1g wget subversion unzip git tree && \
    rm -rf /var/lib/apt/lists/*
# [builder ] RUN
# apt-get update &&
# apt-get install -y --no-install-recommends ca-certificates gnupg build-essential cmake make python3 zlib1g wget subversion unzip git tree &&
# rm -rf /var/lib/apt/lists/*

# Install a newer ninja release. It seems the older version in the debian repos
# randomly crashes when compiling llvm.
RUN wget "https://github.com/ninja-build/ninja/releases/download/v1.12.1/ninja-linux.zip" && \
    echo "6f98805688d19672bd699fbbfa2c2cf0fc054ac3df1f0e6a47664d963d530255 ninja-linux.zip" \
        | sha256sum -c  && \
    unzip ninja-linux.zip -d /usr/local/bin && \
    rm ninja-linux.zip
# [builder ] RUN
# wget "https://github.com/ninja-build/ninja/releases/download/v1.12.1/ninja-linux.zip" &&
# echo "6f98805688d19672bd699fbbfa2c2cf0fc054ac3df1f0e6a47664d963d530255 ninja-linux.zip" | sha256sum -c  &&
# unzip ninja-linux.zip -d /usr/local/bin &&
# rm ninja-linux.zip

# ADD checksums /tmp/checksums
# [builder ] ADD checksums /tmp/checksums
ADD scripts /tmp/scripts
# [builder ] ADD scripts /tmp/scripts

# Checkout the source code.
ARG checkout_args
RUN /tmp/scripts/checkout.sh ${checkout_args}
# [builder ] RUN /tmp/scripts/checkout.sh

# Run the build. Results of the build will be available at /tmp/clang-install/.
ARG buildscript_args
RUN /tmp/scripts/build_install_llvm.sh --to /tmp/clang-install ${buildscript_args}
# [builder ] RUN /tmp/scripts/build_install_llvm.sh --to /tmp/clang-install -i stage2-install-clang -i stage2-install-clang-resource-headers -- -DLLVM_TARGETS_TO_BUILD=Native -DCMAKE_BUILD_TYPE=Release -DBOOTSTRAP_CMAKE_BUILD_TYPE=Release -DCLANG_ENABLE_BOOTSTRAP=ON -DCLANG_BOOTSTRAP_TARGETS=install-clang;install-clang-resource-headers -DLLVM_ENABLE_PROJECTS=clang

RUN tree -a /tmp/clang-install
# RUN tree -a /tmp/clang-install
# /tmp/clang-install
# |-- bin
# |   |-- clang -> clang-21
# |   |-- clang++ -> clang
# |   |-- clang-21
# |   |-- clang-cl -> clang
# |   `-- clang-cpp -> clang
# `-- lib
# `-- clang
# `-- 21
# `-- include
# |-- __clang_cuda_builtin_vars.h
# |-- __clang_cuda_cmath.h
# |-- __clang_cuda_complex_builtins.h
# ...
# |-- adcintrin.h
# ...


# Stage 2. Produce a minimal release image with build results.
FROM launcher.gcr.io/google/debian12:latest

LABEL maintainer="LLVM Developers"

# Install packages for minimal useful image.
RUN apt-get update && \
    apt-get install -y --no-install-recommends binutils && \
    rm -rf /var/lib/apt/lists/*
# [stage-1 ] RUN
# apt-get update &&
# apt-get install -y --no-install-recommends binutils &&
# rm -rf /var/lib/apt/lists/*

# Copy build results of stage 1 to /usr/local.
COPY --from=builder /tmp/clang-install/ /usr/local/
# [stage-1 ] COPY --from=builder /tmp/clang-install/ /usr/local/
