# A guide to Dockerfiles for building LLVM
构建 LLVM 的 Dockerfile 指南

* https://llvm.org/docs/Docker.html

## Introduction
介绍

You can find a number of sources to build docker images with LLVM components in `llvm/utils/docker`. They can be used by anyone who wants to build the docker images for their own use, or as a starting point for someone who wants to write their own Dockerfiles.
您可以在以下位置找到许多使用 LLVM 组件构建 docker 镜像的来源 `llvm/utils/docker`. 任何想要构建 Docker 镜像供自己使用的人都可以使用它们, 或者作为想要编写自己的 Dockerfile 的人的起点.

We currently provide Dockerfiles with `debian12` and `nvidia-cuda` base images. We also provide an `example` image, which contains placeholders that one would need to fill out in order to produce Dockerfiles for a new docker image.
我们目前提供基于 `debian12` 和 `nvidia-cuda` 基础镜像的 Dockerfile. 我们还提供了一个 `example` 镜像, 其中包含一些占位符, 用户需要填写这些占位符才能为新的 Docker 镜像生成 Dockerfile.

### Why?
为什么?

Docker images provide a way to produce binary distributions of software inside a controlled environment. Having Dockerfiles to builds docker images inside LLVM repo makes them much more discoverable than putting them into any other place.
Docker 镜像提供了一种在受控环境中生成软件二进制发行版的方法. 使用 Dockerfile 在 LLVM 仓库中构建 Docker 镜像, 比将它们放在其他任何地方都更容易被发现.

### Docker basics
Docker 基础知识

If you've never heard about Docker before, you might find this section helpful to get a very basic explanation of it. [Docker](https://www.docker.com/) is a popular solution for running programs in an isolated and reproducible environment, especially to maintain releases for software deployed to large distributed fleets. It uses linux kernel namespaces and cgroups to provide a lightweight isolation inside currently running linux kernel. A single active instance of dockerized environment is called a *docker container*. A snapshot of a docker container filesystem is called a *docker image*. One can start a container from a prebuilt docker image.
如果你以前从未听说过 Docker, 你可能会发现本节很有帮助来获得一个非常基本的解释.  [Docker](https://www.docker.com/) 是一种流行的解决方案, 用于在隔离且可复制的环境中运行程序, 尤其适用于维护部署到大型分布式集群的软件版本. 它使用 Linux 内核命名空间和 cgroup 在当前运行的 Linux 内核中提供轻量级隔离. Docker 化环境的单个活动实例称为 *Docker 容器* . Docker 容器文件系统的快照称为 *Docker 镜像*. 可以从预构建的 Docker 镜像启动容器.

Docker images are built from a so-called *Dockerfile*, a source file written in a specialized language that defines instructions to be used when build the docker image (see [official documentation](https://docs.docker.com/engine/reference/builder/) for more details). A minimal Dockerfile typically contains a base image and a number of RUN commands that have to be executed to build the image. When building a new image, docker will first download your base image, mount its filesystem as read-only and then add a writable overlay on top of it to keep track of all filesystem modifications, performed while building your image. When the build process is finished, a diff between your image's final filesystem state and the base image's filesystem is stored in the resulting image.
Docker 镜像是从所谓的 *Dockerfile* 构建的, Dockerfile 是一个用专门语言编写的源文件, 它定义了构建 docker 镜像时要使用的指令(有关更多详细信息, 请参阅[官方文档](https://docs.docker.com/engine/reference/builder/)). 最小 Dockerfile 通常包含一个基本镜像和一些构建镜像必须执行的 RUN 命令. 构建新镜像时, docker 将首先下载基本镜像, 将其文件系统挂载为只读, 然后在其上添加可写的覆盖层, 以跟踪构建镜像时执行的所有文件系统修改. 构建过程完成后, 镜像的最终文件系统状态和基本镜像的文件系统之间的差异将存储在生成的镜像中.

## Overview
概述

The `llvm/utils/docker` folder contains Dockerfiles and simple bash scripts to serve as a basis for anyone who wants to create their own Docker image with LLVM components, compiled from sources. The sources are checked out from the upstream git repository when building the image.
`llvm/utils/docker` 文件夹包含 Dockerfile 和简单的 bash 脚本, 可供任何想要使用 LLVM 组件(从源代码编译)创建自己的 Docker 镜像的用户作为基础. 构建镜像时, 会从上游 git 仓库中检出源代码.

The resulting image contains only the requested LLVM components and a few extra packages to make the image minimally useful for C++ development, e.g. libstdc++ and binutils.
生成的图像仅包含所请求的 LLVM 组件和一些额外的包, 以使图像对于 C++ 开发有最低限度的用处, 例如 libstdc++ 和 binutils.

The interface to run the build is `build_docker_image.sh` script. It accepts a list of LLVM repositories to checkout and arguments for CMake invocation.
运行构建的接口是 `build_docker_image.sh` 脚本. 它接受要检出的 LLVM 存储库列表以及 CMake 调用的参数.

If you want to write your own docker image, start with an `example/` subfolder. It provides an incomplete Dockerfile with (very few) FIXMEs explaining the steps you need to take in order to make your Dockerfiles functional.
如果您想编写自己的 Docker 镜像, 请从 `example/` 子文件夹开始. 它提供了一个不完整的 Dockerfile, 其中包含(极少的)FIXME 文件, 解释了使 Dockerfile 正常运行所需的步骤.

## Usage
用法

The `llvm/utils/build_docker_image.sh` script provides a rather high degree of control on how to run the build. It allows you to specify the projects to checkout from git and provide a list of CMake arguments to use during when building LLVM inside docker container.
`llvm/utils/build_docker_image.sh` 脚本对如何运行构建提供了相当高程度的控制. 它允许您指定要从 Git 签出的项目, 并提供在 Docker 容器内构建 LLVM 时要使用的 CMake 参数列表.

Here's a very simple example of getting a docker image with clang binary, compiled by the system compiler in the debian12 image:
这是一个非常简单的示例, 获取带有 clang 二进制文件的 docker 镜像, 由 debian12 镜像中的系统编译器编译:

```bash
./llvm/utils/docker/build_docker_image.sh \
 --source debian12 \
 --docker-repository clang-debian12 --docker-tag "staging" \
 -p clang -i install-clang -i install-clang-resource-headers \
 -- \
 -DCMAKE_BUILD_TYPE=Release
```

Note that a build like that doesn't use a 2-stage build process that you probably want for clang. Running a 2-stage build is a little more intricate, this command will do that:
请注意, 这样的构建不会使用你可能想要的 clang 的两阶段构建过程. 运行两阶段构建稍微复杂一些, 以下命令可以做到这一点:

# Run a 2-stage build.

```bash
# LLVM_TARGETS_TO_BUILD=Native is to reduce stage1 compile time.
# Options, starting with BOOTSTRAP_* are passed to stage2 cmake invocation.
./build_docker_image.sh \
 --source debian12 \
 --docker-repository clang-debian12 --docker-tag "staging" \
 -p clang -i stage2-install-clang -i stage2-install-clang-resource-headers \
 -- \
 -DLLVM_TARGETS_TO_BUILD=Native -DCMAKE_BUILD_TYPE=Release \
 -DBOOTSTRAP_CMAKE_BUILD_TYPE=Release \
 -DCLANG_ENABLE_BOOTSTRAP=ON -DCLANG_BOOTSTRAP_TARGETS="install-clang;install-clang-resource-headers"
```

This will produce a new image `clang-debian12:staging` from the latest upstream revision. After the image is built you can run bash inside a container based on your image like this:
这将从最新的上游修订版本生成一个新的镜像 `clang-debian12:staging` . 镜像构建完成后, 您可以在基于该镜像的容器内运行 bash, 如下所示:

```bash
docker run -ti clang-debian12:staging bash
```

Now you can run bash commands as you normally would:
现在您可以像平常一样运行 bash 命令:

```bash
root@80f351b51825:/# clang -v
clang version 19.1.7 (trunk 524462)
Target: x86_64-unknown-linux-gnu
Target: x86_64-unknown-linux-gnu
Thread model: posix
InstalledDir: /bin
```

## Which image should I choose?
我应该选择哪张图片?

We currently provide two images: Debian12-based and nvidia-cuda-based. They differ in the base image that they use, i.e. they have a different set of preinstalled binaries. Debian8 is very minimal, nvidia-cuda is larger, but has preinstalled CUDA libraries and allows to access a GPU, installed on your machine.
我们目前提供两种镜像:基于 Debian 12 和基于 nvidia-cuda. 它们的区别在于所使用的基础镜像, 即预装的二进制文件不同. Debian 8 非常精简, 而 nvidia-cuda 较大, 但预装了 CUDA 库, 并允许访问您机器上安装的 GPU.

If you need a minimal linux distribution with only clang and libstdc++ included, you should try Debian12-based image.
如果您需要仅包含 clang 和 libstdc++ 的最小 Linux 发行版, 您应该尝试基于 Debian12 的图像.

If you want to use CUDA libraries and have access to a GPU on your machine, you should choose nvidia-cuda-based image and use [nvidia-docker](https://github.com/NVIDIA/nvidia-docker) to run your docker containers. Note that you don't need nvidia-docker to build the images, but you need it in order to have an access to GPU from a docker container that is running the built image.
如果您想使用 CUDA 库并访问计算机上的 GPU, 则应选择基于 nvidia-cuda 的镜像, 并使用 [nvidia-docker](https://github.com/NVIDIA/nvidia-docker) 运行 docker 容器. 请注意, 您不需要 nvidia-docker 来构建镜像, 但您需要它才能从运行构建镜像的 docker 容器访问 GPU.

If you have a different use-case, you could create your own image based on `example/` folder.
如果你有不同的用例, 你可以根据以下情况创建自己的图像 `example/` 文件夹.

Any docker image can be built and run using only the docker binary, i.e. you can run debian12 build on Fedora or any other Linux distribution. You don't need to install CMake, compilers or any other clang dependencies. It is all handled during the build process inside Docker's isolated environment.
任何 docker 镜像都可以仅使用 docker 二进制文件构建和运行, 例如, 您可以在 Fedora 或任何其他 Linux 发行版上运行 debian12 构建. 您无需安装 CMake、编译器或任何其他 clang 依赖项. 所有这些都在 Docker 隔离环境的构建过程中处理.

## Stable build
稳定构建

If you want a somewhat recent and somewhat stable build, use the `branches/google/stable` branch, i.e. the following command will produce a Debian12-based image using the latest `google/stable` sources for you:
如果您想要一个较新且较稳定的版本, 请使用 `branches/google/stable` 分支, 即以下命令将使用最新的 `google/stable` 源为您生成基于 Debian12 的映像:

```bash
./llvm/utils/docker/build_docker_image.sh \
 -s debian12 --d clang-debian12 -t "staging" \
 --branch branches/google/stable \
 -p clang -i install-clang -i install-clang-resource-headers \
 -- \
 -DCMAKE_BUILD_TYPE=Release
```

## Minimizing docker image size
最小化 docker 镜像大小

Due to how Docker's filesystem works, all intermediate writes are persisted in the resulting image, even if they are removed in the following commands. To minimize the resulting image size we use [multi-stage Docker builds](https://docs.docker.com/develop/develop-images/multistage-build/). Internally Docker builds two images. The first image does all the work: installs build dependencies, checks out LLVM source code, compiles LLVM, etc. The first image is only used during build and does not have a descriptive name, i.e. it is only accessible via the hash value after the build is finished. The second image is our resulting image. It contains only the built binaries and not any build dependencies. It is also accessible via a descriptive name (specified by -d and -t flags).
由于 Docker 文件系统的工作方式, 所有中间写入都会保留在结果映像中, 即使在以下命令中删除它们也是如此. 为了最小化结果映像的大小, 我们使用[多阶段 Docker 构建](https://docs.docker.com/develop/develop-images/multistage-build/). Docker 内部构建两个映像. 第一个映像完成所有工作:安装构建依赖项、检出 LLVM 源代码、编译 LLVM 等. 第一个映像仅在构建期间使用, 并且没有描述性名称, 即, 只能在构建完成后通过哈希值访问它. 第二个映像是我们的结果映像. 它仅包含构建的二进制文件, 而不包含任何构建依赖项. 它也可以通过描述性名称访问(由 -d 和 -t 标志指定).


```bash
docker run -ti --rm \
-v ~/work/code/c_code/docker-library/llvm-project:/llvm-project \
-w /llvm-project \
ubuntu:22.04 bash

root@686ff079f7b0:/llvm-project# tree -a ./llvm/utils/docker/
./llvm/utils/docker/
|-- README
|-- build_docker_image.sh
|-- debian12
|   `-- Dockerfile
|-- example
|   `-- Dockerfile
|-- learn.md
|-- nvidia-cuda
|   `-- Dockerfile
`-- scripts
    |-- build_install_llvm.sh
    |-- checkout.sh
    `-- llvm_checksum
        |-- llvm_checksum.py
        `-- project_tree.py

5 directories, 10 files
root@686ff079f7b0:/llvm-project#

root@686ff079f7b0:/llvm-project# ./llvm/utils/docker/build_docker_image.sh -h
Usage: build_docker_image.sh [options] [-- [cmake_args]...]

Available options:
  General:
    -h|--help               show this help message
  Docker-specific:
    -s|--source             image source dir (i.e. debian12, nvidia-cuda, etc)
    -d|--docker-repository  docker repository for the image
    -t|--docker-tag         docker tag for the image
  Checkout arguments:
    -b|--branch         git branch to checkout, i.e. 'main',
                        'release/10.x'
                        (default: 'main')
    -r|--revision       git revision to checkout
    -c|--cherrypick     revision to cherry-pick. Can be specified multiple times.
                        Cherry-picks are performed in the sorted order using the
                        following command:
                        'git cherry-pick $rev'.
    -p|--llvm-project   Add the project to a list LLVM_ENABLE_PROJECTS, passed to
                        CMake.
                        Can be specified multiple times.
    --checksums         name of a file, containing checksums of llvm checkout.
                        Script will fail if checksums of the checkout do not
                        match.
  Build-specific:
    -i|--install-target name of a cmake install target to build and include in
                        the resulting archive. Can be specified multiple times.

Required options: --source and --docker-repository, at least one
  --install-target.

All options after '--' are passed to CMake invocation.

For example, running:

$ build_docker_image.sh \
-s debian12 \
-d mydocker/debian12-clang \
-t latest \
-p clang \
-i install-clang -i install-clang-resource-headers

will produce two docker images:
    mydocker/debian12-clang-build:latest - an intermediate image used to compile clang. 用于编译 clang 的中间映像.
    mydocker/clang-debian12:latest       - a small image with preinstalled clang.

Please note that this example produces a not very useful installation, since it
doesn't override CMake defaults, which produces a Debug and non-boostrapped
version of clang.
请注意, 此示例生成的安装不太实用, 因为它
没有覆盖 CMake 的默认设置, 而是生成了一个 Debug 且非 bootstrapped 版本的 clang.

To get a 2-stage clang build, you could use this command:

$ ./build_docker_image.sh \
-s debian12 \
-d mydocker/clang-debian12 \
-t "latest" \
-p clang \
-i stage2-install-clang -i stage2-install-clang-resource-headers \
-- \
-DLLVM_TARGETS_TO_BUILD=Native \
-DCMAKE_BUILD_TYPE=Release \
-DBOOTSTRAP_CMAKE_BUILD_TYPE=Release \
-DCLANG_ENABLE_BOOTSTRAP=ON \
-DCLANG_BOOTSTRAP_TARGETS="install-clang;install-clang-resource-headers"

root@686ff079f7b0:/llvm-project#

root@6111527893b7:/llvm-project# ./llvm/utils/docker/build_docker_image.sh -s debian12 -d mydocker/clang-debian12 -t "latest" -p clang -i stage2-install-clang -i stage2-install-clang-resource-headers -- -DLLVM_TARGETS_TO_BUILD=Native -DCMAKE_BUILD_TYPE=Release -DBOOTSTRAP_CMAKE_BUILD_TYPE=Release -DCLANG_ENABLE_BOOTSTRAP=ON -DCLANG_BOOTSTRAP_TARGETS="install-clang;install-clang-resource-headers"

```
