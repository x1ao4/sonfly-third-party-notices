# THIRD-PARTY-NOTICES

本文件随 Sonfly 发行镜像分发（镜像内路径 `/usr/share/doc/sonfly/THIRD-PARTY-NOTICES`）。同目录 `licenses/` 同时包含按来源逐项标明的上游原始许可材料与 SPDX 标准许可证参考文本；参考文本不是任何具体组件版本的原始 LICENSE。材料类别与来源见 `licenses/README.txt`。

标注说明：〔法定〕= 适用许可证原文明确要求的义务；〔保守〕= 非强制、为透明披露或稳妥处理而附加的说明。

**组件总览**：FFmpeg 7.0.2（LGPL-2.1-or-later，静态构建）静态链入 LAME 3.100（LGPL-2.0-or-later，libmp3lame）与 musl libc 1.2.5（MIT）；Python 3.12 及 36 个 pip 依赖；Node.js 及内置 NCM API（249 条生产依赖安装路径，其中 1 条为 LGPL-3.0-only，见 §五）；前端构建产物（4 个运行时依赖）；Debian 13 trixie 基础系统包。

---

## 一、FFmpeg 7.0.2（LGPL 静态构建）

- 版本与许可：**7.0.2**，**LGPL-2.1-or-later**——构建时 configure 自报 `License: LGPL version 2.1 or later`；运行时 `ffmpeg -L` 实测同。
- 官方源码：`https://ffmpeg.org/releases/ffmpeg-7.0.2.tar.xz`
  - SHA256 `8646515b638a3ad303e23af6a3587734447cb8fc0a0c064ecdb8e95c4fd8b389`
  - 上游 GPG 签名 `ffmpeg-7.0.2.tar.xz.asc` 由 FFmpeg release signing key `<ffmpeg-devel@ffmpeg.org>` 签发；该密钥指纹为 `FCF986EA15E6E293A5644F10B4322F04D67658D8`（与 ffmpeg.org 下载页公布的指纹一致），公钥见公开发布的材料仓库 `sources/keys/`。
- 构建方式：**从上游源码自行构建**（非第三方预编译包）。构建脚本与构建材料随公开发布的材料仓库提供；脚本对源码与产物均做 SHA256 fail-closed 校验。
  - 构建基础镜像：`alpine:3.22` @ `sha256:5291449c3df73caf6ed85e649dec1b9e818b39a5d8c871e97afc13e9cd5e8fa8`（多阶段构建的 `ffmpeg-build` 阶段；编译工具链不进入最终镜像）。
  - configure 参数（完整）：`--prefix=/build/out --disable-debug --disable-doc --disable-ffplay --disable-indev=sndio --disable-outdev=sndio --disable-indev=v4l2 --disable-outdev=v4l2 --disable-indev=fbdev --disable-outdev=fbdev --enable-libmp3lame --disable-shared --enable-static --extra-cflags=-I/build/lame/include --extra-ldflags='-static -L/build/lame/lib' --cc=gcc`
  - 构建工具链：gcc 14.2.0-r6 / binutils 2.44-r3 / make 4.4.1-r3 / nasm 2.16.03-r0 / musl 1.2.5-r12 / pkgconf 2.4.3-r0 / linux-headers 6.14.2-r0。
  - **未启用** `--enable-gpl` / `--enable-version3` / `--enable-nonfree`；二进制内无任何 GPL 组件（构建脚本在构建时对配置与组件列表做 fail-closed 强校验）。
- 本镜像使用的产物：23,493,032 字节，SHA256 `7e58a04d102ee638ae7d5e282b29e1a934baee13ce4655496113a3019f1441d5`。
- 许可全文：`licenses/FFmpeg-COPYING.LGPLv2.1`、`licenses/FFmpeg-LICENSE.md`。〔法定〕
- 对应源码：FFmpeg 官方源码 tarball（SHA256 已固定）+ 构建脚本 + 构建工具链记录，随公开发布的材料仓库提供。〔法定〕
- **静态链接说明**：该二进制内静态链入了以下两个库；Sonfly 自身代码**未被链接**进该二进制（Sonfly 以独立子进程方式调用 ffmpeg 命令行程序）：
  - LAME / libmp3lame 3.100（LGPL-2.0-or-later，见 §二）
  - musl libc 1.2.5（MIT，见 §三）
- 用途声明〔保守〕：Sonfly 以独立子进程调用 FFmpeg 完成音频转码（不可被浏览器解码的音频格式 → MP3 256k 缓存）；未修改 FFmpeg / LAME 任何源码。
- **IJG 致谢**〔法定，FFmpeg LICENSE.md 对三个 libjpeg 来源文件的专门要求〕：本镜像内 FFmpeg 包含三个取自 libjpeg 的文件——`libavcodec/jfdctfst.c`、`libavcodec/jfdctint_template.c`、`libavcodec/jrevdct.c`；谨此向 **Independent JPEG Group（IJG）** 致谢。上述三文件未做任何增删修改（构建使用上游原样源码）。

## 二、LAME 3.100（libmp3lame，静态编入 FFmpeg）

- 版本与许可：**3.100**，**LGPL-2.0-or-later**——随包 `COPYING` 为 GNU Library General Public License Version 2（June 1991）全文；源码头文件含 "or later"。**注意与 LGPL-2.1 是两份不同许可文本**。
- 官方源码：`https://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz`
  - SHA256 `ddfe36cab873794038ae2c1210557ad34857a4b6bdc515785d1da9e175b1da1e`
  - SHA512 `0844b9eadb4aacf8000444621451277de365041cc1d97b7f7a589da0b7a23899310afd4e4d81114b9912aa97832621d20588034715573d417b2923948c08634b`（与 Alpine `main/lame` 的 `APKBUILD` 记录一致，独立交叉佐证）
  - 上游**未提供** GPG 签名文件（SourceForge 项目发布目录中无 `.sig` / `.asc`）。
- 构建方式：**上游源码直接构建，不含任何发行版补丁**（`./configure --disable-shared --enable-static --disable-frontend --disable-decoder`）。
  - `--disable-decoder`：LAME 内置 mpglib 解码引擎不编译、不进入任何分发产物——Sonfly 仅使用 LAME 编码 API。产物内不含 mpglib 对象与 `hip_*` / `lame_decode` 符号。
  - 编译标志：`CFLAGS="-O2 -fomit-frame-pointer"`。
  - 中间产物：`libmp3lame.a` SHA256 `c7552887925b83624b669ee588c15173a1fc7ec656850952e3be059f89ef9d68`。
- 许可全文：`licenses/LAME-COPYING-LGPL-2.0`、`licenses/LAME-LICENSE`。〔法定〕
- 项目请求的承认声明〔保守，LAME 项目在其随包 LICENSE 文件中的请求〕：本软件使用 LAME 编码器；LAME 项目地址 <https://lame.sourceforge.io/>（原 www.mp3dev.org）。未对 LAME 源码做任何修改。
- 版权声明〔保守·LGPL-2.0 §6「运行显示版权声明」条款之文本缓解〕：libmp3lame 各源文件头载有逐作者版权行（如 `Copyright (c) 1999-2000 Mark Taylor`、`(c) 2000-2017 Robert Hegemann`、`(c) 2000-2005 Takehiro Tominaga` 等，完整列表见对应源码）。镜像内 ffmpeg 运行时输出不展示上述版权行（LAME 无运行时输出），故于本文档中补足。
- 对应源码：上游 tarball（SHA256 已固定），随公开发布的材料仓库提供。〔法定〕

## 三、musl libc 1.2.5（静态编入 FFmpeg）

- 版本与许可：Alpine `musl` / `musl-dev` **1.2.5-r12**，许可 **MIT**。
- 官方源码：`https://musl.libc.org/releases/musl-1.2.5.tar.gz`
  - SHA256 `a9a118bbe84d8764da0ea0d28b3ab3fae8477fc7e4085d90102b8596fc7c75e4`
  - 上游 GPG 签名 `musl-1.2.5.tar.gz.asc` 由 `musl libc <musl@libc.org>` 签发，密钥指纹 `836489290BB6B70F99FFDA0556BCDB593020450F`，公钥见公开发布的材料仓库 `sources/keys/`。
- 许可全文：`licenses/musl-COPYRIGHT`（上游 COPYRIGHT：`Copyright © 2005-2020 Rich Felker, et al.`，标准 MIT 条款）。〔法定——**Alpine 的 musl 包不携带许可文本**，本材料是许可文本的正式来源。〕
- 静态链接分析：musl 为 MIT，义务为「保留版权与许可声明」，**不引入 LGPL 式重新链接义务**。
- 对应源码：上游 tarball（SHA256 已固定），随公开发布的材料仓库提供。〔保守：可复现性〕

## 四、Python 运行时与依赖（36 包）

- Python 3.12：PSF License Version 2（`python:3.12-slim`，Debian trixie）。
- 依赖清单（声明见 `backend/requirements.txt`；全量版本与产物哈希以 `pip-compile --generate-hashes` 生成的 `backend/requirements.lock` 锁定；逐包明细见公开发布的材料仓库中的 `SBOM.md`）：

| 许可证 | 包 |
|---|---|
| MPL-2.0 | certifi（未修改；附许可文本 + 上游源码指针）〔法定〕 |
| Apache-2.0（OR BSD-3） | bcrypt、cryptography、python-multipart |
| Apache-2.0 | opentelemetry-api（附许可全文 `licenses/opentelemetry-api-LICENSE-Apache-2.0`）〔法定：Apache-2.0 §4(b) 随分发提供许可副本〕 |
| MIT | fastapi、pydantic、pydantic-core、pydantic-settings、PyJWT、pypinyin、PyYAML、SQLAlchemy、aiosqlite、uvloop、watchfiles、httptools、h11、annotated-types、anyio、typing-inspection、annotated-doc |
| MIT-0 | cffi |
| MIT-CMU | Pillow |
| BSD-3-Clause | httpx、starlette、uvicorn、python-dotenv、passlib、idna、httpcore、pycparser、websockets、click、greenlet（MIT AND PSF-2.0） |
| PSF-2.0 | typing_extensions |

## 五、Node.js 运行时与内置 NCM API

- **Node.js**：官方 `node:24-trixie-slim` 镜像提供的 **24.22.0**（MIT）。镜像仅复制其 `node` 可执行文件与 `LICENSE`（`licenses/Node.js-LICENSE`，2946 行 / 157,609 字节，含 V8、ICU、OpenSSL、zlib 等内嵌组件的许可与版权声明）；npm 与 node 头文件不随镜像分发。
- **NCM API**：`@neteasecloudmusicapienhanced/api` **4.36.1**，MIT（`backend/vendor/ncm-api/LICENSE`，Copyright (c) 2013-2022 Binaryify）——许可文本随镜像保留〔法定：MIT 需在副本中保留版权与许可声明〕。该内置副本相对上游 npm 发布包（`4.36.1`）含以下本地修改，逐项登记与上游升级重放步骤见源码树内 `backend/vendor/ncm-api/VENDOR-PATCHES.md`（该文件不随镜像分发）：
  1. **P-001 日志白名单化**：新增 `util/log-redact.js`；修改 `server.js`、`util/request.js`、`generateConfig.js`，使请求日志只记录方法与不含查询串的路径，错误日志只输出白名单字段，不输出 Cookie、查询串与响应体；
  2. **P-002 初始化稳健性**：`generateConfig.js` 调整 xeapi 公钥与匿名注册的执行顺序并复用 deviceId；`module/register_anonimous.js` 复用同一 deviceId；`module/login_qr_check.js` 在扫码检查返回异常结构时降级为固定错误码与空 cookie；
  3. **P-003 可选数据降级**：`util/index.js` 在 `data/china_ip_ranges.txt` 缺失时由 error 降为 warning 并使用兜底随机国内 IP；上游 `data/` 目录（`china_ip_ranges.txt`、`deviceid.txt`）未纳入本地副本；
  4. **P-004 入口包装**：新增 `index.js`、`index.mjs`（各 1 行，仅转发至 `app.js`；镜像启动使用 `app.js`，二者未被调用）；
  5. **P-005 依赖清单调整**：移除上游声明但未使用的 `gzip` 依赖（0.1.0），并生成 `package-lock.json` 固定依赖树；上游 `package.json` 的 `scripts` 段仅调整位置，内容未变；
  6. **P-006 依赖安全升级**：`axios` 1.20.0、`express` 5.3.0、`music-metadata` 11.16.1；通过 `overrides` 将 `qs` 统一到 6.16.1，并随依赖解析更新 `socks` 2.8.10、`ip-address` 10.7.4、嵌套 `body-parser` 1.20.8 等；`node-forge`、`basic-ftp` 因无修复版本或上游约束且当前调用路径不可达，保留原版本并记录。

  以上修改均不涉及许可文本与版权声明的变更。

### 部分 npm 依赖的许可材料说明

下表六个包在其发布归档与上游仓库中未见版本对应的原始许可证全文及明确版权声明行；其 `license` 字段均为 `package.json` 的元数据声明，不单独作为授权充分的证明。`SPDX-MIT-REFERENCE.txt` 与 `SPDX-ISC-REFERENCE.txt` 是 SPDX 标准许可证参考文本，**不是**下列具体 npm 版本随包发布或从其归档提取的原始 LICENSE，也不包含这些版本的版权声明、权利人或年份；占位符保持未填写，未根据 `author` 字段推定。本说明与随附的标准参考文本不改变上述材料的实际状态。

| 实际生产依赖路径 | 随包 `package.json` 声明（原样要点） | 依赖用途与许可材料状态 | 本目录材料性质 |
|---|---|---|---|
| `@tokenizer/token@0.3.0`（顶层） | `license: MIT`；`author: {name: Borewit, url: https://github.com/Borewit}` | `music-metadata` / `strtok3` / `token-types` 依赖链；归档只有 `package.json`、README、`index.d.ts`，无 JavaScript 运行时代码；发布归档与上游仓库中未见 LICENSE 文件，版本树无明确版权行 | `SPDX-MIT-REFERENCE.txt`：仅标准参考文本，非该版本原始 LICENSE |
| `agent-base@6.0.2`（顶层） | `license: MIT`；`author: Nathan Rajlich <nathan@tootallnate.net> (http://n8.io/)` | 由 `https-proxy-agent@5.0.1` 以依赖声明 `agent-base: "6"` 引入；另有 `agent-base@7.1.4` 嵌套路径，版本分开统计；发布归档与上游仓库中未见 LICENSE 文件或版权行 | `SPDX-MIT-REFERENCE.txt`：仅标准参考文本，非该版本原始 LICENSE |
| `degenerator@5.0.1`（顶层） | `license: MIT`；`author: Nathan Rajlich <nathan@tootallnate.net> (http://n8.io/)` | `pac-proxy-agent@7.2.0` → `pac-resolver@7.0.1` 引入，服务 PAC 解析路径；包本身含运行时代码；嵌套 `escodegen` 的 BSD LICENSE 仅属于 escodegen，不替代本包材料；该版本发布归档与上游仓库中未见 LICENSE 文件或版权行 | `SPDX-MIT-REFERENCE.txt`：仅标准参考文本，非该版本原始 LICENSE |
| `https@1.0.0`（顶层） | `license: ISC`；`author: hardus van der berg <hardus@sunfork.com> (http://www.sunfork.com)` | `unblockmusic-utils@0.3.3` 声明依赖；归档只有 331 B `package.json`，没有 `index.js`；应用 `require('https')` 解析到 Node.js 内置核心模块，与此 npm 包不同 | `SPDX-ISC-REFERENCE.txt`：仅标准参考文本，非该版本原始 LICENSE |
| `https-proxy-agent@5.0.1`（顶层） | `license: MIT`；`author: Nathan Rajlich <nathan@tootallnate.net> (http://n8.io/)` | `axios@1.20.0` 的传递依赖；PAC 路径另有嵌套 `https-proxy-agent@7.0.6`，版本分开统计；5.0.1 发布归档与上游仓库中未见 LICENSE 文件或版权行 | `SPDX-MIT-REFERENCE.txt`：仅标准参考文本，非该版本原始 LICENSE |
| `cookie-signature@1.0.7`（`unblockmusic-utils` 下的嵌套路径） | `license: MIT`；`author: TJ Holowaychuk <tj@learnboost.com>` | 由嵌套 `express@4.22.2` 的 `~1.0.6` 依赖引入；1.0.7 发布分支与归档中未见 LICENSE 文件或版权行 | `SPDX-MIT-REFERENCE.txt`：仅标准参考文本，非 1.0.7 原始 LICENSE；1.0.7 的原始许可证文件未取得 |

**独立版本说明**：顶层 `cookie-signature@1.2.2` 是 Express 5 的另一条实际安装路径，不等同于上述嵌套 `1.0.7`。`cookie-signature-1.2.2-LICENSE` 是从实际安装的顶层 `cookie-signature@1.2.2` 包内原样提取的上游文件，仅对应 1.2.2，**不得用于证明或替代 1.0.7 的版本对应材料**。

- **生产依赖树的许可分布**：镜像内 `node_modules` 共 256 个 `package.json`，其中 **249 条为生产安装路径**（顶层 180 + 嵌套 69）：
  - **247 条为单一宽松许可**（MIT 218 / ISC 18 / BSD-2-Clause 5 / BSD-3-Clause 4 / BlueOak-1.0.0 1 / 0BSD 1）
  - **1 条为双许可** `(BSD-3-Clause OR GPL-2.0)`（`node-forge@1.4.0`，本项目依 BSD-3-Clause 选项使用）〔保守：披露所选许可〕
  - **1 条为 `LGPL-3.0-only`**（`@unblockneteasemusic/server@0.28.0`，见下）
  - 另有 **7 个辅助清单**（SDK / helpers / benchmarks 的 `package.json`，无 `license` 字段），不计入 249
  - 说明：`package-lock.json`（v3）不记录 `license` 字段，故许可分类以随包 `package.json` / `LICENSE` 为准，不能从 lockfile 推断。`busboy` / `streamsearch` 的 registry 元数据缺 `license` 字段，其随包 `LICENSE` 文件为 MIT。
- **@unblockneteasemusic/server 0.28.0**：**LGPL-3.0-only**（随包 `package.json` 声明；许可全文随包提供）。依赖链：内置 NCM API → `@neteasecloudmusicapienhanced/unblockmusic-utils` 0.3.3 → 本包。镜像内实际位置 `backend/vendor/ncm-api/node_modules/@unblockneteasemusic/server/`，以**未修改**形态分发（88 个文件，含 `src/` 全量可读 JavaScript；与上游 npm 产物逐字节一致），随包自带 `COPYING`（GPL-3.0 全文）与 `COPYING.LESSER`（LGPL-3.0）；许可全文亦随附于 `licenses/`（`UnblockNeteaseMusic-COPYING-GPL-3.0`、`UnblockNeteaseMusic-COPYING.LESSER-LGPL-3.0`）。〔法定：LGPL-3.0 分发组合作品须保留许可与声明、随附 GPL/LGPL 文本、提供库对应源码、允许用户修改并替换该库（未打包混淆、`node_modules` 形态可替换）〕
  - 运行状态〔保守·事实声明〕：Sonfly 从未传入 `unblock` 参数、从未调用 `/song/url/match`，且 `ENABLE_GENERAL_UNBLOCK` 未设置——该包在 Sonfly 的全部功能路径中默认不参与运行（Sonfly 不请求解灰能力）。此为事实声明，不改变分发相关义务。
- 完整逐包清单见公开发布的材料仓库中的 `SBOM.md`。

## 六、前端构建产物

- 运行时依赖（全部 MIT；锁定版本以 `frontend/package-lock.json` 为准）：

| 包 | 版本 | 版权主体 | 许可全文（同目录 `licenses/`） |
|---|---|---|---|
| react | 18.3.1 | Facebook, Inc. and its affiliates | `react-LICENSE` |
| react-dom | 18.3.1 | Facebook, Inc. and its affiliates | `react-LICENSE`（与 react 的 LICENSE 逐字节相同，共用一份） |
| react-router-dom | 6.30.4 | React Training LLC 2015-2019；Remix Software Inc. 2020-2021；Shopify Inc. 2022-2023 | `react-router-dom-LICENSE.md` |
| pinyin-pro | 3.28.2 | zh-lx（2022-present） | `pinyin-pro-LICENSE` |

- 前端以**构建产物**（静态 JS bundle）形态随镜像分发。上述 4 个依赖的 MIT 许可全文随镜像分发〔法定：MIT 要求在本软件的所有副本或实质部分中包含版权声明与许可声明〕；此外构建产物内亦保留了 `react` / `react-dom` / `react-router-dom` 的版权与许可标识注释（`@license React` / `@license MIT`）。
- 依赖关系说明：`react-router-dom` 的许可文本同时覆盖其依赖 `react-router` 6.30.4 与 `@remix-run/router` 1.23.3（三者 `LICENSE.md` 逐字节相同，且三者的版权标识注释均出现在构建产物内）。
- 字体说明〔保守〕：品牌字标与图标中的字形轮廓烘焙自 Google Sans Flex（SIL OFL 1.1，Copyright 2015 The Google Sans Flex Authors），依据 OFL 1.1 第 5 条「用字体创建的作品不受字体许可约束」；字体文件本身不随镜像分发。

## 七、基础镜像（Debian 13 trixie）

- 基础包（bash、coreutils、tar、curl、tzdata 等；FFmpeg 构建相关工具链全部位于被丢弃的构建阶段）各自许可已由 Debian 以 `/usr/share/doc/<pkg>/copyright` 随镜像保留〔法定义务由 Debian 履行，本文档引用〕。
- Node.js 运行时来自官方 `node:24-trixie-slim` 镜像（基座同为 Debian 13 trixie）：仅复制 `node` 可执行文件与 `LICENSE`，该镜像其余内容（npm、node 头文件、Debian 包清单）均不进入本镜像。
- 对应源码获取：`https://deb.debian.org/debian/` 及 `https://www.debian.org/sources`〔保守：声明指引〕。

## 八、声明文本（镜像内同目录一并提供）

> 本软件（Sonfly）使用 **FFmpeg 7.0.2**（GNU Lesser General Public License v2.1-or-later），其中静态链接了：
> - **LAME 3.100 / libmp3lame**（GNU Library General Public License v2-or-later；构建时已关闭其内置 mpglib 解码引擎）
> - **musl libc 1.2.5**（MIT License）
>
> 本软件内含的 **NCM API** 组件（`@neteasecloudmusicapienhanced/api` 4.36.1，MIT License）的依赖树中含 **UnblockNeteaseMusic**（`@unblockneteasemusic/server` 0.28.0，**GNU Lesser General Public License v3.0 only**）：该库以未修改的形态与其完整可读源码（JavaScript）随镜像分发（`backend/vendor/ncm-api/node_modules/@unblockneteasemusic/server/`），并自带 `COPYING`（GPL-3.0 全文）与 `COPYING.LESSER`（LGPL-3.0）；该库未打包、未混淆、运行时不校验完整性，用户可自由修改并替换（JavaScript 场景下「重新链接」即替换文件）。
>
> 上述 FFmpeg / LAME / musl 组件与 UnblockNeteaseMusic 均未修改；各许可全文见随附 `licenses/` 目录。对应源码、构建脚本与构建材料（含重新链接说明）可从以下渠道获取：
>
> · **来源渠道**：对应源码归档、构建脚本与构建材料、公钥、许可证文本与校验清单提供于公开材料仓库 `https://github.com/x1ao4/sonfly-third-party-notices`（随 Sonfly 正式发布同步开放）：
>   - `sources/`：FFmpeg / LAME / musl 上游源码归档与签名、签名公钥（`sources/keys/`）、UnblockNeteaseMusic 上游 npm 产物及来源记录
>   - `build/`：构建脚本 `build-ffmpeg-lgpl.sh`、构建工具链与配置记录、完整构建日志
>   - `licenses/`：各组件许可全文与来源说明（`licenses/README.txt`）
>   - `notices/THIRD-PARTY-NOTICES.md`：本文件；`SBOM.md`：逐包组件清单
>   - `SHA256SUMS`、`sources/SHA256SUMS`：文件校验清单；`RELINKING.md`：重新链接说明；`verify/`：产物参考哈希
>
> 〔法定：LGPL-2.1 §6 / LGPL-2.0 §6 / LGPL-3.0 §4「prominent notice」+ 许可副本 + 源码与构建材料获取方式〕
> Sonfly 自身代码以独立子进程方式调用该 FFmpeg 二进制、以 HTTP 调用内含的 NCM API 组件，均未与之链接；UnblockNeteaseMusic 在 Sonfly 的全部功能路径中默认不参与运行（Sonfly 不请求解灰能力），此为事实声明，不改变分发相关义务。本声明不影响上述组件各自许可证下的权利与义务。
