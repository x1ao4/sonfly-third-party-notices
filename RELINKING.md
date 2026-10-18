# 重新链接说明（LGPL 静态链接义务的履行方式）

本仓库随 Sonfly 发行镜像提供 FFmpeg / LAME / musl 的**对应源码与完整构建材料**，用于满足：

- FFmpeg（libav* 系列）适用 **GNU LGPL v2.1-or-later 第 6 节 (a)**；
- LAME / libmp3lame 适用 **GNU Library GPL v2（LGPL-2.0）第 6 节 (a)**（该版本无「共享库机制」选项，(a) 是静态链接下的核心路径）；
- 两份许可第 6 节均要求：提供库的完整对应源码（含修改），且对于与库链接的可执行文件，须使**用户能够修改库并重新链接**，生成含有修改版库的可执行文件。

## 1. 二进制构成（为什么本材料已完整覆盖链接义务）

Sonfly 发行物中的 `/usr/local/bin/ffmpeg` 是一个静态链接的可执行文件，其全部构成均为上游开源组件：

| 组成 | 许可 | 是否 Sonfly 自有代码 |
|---|---|---|
| FFmpeg 7.0.2（libav*、ffmpeg 前端等） | LGPL-2.1-or-later | 否（上游官方源码） |
| libmp3lame 3.100（以 `--disable-decoder` 构建，不含其内置 mpglib 解码引擎） | LGPL-2.0-or-later | 否（上游官方源码） |
| musl libc 1.2.5 | MIT | 否（上游官方源码） |

**该二进制中不含任何 Sonfly 自有代码或对象文件。** Sonfly 以独立子进程方式调用它（未链接、未修改其源码）。因此，第 6 节 (a) 要求的「work that uses the Library」即 FFmpeg 自身，其源码与构建材料就是本仓库 `sources/`、`build/` 中的内容——**全部提供，用户可自行修改任一库并重新链接**。

## 2. 材料与组件对应关系

| 组件 | 源码（sources/） | 许可全文（licenses/） | 构建材料（build/） |
|---|---|---|---|
| FFmpeg 7.0.2 | `ffmpeg-7.0.2.tar.xz`（SHA256 `8646515b…`）+ `.asc` 签名 | `FFmpeg-COPYING.LGPLv2.1`、`FFmpeg-LICENSE.md` | `build-ffmpeg-lgpl.sh`、`toolchain.txt`、`product-info.txt`、`full-build-log-2026-10-12.txt` |
| LAME 3.100 | `lame-3.100.tar.gz`（SHA256 `ddfe36ca…`；上游无签名文件） | `LAME-COPYING-LGPL-2.0`、`LAME-LICENSE` | 同上（同一构建脚本） |
| musl 1.2.5 | `musl-1.2.5.tar.gz`（SHA256 `a9a118bb…`）+ `.asc` 签名 | `musl-COPYRIGHT` | 同上；工具链版本见 `build/toolchain.txt` |

签名公钥在 `sources/keys/`；校验清单在 `sources/SHA256SUMS` 与根目录 `SHA256SUMS`。

## 3. Sonfly 构建方式（脚本）

Sonfly 镜像构建 `ffmpeg-build` 阶段所使用的调用方式：

```sh
# 基础镜像（按 digest 固定）：
#   alpine:3.22 @ sha256:5291449c3df73caf6ed85e649dec1b9e818b39a5d8c871e97afc13e9cd5e8fa8
apk add --no-cache build-base nasm pkgconf linux-headers curl
sh build-ffmpeg-lgpl.sh          # 脚本会自行下载源码（含 SHA256 强校验）并完成构建
# 产物：/build/out/bin/ffmpeg
```

脚本内包含对参考产物的 SHA256 fail-closed 校验（供应链完整性用途）；在相同基础镜像与工具链版本下，产物应为：

```
7e58a04d102ee638ae7d5e282b29e1a934baee13ce4655496113a3019f1441d5  ffmpeg
c7552887925b83624b669ee588c15173a1fc7ec656850952e3be059f89ef9d68  libmp3lame.a
```

## 4. 手动重建（使用本仓库源码归档；不需访问上游网络）

```sh
# 4.1 构建环境（与 Sonfly 发行构建一致）
docker run --rm -it -v "$PWD:/materials" \
  alpine:3.22@sha256:5291449c3df73caf6ed85e649dec1b9e818b39a5d8c871e97afc13e9cd5e8fa8 sh
apk add --no-cache build-base nasm pkgconf linux-headers

# 4.2 解压源码（容器内）
mkdir -p /build && cd /build
tar -xzf /materials/sources/lame-3.100.tar.gz
tar -xJf /materials/sources/ffmpeg-7.0.2.tar.xz

# 4.3 构建 LAME（静态库；-O2 必须显式指定，上游默认无优化标志会导致编码显著变慢）
#     --disable-decoder：不包含 mpglib 解码引擎（与 Sonfly 发行构建一致；Sonfly 仅使用编码 API）
cd /build/lame-3.100
CFLAGS="-O2 -fomit-frame-pointer" ./configure --prefix=/build/lame \
  --disable-shared --enable-static --disable-frontend --disable-decoder
make -j"$(nproc)" && make install

# 4.4 构建 FFmpeg（LGPL 配置；完整参数见 build/product-info.txt 与构建脚本）
cd /build/ffmpeg-7.0.2
./configure --prefix=/build/out \
  --disable-debug --disable-doc --disable-ffplay \
  --disable-indev=sndio --disable-outdev=sndio \
  --disable-indev=v4l2 --disable-outdev=v4l2 \
  --disable-indev=fbdev --disable-outdev=fbdev \
  --enable-libmp3lame --disable-shared --enable-static \
  --extra-cflags=-I/build/lame/include \
  --extra-ldflags="-static -L/build/lame/lib" \
  --cc=gcc
make -j"$(nproc)" && make install

# 4.5 校验（未修改任何源码、工具链一致时）
sha256sum /build/out/bin/ffmpeg    # 应为 7e58a04d…
```

## 5. 构建「修改过的库」并重新链接（LGPL 授予你的权利）

LGPL 第 6 节 (a) 的目的即让接收者能够修改库并重新链接。你可以：

1. **修改源码 / 构建配置**：在 4.2 解压后直接编辑 `lame-3.100/`（如 `libmp3lame/` 下的编码器源码）或 `ffmpeg-7.0.2/`（如 `libavcodec/` 下的解码器源码）；亦可自主调整构建参数（例如去掉 `--disable-decoder` 以启用 LAME 内置解码器——这是 LGPL 赋予你的权利；Sonfly 关闭解码器仅为满足自身使用需求，不构成对你的限制）；
2. **重新构建**：按 **§4** 的手动命令（4.3–4.4）重新构建即可——该流程**不含**任何参考哈希校验；
3. **获得修改版可执行文件**：`/build/out/bin/ffmpeg` 即含修改版库的静态可执行文件；修改版产物哈希与参考值不同属预期。

关于构建脚本：`build-ffmpeg-lgpl.sh` 内对参考产物的 SHA256 fail-closed 校验是 Sonfly 为保证**发行产物一致性**而设置的供应链校验。该校验**不应成为妨碍接收者行使 GNU LGPL 就 FFmpeg / libmp3lame 所授予的修改与重新链接权利的障碍**。

为便于行使该权利，Sonfly 就 `build/build-ffmpeg-lgpl.sh` 这一份脚本授予**有限许可**（与本仓库 README「四、合规辅助脚本」一致）：允许你为**重新构建、修改 FFmpeg / libmp3lame 并重新链接**之目的，复制、使用、修改与再分发该脚本（含其哈希比对逻辑；亦可直接改用 §4 的手动命令绕过该校验）；上述再分发**包含下游场景**——为使下游接收者能够行使相关 LGPL 权利（重新构建、修改并重新链接），可随**修改后的 FFmpeg / libmp3lame 产物**一并再分发该脚本。该许可仅及于该脚本文件，不延伸至 Sonfly 本体源码、业务实现或本仓库其他未授权内容；也不限制、不取代第三方许可证已经授予的任何权利，亦**不妨碍接收者行使该等权利**；你对库本身的修改仍须按相应 LGPL 条款分发。任何修改与重建均无需向 Sonfly 申请或报备。

> 说明：LGPL §6(a) 是否已要求对该类脚本授予上述许可、上述措辞是否已足以满足相关要求，属法律解释事项；本仓库声明不构成法律意见。

## 6. 验证方法与常见问题

- **验证参考产物**：`sha256sum ffmpeg` 对照 §3 中的参考值；`./ffmpeg -buildconf` 可查看完整构建参数（应无 `--enable-gpl` / `--enable-version3` / `--enable-nonfree`）。
- **验证运行**：该二进制为完全静态链接（`ldd` 显示 not a dynamic executable），可在任意 x86-64 Linux（glibc 或 musl 环境）直接运行。
- **哈希不一致？** 若你未修改源码但哈希与 §3 不同，通常是工具链版本差异（Alpine 仓库滚动更新；Sonfly 构建所用版本见 `build/toolchain.txt`）。这不代表构建失败——请在完全一致的工具链下重试，或对比 `-buildconf` 与功能表现。
- **签名验证**：FFmpeg 与 musl 的源码归档可用 `sources/keys/` 中的公钥验证（`gpg --import keys/*.asc && gpg --verify ffmpeg-7.0.2.tar.xz.asc ffmpeg-7.0.2.tar.xz`）。LAME 上游未发布签名文件。

## 7. 联系

如对本材料有疑问（例如需要补充材料或澄清构建细节），请通过 Sonfly 项目渠道联系我们。
