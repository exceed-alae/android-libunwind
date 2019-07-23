#!/bin/sh

prefix_dir=`pwd`/out
mkdir -p ${prefix_dir}

automake
autoreconf -i

target="aarch64-linux-android"
gcc_ver="4.9"
host="darwin-x86_64"
compiler_bin="${NDKROOT}/toolchains/llvm/prebuilt/${host}/bin/"

arm_cc="${compiler_bin}/clang"
arm_cpp="${compiler_bin}/clang++"

toolchain_base="${NDKROOT}/toolchains/${target}-${gcc_ver}/prebuilt/${host}"
toolchain_bin="${toolchain_base}/bin"

toolchain_params=(
    "-target aarch64-linux-android"
    "--sysroot=${NDKROOT}/platforms/android-21/arch-arm64"
    "-gcc-toolchain ${toolchain_base}"
)

cflags=(
    "-DUNW_ADDITIONAL_PREFIX=libunwind_override"
)

ldflags=(
  "-fPIE"
  "-pie"
  "-Wl,--gc-sections"
  "-Wl,--whole-archive"
  "-Wl,--no-whole-archive"
  "-lm"
  "-Wl,-Bdynamic"
  "-Wl,-z,nocopyreloc"
  "-Wl,-z,noexecstack"
  "-Wl,-z,relro"
  "-Wl,-z,now"
  "-Wl,--warn-shared-textrel"
  "-Wl,--fatal-warnings"
  "-Wl,--no-undefined"
  "-ldl"
)

eval ./configure CC=\"${arm_cc} ${toolchain_params[@]}\" \
                 CPP=\"${arm_cc} ${toolchain_params[@]} -E\" \
                 CXX=\"${arm_cpp} ${toolchain_params[@]}\" \
                 CXXCPP=\"${arm_cpp} ${toolchain_params[@]} -E\" \
                 LD=\"${arm_cpp} ${toolchain_params[@]}\" \
                 LDFLAGS=\"${ldflags[@]}\" \
		 CFLAGS=\"${cflags[@]}\" \
                 CXXFLAGS=\"${cflags[@]}\" \
                 AR=\"${toolchain_bin}/${target}-ar\" \
                 RANLIB=\"${toolchain_bin}/${target}-ranlib\" \
		 --host=aarch64-linux-android --disable-coredump --enable-cxx-exceptions --disable-shared --enable-static --prefix=${prefix_dir}

make
make install
tar zcvf libunwind_android_aarch64.tar.gz -C ${prefix_dir} include lib
