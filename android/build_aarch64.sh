#!/bin/sh

autoreconf -i

arm_cc="${NDKROOT}/toolchains/llvm/prebuilt/darwin-x86_64/bin/clang"
arm_cpp="${NDKROOT}/toolchains/llvm/prebuilt/darwin-x86_64/bin/clang++"

toolchain_params=(
    "-target aarch64-none-linux-android"
    "--sysroot=\"${NDKROOT}/platforms/android-24/arch-arm64\""
    "-gcc-toolchain \"${NDKROOT}/toolchains/aarch64-linux-android-4.9/prebuilt/darwin-x86_64\""
)

ldflags=(
#  "-nostdlib"
  "-Bdynamic"
  "-fPIE"
  "-pie"
  "-Wl,-dynamic-linker,/system/bin/linker"
  "-Wl,--gc-sections"
  "-Wl,-z,nocopyreloc"
  "-Wl,--whole-archive"
  "-Wl,--no-whole-archive"
  "-lm"
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
                 LDFLAGS=\"${toolchain_params[@]} ${ldflags[@]}\" \
		 --host=aarch64 --disable-coredump --disable-ptrace

make
