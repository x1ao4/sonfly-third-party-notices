#!/bin/sh
# ============================================================================
# FFmpeg 7.0.2 + LAME 3.100 · LGPL 静态构建脚本
#
# 用途：在 Docker 构建阶段（docker/Dockerfile 的 ffmpeg-build 阶段，
#       基础镜像 alpine:3.22 / musl）内执行，产出静态 ffmpeg 二进制，
#       随后 COPY 进最终运行镜像（python:3.12-slim / glibc，可独立运行）。
#
# 背景：本脚本从 FFmpeg / LAME 上游源码构建 LGPL 配置的静态 ffmpeg 二进制，
#       供闭源分发的发行物使用；产物转码输出与既定生产基线逐字节一致（含 WMA）。
#
# 许可要点：
#   · 不启用 --enable-gpl / --enable-version3 / --enable-nonfree；
#   · 仅静态链入 libmp3lame（LGPL-2.0-or-later）与 musl libc（MIT）；
#   · LAME 以 --disable-decoder 构建：不编译其内置 mpglib 解码引擎、不定义
#     HAVE_MPGLIB / DECODE_ON_THE_FLY，解码器对象不进入任何分发产物；
#   · 构建后双重强校验：configure 自报 License 行 + 产物关键字扫描。
#
# fail-closed 设计（供应链完整性，构建漂移即中断）：
#   1. 两份源码必须匹配记录的 SHA256，否则立即中断；
#   2. LAME 中间库与最终产物 SHA256 均与已验证值比对（x86_64 参考值），
#      任何漂移即中断——须重新完成全量逐字节回归验证后才可放行，
#      不得直接沿用旧结论，也不得直接认定失败；
#   3. 参考哈希留空 = 记录模式（仅供升级/换配置时由维护者显式留空使用）：
#      打印实际哈希并继续；记录后必须回填并重新构建确认，不得长期留空。
#
# 维护流程：改版本/URL/SHA256 → 构建 → 全量逐字节回归 → 更新本脚本参考值
#       与随镜像分发的第三方声明。
#
# 构建工具链（alpine:3.22 实测快照，实际版本以构建日志为准）：
#       gcc 14.2.0-r6 / binutils 2.44-r3 / make 4.4.1-r3 / nasm 2.16.03-r0 /
#       musl 1.2.5-r12 / pkgconf 2.4.3-r0 / linux-headers 6.14.2-r0
# ============================================================================
set -eux

FFMPEG_VERSION="7.0.2"
FFMPEG_URL="https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.xz"
FFMPEG_SRC_SHA256="8646515b638a3ad303e23af6a3587734447cb8fc0a0c064ecdb8e95c4fd8b389"

LAME_VERSION="3.100"
LAME_URL="https://downloads.sourceforge.net/project/lame/lame/${LAME_VERSION}/lame-${LAME_VERSION}.tar.gz"
LAME_SRC_SHA256="ddfe36cab873794038ae2c1210557ad34857a4b6bdc515785d1da9e175b1da1e"

# 已验证参考哈希（x86_64；LAME 以 --disable-decoder 构建；
#   对应双跑一致且通过目标环境全量逐字节回归的同一二进制）
FFMPEG_BIN_SHA256_X86_64="7e58a04d102ee638ae7d5e282b29e1a934baee13ce4655496113a3019f1441d5"
LAME_LIB_SHA256_X86_64="c7552887925b83624b669ee588c15173a1fc7ec656850952e3be059f89ef9d68"

BUILD_DIR=/build
LAME_PREFIX="${BUILD_DIR}/lame"
OUT_PREFIX="${BUILD_DIR}/out"
LOG_DIR="${BUILD_DIR}/logs"

# ---- [0] 构建环境记录（进构建日志，作为工具链证据） ----
mkdir -p "$LOG_DIR"
echo "===== [0] 构建环境记录 ====="
head -3 /etc/os-release
gcc --version | head -1
ld --version | head -1
make --version | head -1
nasm -v
apk info -v 2>/dev/null | grep -E '^(musl|gcc|binutils|make|nasm|pkgconf|linux-headers|build-base)' | sort

# ---- [1] 源码获取与 fail-closed 校验 ----
cd "$BUILD_DIR"
echo "===== [1] 下载源码（含 SHA256 fail-closed 校验）====="
curl -fsSL --retry 3 --retry-delay 2 -o "lame-${LAME_VERSION}.tar.gz" "$LAME_URL"
echo "${LAME_SRC_SHA256}  lame-${LAME_VERSION}.tar.gz" | sha256sum -c -
curl -fsSL --retry 3 --retry-delay 2 -o "ffmpeg-${FFMPEG_VERSION}.tar.xz" "$FFMPEG_URL"
echo "${FFMPEG_SRC_SHA256}  ffmpeg-${FFMPEG_VERSION}.tar.xz" | sha256sum -c -

# ---- [2] LAME 3.100（静态库）----
# CFLAGS 必须显式给 -O2：上游源码默认构建无优化标志，MP3 编码性能显著降低
#   （实测约 3 倍耗时）；-O2 与 -O3 转码输出一致、性能同档，取保守档 -O2。
# --disable-decoder：关闭 mpglib 解码引擎——不定义 HAVE_MPGLIB / DECODE_ON_THE_FLY；
#   效果：libmp3lame.a 不含 mpglib 对象；全部 hip_* 调用随宏消失；
#   ffmpeg 二进制内 mpglib 字节签名归零。仅影响解码功能
#   （lame --decode / replaygain-accurate），编码路径与转码输出不受影响。
echo "===== [2] 构建 LAME ${LAME_VERSION} ====="
tar -xzf "lame-${LAME_VERSION}.tar.gz"
cd "lame-${LAME_VERSION}"
CFLAGS="-O2 -fomit-frame-pointer" ./configure \
  --prefix="$LAME_PREFIX" \
  --disable-shared --enable-static --disable-frontend --disable-decoder \
  > "${LOG_DIR}/lame-configure.log" 2>&1 || { cat "${LOG_DIR}/lame-configure.log"; exit 1; }
cat "${LOG_DIR}/lame-configure.log"
# 强校验：decoder 必须处于关闭状态（防止 --disable-decoder 参数被误删/替换）
grep -q 'use of mpg123 decoder\.\.\. no' "${LOG_DIR}/lame-configure.log" || {
  echo "!! LAME decoder 未按预期关闭（configure 输出异常），构建终止"; exit 1; }
make -j"$(nproc)" > "${LOG_DIR}/lame-make.log" 2>&1 || { tail -100 "${LOG_DIR}/lame-make.log"; exit 1; }
cat "${LOG_DIR}/lame-make.log"
make install > "${LOG_DIR}/lame-install.log" 2>&1
cd "$BUILD_DIR"

LAME_LIB_SHA256="$(sha256sum "${LAME_PREFIX}/lib/libmp3lame.a" | awk '{print $1}')"
echo "LAME 静态库 SHA256: ${LAME_LIB_SHA256}"
if [ "$(uname -m)" = "x86_64" ]; then
  if [ -z "$LAME_LIB_SHA256_X86_64" ]; then
    echo "WARN：LAME 参考哈希为空（记录模式）——请记录后在脚本中回填，并重新构建确认。"
  elif [ "$LAME_LIB_SHA256" != "$LAME_LIB_SHA256_X86_64" ]; then
    echo "!! LAME 静态库哈希与已验证参考值不一致（工具链漂移？），构建终止。"
    echo "   预期: ${LAME_LIB_SHA256_X86_64}"
    echo "   实际: ${LAME_LIB_SHA256}"
    exit 1
  fi
fi

# ---- [3] FFmpeg 7.0.2（LGPL 静态）----
echo "===== [3] 构建 FFmpeg ${FFMPEG_VERSION} ====="
tar -xJf "ffmpeg-${FFMPEG_VERSION}.tar.xz"
cd "ffmpeg-${FFMPEG_VERSION}"
./configure \
  --prefix="$OUT_PREFIX" \
  --disable-debug --disable-doc --disable-ffplay \
  --disable-indev=sndio --disable-outdev=sndio \
  --disable-indev=v4l2 --disable-outdev=v4l2 \
  --disable-indev=fbdev --disable-outdev=fbdev \
  --enable-libmp3lame \
  --disable-shared --enable-static \
  --extra-cflags="-I${LAME_PREFIX}/include" \
  --extra-ldflags="-static -L${LAME_PREFIX}/lib" \
  --cc=gcc \
  > "${LOG_DIR}/ffmpeg-configure.log" 2>&1 || { cat "${LOG_DIR}/ffmpeg-configure.log"; exit 1; }
cat "${LOG_DIR}/ffmpeg-configure.log"
# configure 自报 License 必须是 LGPL（构建期快速检查；最终以 -L 实测为准）
grep -q '^License: LGPL' "${LOG_DIR}/ffmpeg-configure.log" || {
  echo "!! configure 自报 License 非 LGPL，构建终止"; exit 1; }
make -j"$(nproc)" > "${LOG_DIR}/ffmpeg-make.log" 2>&1 || { tail -200 "${LOG_DIR}/ffmpeg-make.log"; exit 1; }
cat "${LOG_DIR}/ffmpeg-make.log"
make install > "${LOG_DIR}/ffmpeg-install.log" 2>&1
cd "$BUILD_DIR"

# ---- [4] 产物自检（fail-closed）----
FFMPEG_BIN="${OUT_PREFIX}/bin/ffmpeg"
echo "===== [4] 产物自检 ====="
ls -la "$FFMPEG_BIN"

echo "--- [4.1] 版本与许可自报 ---"
"$FFMPEG_BIN" -version 2>&1 | head -3
"$FFMPEG_BIN" -L 2>&1 | tail -16
"$FFMPEG_BIN" -L 2>&1 | grep -q 'GNU Lesser General Public' || {
  echo "!! -L 未自报 LGPL，构建终止"; exit 1; }

echo "--- [4.2] GPL/version3/nonfree 关键字检查（必须为 0 项）---"
if "$FFMPEG_BIN" -buildconf 2>&1 | grep -E 'enable-gpl|enable-version3|enable-nonfree'; then
  echo "!! 构建配置中发现 GPL/version3/nonfree 项，终止（不符合 LGPL 发行要求）"
  exit 1
fi
echo "OK：无 GPL/version3/nonfree 配置项"

echo "--- [4.3] GPL 组件残留检查（必须为 0 项）---"
if "$FFMPEG_BIN" -encoders 2>/dev/null | grep -E 'libx264|libx265|libxvid|vidstab|frei0r|rubberband|libzvbi'; then
  echo "!! 产物中发现 GPL 组件，终止"
  exit 1
fi
echo "OK：无 GPL 组件残留"

echo "--- [4.4] 产物哈希 fail-closed 校验 ---"
ACTUAL_SHA256="$(sha256sum "$FFMPEG_BIN" | awk '{print $1}')"
echo "产物 SHA256: ${ACTUAL_SHA256}"
if [ "$(uname -m)" = "x86_64" ]; then
  if [ -z "$FFMPEG_BIN_SHA256_X86_64" ]; then
    echo "WARN：参考哈希为空（记录模式）——请记录 ${ACTUAL_SHA256} 并回填后重新构建确认。"
  elif [ "$ACTUAL_SHA256" != "$FFMPEG_BIN_SHA256_X86_64" ]; then
    echo "!! 产物哈希与已验证参考值不一致，构建终止。"
    echo "   预期: ${FFMPEG_BIN_SHA256_X86_64}"
    echo "   实际: ${ACTUAL_SHA256}"
    echo "   处置：先确认源码版本、SHA256 与构建工具链、configure 参数是否发生漂移；"
    echo "         再对照旧二进制重新完成全量逐字节回归（含 WMA 等样本）后方可放行；"
    echo "         不得直接认定构建失败或成功，也不得沿用旧结论。"
    exit 1
  else
    echo "OK：产物哈希与已验证参考值一致（= 已通过逐字节回归的同一二进制）"
  fi
else
  echo "WARN：当前架构 $(uname -m) 无已验证参考哈希；"
  echo "      该产物在完成回归验证前不得用于生产（记录哈希：${ACTUAL_SHA256}）。"
fi

# ---- [5] 清理下载归档与源码树（减小构建缓存体积；安装前缀保留）----
rm -f "lame-${LAME_VERSION}.tar.gz" "ffmpeg-${FFMPEG_VERSION}.tar.xz"
rm -rf "${BUILD_DIR}/lame-${LAME_VERSION}" "${BUILD_DIR}/ffmpeg-${FFMPEG_VERSION}"

echo "===== 构建完成：${FFMPEG_BIN} ====="
