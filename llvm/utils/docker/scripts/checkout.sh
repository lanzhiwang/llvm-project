#!/usr/bin/env bash
#===- llvm/utils/docker/scripts/checkout.sh ---------------------===//
#
# Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
#
#===-----------------------------------------------------------------------===//

set -e
set -x

function show_usage() {
  cat <<EOF
Usage: checkout.sh [options]

Checkout git sources into /tmp/clang-build/src. Used inside a docker container.

Available options:
  -h|--help           show this help message
  -b|--branch         git branch to checkout, i.e. 'main',
                      'release/19.x'
                      (default: 'main')
  -r|--revision       git revision to checkout
  -c|--cherrypick     revision to cherry-pick. Can be specified multiple times.
                      Cherry-picks are performed in the sorted order using the
                      following command:
                      'git cherry-pick \$rev)'.
EOF
}

LLVM_GIT_REV="" # LLVM_GIT_REV=
CHERRYPICKS=""  # CHERRYPICKS=
LLVM_BRANCH=""  # LLVM_BRANCH=

while [[ $# -gt 0 ]]; do
  case "$1" in
  -r | --revision)
    shift
    LLVM_GIT_REV="$1"
    shift
    ;;
  -c | --cherrypick)
    shift
    CHERRYPICKS="$CHERRYPICKS $1"
    shift
    ;;
  -b | --branch)
    shift
    LLVM_BRANCH="$1"
    shift
    ;;
  -h | --help)
    show_usage
    exit 0
    ;;
  *)
    echo "Unknown option: $1"
    exit 1
    ;;
  esac
done

if [ "$LLVM_BRANCH" == "" ]; then
  LLVM_BRANCH="main"
fi
# LLVM_BRANCH=main

if [ "$LLVM_GIT_REV" != "" ]; then
  GIT_REV_ARG="$LLVM_GIT_REV"
  echo "Checking out git revision $LLVM_GIT_REV."
else
  GIT_REV_ARG=""
  echo "Checking out latest git revision."
fi
# GIT_REV_ARG=

# Sort cherrypicks and remove duplicates.
CHERRYPICKS="$(echo "$CHERRYPICKS" | xargs -n1 | sort | uniq | xargs)"
# echo '' | xargs -n1 | sort | uniq | xargs
# CHERRYPICKS=

function apply_cherrypicks() {
  local CHECKOUT_DIR="$1"
  # local CHECKOUT_DIR=/tmp/clang-build/src

  [ "$CHERRYPICKS" == "" ] || echo "Applying cherrypicks"
  pushd "$CHECKOUT_DIR"

  # This function is always called on a sorted list of cherrypicks.
  for CHERRY_REV in $CHERRYPICKS; do
    echo "Cherry-picking $CHERRY_REV into $CHECKOUT_DIR"
    EMAIL="someone@somewhere.net" git cherry-pick "$CHERRY_REV"
  done

  popd
}

CLANG_BUILD_DIR=/tmp/clang-build

# Get the sources from git.
echo "Checking out sources from git"
mkdir -p "$CLANG_BUILD_DIR/src"
# mkdir -p /tmp/clang-build/src

CHECKOUT_DIR="$CLANG_BUILD_DIR/src"
# CHECKOUT_DIR=/tmp/clang-build/src

echo "Checking out https://github.com/llvm/llvm-project.git to $CHECKOUT_DIR"
git clone -b "$LLVM_BRANCH" --single-branch \
  "https://github.com/llvm/llvm-project.git" \
  "$CHECKOUT_DIR"
# git clone -b main --single-branch https://github.com/llvm/llvm-project.git /tmp/clang-build/src
# $ ll /tmp/clang-build/src
# total 72
# -rw-r--r--   1 huzhi  staff   112B  6 11 09:45 CODE_OF_CONDUCT.md
# -rw-r--r--   1 huzhi  staff   638B  6 11 09:45 CONTRIBUTING.md
# -rw-r--r--   1 huzhi  staff    15K  6 11 09:45 LICENSE.TXT
# -rw-r--r--   1 huzhi  staff   2.2K  6 11 09:45 README.md
# -rw-r--r--   1 huzhi  staff   205B  6 11 09:45 SECURITY.md
# drwxr-xr-x  15 huzhi  staff   480B  6 11 09:45 bolt
# drwxr-xr-x  24 huzhi  staff   768B  6 11 09:46 clang
# drwxr-xr-x  23 huzhi  staff   736B  6 11 09:45 clang-tools-extra
# drwxr-xr-x   4 huzhi  staff   128B  6 11 09:46 cmake
# drwxr-xr-x  18 huzhi  staff   576B  6 11 09:46 compiler-rt
# drwxr-xr-x   9 huzhi  staff   288B  6 11 09:46 cross-project-tests
# drwxr-xr-x  19 huzhi  staff   608B  6 11 09:46 flang
# drwxr-xr-x  14 huzhi  staff   448B  6 11 09:46 flang-rt
# drwxr-xr-x  23 huzhi  staff   736B  6 11 09:46 libc
# drwxr-xr-x  17 huzhi  staff   544B  6 11 09:46 libclc
# drwxr-xr-x  19 huzhi  staff   608B  6 11 09:46 libcxx
# drwxr-xr-x  14 huzhi  staff   448B  6 11 09:46 libcxxabi
# drwxr-xr-x  10 huzhi  staff   320B  6 11 09:46 libunwind
# drwxr-xr-x  22 huzhi  staff   704B  6 11 09:46 lld
# drwxr-xr-x  22 huzhi  staff   704B  6 11 09:46 lldb
# drwxr-xr-x  27 huzhi  staff   864B  6 11 09:46 llvm
# drwxr-xr-x   6 huzhi  staff   192B  6 11 09:46 llvm-libgcc
# drwxr-xr-x  18 huzhi  staff   576B  6 11 09:46 mlir
# drwxr-xr-x  17 huzhi  staff   544B  6 11 09:46 offload
# drwxr-xr-x  13 huzhi  staff   416B  6 11 09:46 openmp
# drwxr-xr-x  18 huzhi  staff   576B  6 11 09:46 polly
# drwxr-xr-x  11 huzhi  staff   352B  6 11 09:46 pstl
# -rw-r--r--   1 huzhi  staff    57B  6 11 09:46 pyproject.toml
# drwxr-xr-x   5 huzhi  staff   160B  6 11 09:46 runtimes
# drwxr-xr-x   5 huzhi  staff   160B  6 11 09:46 third-party
# drwxr-xr-x   3 huzhi  staff    96B  6 11 09:46 utils
# $

# $ ll /tmp/clang-build/src/llvm
# total 256
# -rw-r--r--    1 huzhi  staff    62K  6 11 09:46 CMakeLists.txt
# -rw-r--r--    1 huzhi  staff    13K  6 11 09:46 CREDITS.TXT
# -rw-r--r--    1 huzhi  staff    15K  6 11 09:46 LICENSE.TXT
# -rw-r--r--    1 huzhi  staff    17K  6 11 09:46 Maintainers.md
# -rw-r--r--    1 huzhi  staff   663B  6 11 09:46 README.txt
# -rw-r--r--    1 huzhi  staff   1.0K  6 11 09:46 RELEASE_TESTERS.TXT
# drwxr-xr-x    9 huzhi  staff   288B  6 11 09:46 benchmarks
# drwxr-xr-x    4 huzhi  staff   128B  6 11 09:46 bindings
# drwxr-xr-x   11 huzhi  staff   352B  6 11 09:46 cmake
# -rwxr-xr-x    1 huzhi  staff   573B  6 11 09:46 configure
# drwxr-xr-x  222 huzhi  staff   6.9K  6 11 09:46 docs
# drwxr-xr-x   15 huzhi  staff   480B  6 11 09:46 examples
# drwxr-xr-x    9 huzhi  staff   288B  6 11 09:46 include
# drwxr-xr-x   51 huzhi  staff   1.6K  6 11 09:46 lib
# drwxr-xr-x    3 huzhi  staff    96B  6 11 09:46 projects
# drwxr-xr-x    3 huzhi  staff    96B  6 11 09:46 resources
# drwxr-xr-x    3 huzhi  staff    96B  6 11 09:46 runtimes
# drwxr-xr-x   40 huzhi  staff   1.3K  6 11 09:46 test
# drwxr-xr-x   99 huzhi  staff   3.1K  6 11 09:46 tools
# drwxr-xr-x   45 huzhi  staff   1.4K  6 11 09:46 unittests
# drwxr-xr-x  103 huzhi  staff   3.2K  6 11 09:46 utils
# $

pushd $CHECKOUT_DIR
# pushd /tmp/clang-build/src
git checkout -q $GIT_REV_ARG
# git checkout -q
popd
# popd

# We apply cherrypicks to all repositories regardless of whether the revision
# changes this repository or not. For repositories not affected by the
# cherrypick, applying the cherrypick is a no-op.
apply_cherrypicks "$CHECKOUT_DIR"
# apply_cherrypicks /tmp/clang-build/src

CHECKSUMS_FILE="/tmp/checksums/checksums.txt"
# CHECKSUMS_FILE=/tmp/checksums/checksums.txt

if [ -f "$CHECKSUMS_FILE" ]; then
  echo "Validating checksums for LLVM checkout..."
  python "$(dirname "$0")/llvm_checksum/llvm_checksum.py" -c "$CHECKSUMS_FILE" \
    --partial --multi_dir "$CLANG_BUILD_DIR/src"
else
  echo "Skipping checksumming checks..."
fi

echo "Done"
