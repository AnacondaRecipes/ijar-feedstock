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

if [[ "${target_platform}" == linux-* ]]; then
    # The bazel crosstool bakes "$PREFIX/lib:$BUILD_PREFIX/lib" into the RPATH, so the
    # shipped binaries keep a hardcoded build-host path. Rewrite it to the relocatable
    # conda location; bazel marks its outputs read-only, hence the chmod.
    chmod +w $PREFIX/bin/ijar $PREFIX/bin/zipper
    patchelf --set-rpath '$ORIGIN/../lib' $PREFIX/bin/ijar $PREFIX/bin/zipper
fi
