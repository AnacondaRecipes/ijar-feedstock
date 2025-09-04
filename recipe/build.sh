#!/bin/bash

set -euxo pipefail

source gen-bazel-toolchain

chmod +x bazel
pushd third_party/ijar
../../bazel build \
	--logging=6 \
	--subcommands \
	--verbose_failures \
	--local_resources=cpu=1 \
	--extra_toolchains=//bazel_toolchain:cc_cf_toolchain \
	--extra_toolchains=//bazel_toolchain:cc_cf_host_toolchain \
	--platforms=//bazel_toolchain:target_platform \
	--host_platform=//bazel_toolchain:build_platform \
	--cpu=${TARGET_CPU} \
	zipper ijar
mkdir -p $PREFIX/bin
cp ../../bazel-out/${TARGET_CPU}-fastbuild/bin/third_party/ijar/ijar $PREFIX/bin
cp ../../bazel-out/${TARGET_CPU}-fastbuild/bin/third_party/ijar/zipper $PREFIX/bin
