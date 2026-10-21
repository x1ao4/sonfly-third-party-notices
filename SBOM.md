# SBOM —— Sonfly 软件物料清单

- **对应发行物**：Sonfly 发行镜像（应用版本见仓库根 `VERSION`）。
- **数据来源**：
  - Python：`backend/requirements.lock`（pip-compile --generate-hashes 逐包哈希锁定）逐包解析；
  - Node.js：`backend/vendor/ncm-api/package-lock.json` 生产安装路径逐条解析 × **镜像内 `node_modules` 逐包 `package.json` 实测**；
  - 前端：`frontend/package-lock.json` 运行时依赖；
  - FFmpeg / LAME / musl / UnblockNeteaseMusic：见 [`notices/THIRD-PARTY-NOTICES.md`](notices/THIRD-PARTY-NOTICES.md)（§一~§三、§五）与 [`sources/`](sources/)（源码归档与哈希）。
- **统计口径**：Python 36 包（直接 13 + 传递 23，依 `requirements.lock` 的 `# via` 标注）；npm 生产安装路径 249 条（顶层 180 + 嵌套 69）；前端运行时依赖 4。`package-lock.json`（v3）不记录 license 字段，npm 许可分类**以镜像内随包 `package.json` / `LICENSE` 实测为准**（非 lockfile 推断）。
- **vendored 依赖偏离说明（Sonfly 本地修改）**：上游 `@neteasecloudmusicapienhanced/api@4.36.1` 在其 `package.json` 中声明了 `gzip@^0.1.0` 依赖，但该包为 0 字节空实现且整个依赖树无任何 `require('gzip')` 引用；Sonfly 已在本地修改中将其移除，并相应重生成 `package-lock.json`（见下文 §3.1 说明）。另于 2026-10-18 完成依赖安全升级（`axios` 1.20.0 / `express` 5.3.0 / `music-metadata` 11.16.1；`qs` 经 `overrides` 统一为 6.16.1），详见 NOTICES §五 与 `VENDOR-PATCHES` P-006。
- 本清单与 [`notices/THIRD-PARTY-NOTICES.md`](notices/THIRD-PARTY-NOTICES.md) 配套：NOTICES 给出许可分类与义务说明，本文件给出逐包明细。

## 一、发行物级组件汇总

| 组件 | 版本 | 许可 | 形态 |
|---|---|---|---|
| Sonfly 应用本体 | 1.0.0（应用版本，仓库 `VERSION`） | 专有（闭源） | 镜像内 Python 编译产物（仅 .pyc） |
| FFmpeg | 7.0.2 | LGPL-2.1-or-later | 静态构建二进制（含 LAME / musl，见 §二~§四） |
| LAME / libmp3lame | 3.100 | LGPL-2.0-or-later | 静态编入 ffmpeg（`--disable-decoder`，不含 mpglib） |
| musl libc | 1.2.5 | MIT | 静态编入 ffmpeg |
| Python | 3.12.15 | PSF-2.0 | python:3.12-slim（Debian trixie） |
| Node.js | 24.22.1 | MIT | 官方 node:24-trixie-slim 镜像（仅复制 node 二进制与 LICENSE） |
| NCM API（vendored） | @neteasecloudmusicapienhanced/api 4.36.1 | MIT | node_modules 可读源码（6 项本地修改 P-001～P-006，含日志脱敏与依赖安全升级，见 NOTICES §五） |
| @unblockneteasemusic/server | 0.28.0 | LGPL-3.0-only | 未修改源码随 node_modules 分发（许可全文随附；运行时未启用） |
| 基础镜像 | Debian 13 trixie | 各包许可随 `/usr/share/doc/<pkg>/copyright` 分发 | 系统包（义务由 Debian 履行） |

## 二、Python 运行时依赖（36 包）

| 包 | 版本 | 许可 | 类型 |
|---|---|---|---|
| `aiosqlite` | 0.20.0 | MIT | 直接 |
| `annotated-doc` | 0.0.5 | MIT | 传递 |
| `annotated-types` | 0.8.0 | MIT | 传递 |
| `anyio` | 4.15.1 | MIT | 传递 |
| `bcrypt` | 4.0.1 | Apache-2.0 OR BSD-3-Clause | 直接 |
| `certifi` | 2026.7.22 | MPL-2.0 | 传递 |
| `cffi` | 2.1.1 | MIT-0 | 传递 |
| `click` | 8.5.0 | BSD-3-Clause | 传递 |
| `cryptography` | 50.0.2 | Apache-2.0 OR BSD-3-Clause | 直接 |
| `fastapi` | 0.143.2 | MIT | 直接 |
| `greenlet` | 3.5.6 | MIT AND PSF-2.0 | 传递 |
| `h11` | 0.16.0 | MIT | 传递 |
| `httpcore` | 1.0.9 | BSD-3-Clause | 传递 |
| `httptools` | 0.9.0 | MIT | 传递 |
| `httpx` | 0.28.1 | BSD-3-Clause | 直接 |
| `idna` | 3.20 | BSD-3-Clause | 传递 |
| `opentelemetry-api` | 1.45.1 | Apache-2.0 | 传递 |
| `passlib[bcrypt]` | 1.7.4 | BSD-3-Clause | 直接 |
| `pillow` | 12.3.0 | MIT-CMU | 直接 |
| `pycparser` | 3.11 | BSD-3-Clause | 传递 |
| `pydantic` | 2.14.1 | MIT | 传递 |
| `pydantic-core` | 2.50.1 | MIT | 传递 |
| `pydantic-settings` | 2.7.0 | MIT | 直接 |
| `pyjwt` | 2.15.0 | MIT | 直接 |
| `pypinyin` | 0.53.0 | MIT | 直接 |
| `python-dotenv` | 1.2.4 | BSD-3-Clause | 传递 |
| `python-multipart` | 0.0.31 | Apache-2.0 OR BSD-3-Clause | 直接 |
| `pyyaml` | 6.0.3 | MIT | 传递 |
| `sqlalchemy` | 2.0.36 | MIT | 直接 |
| `starlette` | 1.8.0 | BSD-3-Clause | 传递 |
| `typing-extensions` | 4.16.0 | PSF-2.0 | 传递 |
| `typing-inspection` | 0.4.4 | MIT | 传递 |
| `uvicorn[standard]` | 0.34.0 | BSD-3-Clause | 直接 |
| `uvloop` | 0.23.0 | MIT | 传递 |
| `watchfiles` | 1.3.0 | MIT | 传递 |
| `websockets` | 17.2 | BSD-3-Clause | 传递 |

> 说明：`certifi` 附许可文本与上游源码指针（MPL-2.0 §3.1）；`opentelemetry-api` 许可全文随镜像（`licenses/opentelemetry-api-LICENSE-Apache-2.0`）；`opentelemetry-sdk`/exporter 为 fastapi 可选 extra，未随镜像分发。

## 三、Node.js 生产依赖树（249 条安装路径，vendored NCM API）

### 3.1 顶层（180 条）与嵌套（69 条）逐包清单

> **与上游的依赖差异（Sonfly 本地修改）**：上游 4.36.1 的 `package.json` 声明了 `gzip@^0.1.0`，但该包随归档提供的 `src/gzip.js` 与 `test/test.js` 均为 **0 字节空文件**，且整个依赖树（含全部 `node_modules`）不存在任何 `require('gzip')` 引用——Sonfly 已将其从依赖声明中移除并重生成 lockfile。本清单不含 `gzip`。

**六个 npm 包的许可材料说明**：下表包名与版本按实际锁定路径列入本清单。`license` 是各自 `package.json` 字段声明；这六个版本的发布归档与上游仓库中未见随包原始许可证全文或明确版权行。author 仅按字段记录，不据此推定版权人或年份。目录内 `SPDX-MIT-REFERENCE.txt` / `SPDX-ISC-REFERENCE.txt` 是标准参考文本，不是这些 npm 版本的原始 LICENSE，亦不补足其版权声明或授权依据。

| 目标依赖 | 随包声明及作者字段 | 依赖用途 / 许可材料状态 | 材料说明 |
|---|---|---|---|
| `@tokenizer/token@0.3.0`（顶层） | MIT；`author.name: Borewit`、`author.url: https://github.com/Borewit` | `music-metadata` / `strtok3` / `token-types` 依赖链；归档只有 `package.json`、README、`index.d.ts`，无 JS 运行时代码；无版本对应 LICENSE/版权行 | MIT 标准参考文本；非包内原始文件 |
| `agent-base@6.0.2`（顶层） | MIT；`Nathan Rajlich <nathan@tootallnate.net> (http://n8.io/)` | `https-proxy-agent@5.0.1` 声明 `agent-base: "6"`；其他代理路径的 `agent-base@7.1.4` 为独立条目；无版本对应 LICENSE/版权行 | MIT 标准参考文本；非包内原始文件 |
| `degenerator@5.0.1`（顶层） | MIT；`Nathan Rajlich <nathan@tootallnate.net> (http://n8.io/)` | `pac-resolver@7.0.1` 的 PAC 代理链；嵌套 `escodegen` 的 BSD 文件只对应 escodegen；无本包版本对应 LICENSE/版权行 | MIT 标准参考文本；非包内原始文件 |
| `https@1.0.0`（顶层） | ISC；`hardus van der berg <hardus@sunfork.com> (http://www.sunfork.com)` | `unblockmusic-utils@0.3.3` 声明；归档只有 331 B `package.json`，其 `main` 文件不存在；应用 `require('https')` 使用 Node 核心模块；无版本对应 ISC 文本/版权行 | ISC 标准参考文本；非包内原始文件 |
| `https-proxy-agent@5.0.1`（顶层） | MIT；`Nathan Rajlich <nathan@tootallnate.net> (http://n8.io/)` | Axios 依赖路径；PAC 代理另有 `https-proxy-agent@7.0.6`；无 5.0.1 对应 LICENSE/版权行 | MIT 标准参考文本；非包内原始文件 |
| `cookie-signature@1.0.7`（嵌套） | MIT；`TJ Holowaychuk <tj@learnboost.com>` | 嵌套 Express 4.22.2 声明 `~1.0.6`；1.0.7 发布分支与归档中未见 LICENSE 文件或版权行 | MIT 标准参考文本；非包内原始文件 |

**独立路径**：本清单另含顶层 `cookie-signature@1.2.2`（Express 5 路径）。随包原始 `LICENSE` 单独收录为 `licenses/cookie-signature-1.2.2-LICENSE`，仅对应 1.2.2，不能用于嵌套 `1.0.7`。该文件与 `SPDX-*REFERENCE.txt` 的材料类别不同。

| 包@版本 | 许可 | 安装层级 |
|---|---|---|
| `@borewit/text-codec@0.2.2` | MIT | 顶层 |
| `@neteasecloudmusicapienhanced/unblockmusic-utils@0.3.3` | MIT | 顶层 |
| `accepts@1.3.8` | MIT | 嵌套 |
| `body-parser@1.20.8` | MIT | 嵌套 |
| `content-disposition@0.5.4` | MIT | 嵌套 |
| `cookie-signature@1.0.7` | MIT（package.json 元数据声明；上游版本对应许可证材料缺失，见上文六个包说明） | 嵌套 |
| `debug@2.6.9` | MIT | 嵌套 |
| `ms@2.0.0` | MIT | 嵌套 |
| `express@4.22.2` | MIT | 嵌套 |
| `finalhandler@1.3.2` | MIT | 嵌套 |
| `fresh@0.5.2` | MIT | 嵌套 |
| `iconv-lite@0.4.24` | MIT | 嵌套 |
| `media-typer@0.3.0` | MIT | 嵌套 |
| `merge-descriptors@1.0.3` | MIT | 嵌套 |
| `mime-db@1.52.0` | MIT | 嵌套 |
| `mime-types@2.1.35` | MIT | 嵌套 |
| `negotiator@0.6.3` | MIT | 嵌套 |
| `path-to-regexp@0.1.13` | MIT | 嵌套 |
| `raw-body@2.5.3` | MIT | 嵌套 |
| `send@0.19.2` | MIT | 嵌套 |
| `serve-static@1.16.3` | MIT | 嵌套 |
| `type-is@1.6.18` | MIT | 嵌套 |
| `@tokenizer/inflate@0.4.1` | MIT | 顶层 |
| `@tokenizer/token@0.3.0` | MIT | 顶层 |
| `@tootallnate/quickjs-emscripten@0.23.0` | MIT | 顶层 |
| `@unblockneteasemusic/server@0.28.0` | LGPL-3.0-only | 顶层 |
| `accepts@2.0.0` | MIT | 顶层 |
| `agent-base@6.0.2` | MIT | 顶层 |
| `ansi-regex@6.2.2` | MIT | 顶层 |
| `ansi-styles@4.3.0` | MIT | 顶层 |
| `args@5.0.3` | MIT | 顶层 |
| `ansi-styles@3.2.1` | MIT | 嵌套 |
| `chalk@2.4.2` | MIT | 嵌套 |
| `color-convert@1.9.3` | MIT | 嵌套 |
| `color-name@1.1.3` | MIT | 嵌套 |
| `escape-string-regexp@1.0.5` | MIT | 嵌套 |
| `has-flag@3.0.0` | MIT | 嵌套 |
| `supports-color@5.5.0` | MIT | 嵌套 |
| `array-flatten@1.1.1` | MIT | 顶层 |
| `ast-types@0.13.4` | MIT | 顶层 |
| `asynckit@0.4.0` | MIT | 顶层 |
| `atomic-sleep@1.0.0` | MIT | 顶层 |
| `axios@1.20.0` | MIT | 顶层 |
| `basic-ftp@5.3.1` | MIT | 顶层 |
| `body-parser@2.3.0` | MIT | 顶层 |
| `content-type@2.0.0` | MIT | 嵌套 |
| `busboy@1.6.0` | MIT（随包 LICENSE 实测；package.json 无 license 字段） | 顶层 |
| `bytes@3.1.2` | MIT | 顶层 |
| `call-bind-apply-helpers@1.0.2` | MIT | 顶层 |
| `call-bound@1.0.4` | MIT | 顶层 |
| `camelcase@5.0.0` | MIT | 顶层 |
| `cliui@9.0.1` | ISC | 顶层 |
| `emoji-regex@10.6.0` | MIT | 嵌套 |
| `string-width@7.2.0` | MIT | 嵌套 |
| `color-convert@2.0.1` | MIT | 顶层 |
| `color-name@1.1.4` | MIT | 顶层 |
| `colorette@2.0.20` | MIT | 顶层 |
| `combined-stream@1.0.8` | MIT | 顶层 |
| `content-disposition@2.0.1` | MIT | 顶层 |
| `content-type@1.0.5` | MIT | 顶层 |
| `cookie@0.7.2` | MIT | 顶层 |
| `cookie-signature@1.2.2` | MIT | 顶层 |
| `crypto-js@4.2.0` | MIT | 顶层 |
| `data-uri-to-buffer@6.0.2` | MIT | 顶层 |
| `dateformat@4.6.3` | MIT | 顶层 |
| `debug@4.4.3` | MIT | 顶层 |
| `degenerator@5.0.1` | MIT | 顶层 |
| `escodegen@2.1.0` | BSD-2-Clause | 嵌套 |
| `delayed-stream@1.0.0` | MIT | 顶层 |
| `depd@2.0.0` | MIT | 顶层 |
| `destroy@1.2.0` | MIT | 顶层 |
| `dijkstrajs@1.0.3` | MIT | 顶层 |
| `dotenv@17.4.2` | BSD-2-Clause | 顶层 |
| `dunder-proto@1.0.1` | MIT | 顶层 |
| `duplexify@4.1.3` | MIT | 顶层 |
| `ee-first@1.1.1` | MIT | 顶层 |
| `emoji-regex@8.0.0` | MIT | 顶层 |
| `encodeurl@2.0.0` | MIT | 顶层 |
| `end-of-stream@1.4.5` | MIT | 顶层 |
| `es-define-property@1.0.1` | MIT | 顶层 |
| `es-errors@1.3.0` | MIT | 顶层 |
| `es-object-atoms@1.1.2` | MIT | 顶层 |
| `es-set-tostringtag@2.1.0` | MIT | 顶层 |
| `escalade@3.2.0` | MIT | 顶层 |
| `escape-html@1.0.3` | MIT | 顶层 |
| `esprima@4.0.1` | BSD-2-Clause | 顶层 |
| `estraverse@5.3.0` | BSD-2-Clause | 顶层 |
| `esutils@2.0.3` | BSD-2-Clause | 顶层 |
| `etag@1.8.1` | MIT | 顶层 |
| `express@5.3.0` | MIT | 顶层 |
| `content-type@2.1.0` | MIT | 嵌套 |
| `express-fileupload@1.5.2` | MIT | 顶层 |
| `fast-redact@3.5.0` | MIT | 顶层 |
| `fast-safe-stringify@2.1.1` | MIT | 顶层 |
| `file-type@21.3.4` | MIT | 顶层 |
| `finalhandler@2.1.1` | MIT | 顶层 |
| `flatstr@1.0.12` | MIT | 顶层 |
| `follow-redirects@1.16.0` | MIT | 顶层 |
| `form-data@4.0.6` | MIT | 顶层 |
| `mime-db@1.52.0` | MIT | 嵌套 |
| `mime-types@2.1.35` | MIT | 嵌套 |
| `forwarded@0.2.0` | MIT | 顶层 |
| `fresh@2.0.0` | MIT | 顶层 |
| `function-bind@1.1.2` | MIT | 顶层 |
| `get-caller-file@2.0.5` | ISC | 顶层 |
| `get-east-asian-width@1.6.0` | MIT | 顶层 |
| `get-intrinsic@1.3.0` | MIT | 顶层 |
| `get-proto@1.0.1` | MIT | 顶层 |
| `get-uri@6.0.5` | MIT | 顶层 |
| `gopd@1.2.0` | MIT | 顶层 |
| `has-symbols@1.1.0` | MIT | 顶层 |
| `has-tostringtag@1.0.2` | MIT | 顶层 |
| `hasown@2.0.4` | MIT | 顶层 |
| `http-errors@2.0.1` | MIT | 顶层 |
| `http-proxy-agent@7.0.2` | MIT | 顶层 |
| `agent-base@7.1.4` | MIT | 嵌套 |
| `https@1.0.0` | ISC | 顶层 |
| `https-proxy-agent@5.0.1` | MIT | 顶层 |
| `iconv-lite@0.7.2` | MIT | 顶层 |
| `ieee754@1.2.1` | BSD-3-Clause | 顶层 |
| `inherits@2.0.4` | ISC | 顶层 |
| `ip-address@10.7.4` | MIT | 顶层 |
| `ipaddr.js@1.9.1` | MIT | 顶层 |
| `is-promise@4.0.0` | MIT | 顶层 |
| `joycon@3.1.1` | MIT | 顶层 |
| `leven@2.1.0` | MIT | 顶层 |
| `math-intrinsics@1.1.0` | MIT | 顶层 |
| `media-typer@2.0.0` | MIT | 顶层 |
| `merge-descriptors@2.0.0` | MIT | 顶层 |
| `methods@1.1.2` | MIT | 顶层 |
| `mime@1.6.0` | MIT | 顶层 |
| `mime-db@1.54.0` | MIT | 顶层 |
| `mime-types@3.0.2` | MIT | 顶层 |
| `mri@1.1.4` | MIT | 顶层 |
| `ms@2.1.3` | MIT | 顶层 |
| `music-metadata@11.16.1` | MIT | 顶层 |
| `content-type@2.1.0` | MIT | 嵌套 |
| `negotiator@1.0.0` | MIT | 顶层 |
| `netmask@2.1.1` | MIT | 顶层 |
| `node-forge@1.4.0` | (BSD-3-Clause OR GPL-2.0) | 顶层 |
| `node-windows@1.0.0-beta.8` | MIT | 顶层 |
| `ansi-regex@5.0.1` | MIT | 嵌套 |
| `cliui@8.0.1` | ISC | 嵌套 |
| `is-fullwidth-code-point@3.0.0` | MIT | 嵌套 |
| `string-width@4.2.3` | MIT | 嵌套 |
| `strip-ansi@6.0.1` | MIT | 嵌套 |
| `wrap-ansi@7.0.0` | MIT | 嵌套 |
| `yargs@17.7.3` | MIT | 嵌套 |
| `object-inspect@1.13.4` | MIT | 顶层 |
| `on-exit-leak-free@0.2.0` | MIT | 顶层 |
| `on-finished@2.4.1` | MIT | 顶层 |
| `once@1.4.0` | ISC | 顶层 |
| `p-try@2.2.0` | MIT | 顶层 |
| `pac-proxy-agent@7.2.0` | MIT | 顶层 |
| `agent-base@7.1.4` | MIT | 嵌套 |
| `https-proxy-agent@7.0.6` | MIT | 嵌套 |
| `pac-resolver@7.0.1` | MIT | 顶层 |
| `parseurl@1.3.3` | MIT | 顶层 |
| `path-exists@4.0.0` | MIT | 顶层 |
| `path-to-regexp@8.4.2` | MIT | 顶层 |
| `pino@6.14.0` | MIT | 顶层 |
| `pino-abstract-transport@0.5.0` | MIT | 顶层 |
| `pino-pretty@7.6.1` | MIT | 顶层 |
| `sonic-boom@2.8.0` | MIT | 嵌套 |
| `pino-std-serializers@3.2.0` | MIT | 顶层 |
| `pngjs@5.0.0` | MIT | 顶层 |
| `process-warning@1.0.0` | MIT | 顶层 |
| `proxy-addr@2.0.8` | MIT | 顶层 |
| `proxy-from-env@2.1.0` | MIT | 顶层 |
| `pump@3.0.4` | MIT | 顶层 |
| `qrcode@1.5.4` | MIT | 顶层 |
| `ansi-regex@5.0.1` | MIT | 嵌套 |
| `cliui@6.0.0` | ISC | 嵌套 |
| `decamelize@1.2.0` | MIT | 嵌套 |
| `find-up@4.1.0` | MIT | 嵌套 |
| `is-fullwidth-code-point@3.0.0` | MIT | 嵌套 |
| `locate-path@5.0.0` | MIT | 嵌套 |
| `p-limit@2.3.0` | MIT | 嵌套 |
| `p-locate@4.1.0` | MIT | 嵌套 |
| `string-width@4.2.3` | MIT | 嵌套 |
| `strip-ansi@6.0.1` | MIT | 嵌套 |
| `wrap-ansi@6.2.0` | MIT | 嵌套 |
| `y18n@4.0.3` | ISC | 嵌套 |
| `yargs@15.4.1` | MIT | 嵌套 |
| `yargs-parser@18.1.3` | ISC | 嵌套 |
| `qs@6.16.1` | BSD-3-Clause | 顶层 |
| `quick-format-unescaped@4.0.4` | MIT | 顶层 |
| `range-parser@1.2.1` | MIT | 顶层 |
| `raw-body@3.0.2` | MIT | 顶层 |
| `readable-stream@3.6.2` | MIT | 顶层 |
| `require-directory@2.1.1` | MIT | 顶层 |
| `require-main-filename@2.0.0` | ISC | 顶层 |
| `rfdc@1.4.1` | MIT | 顶层 |
| `router@2.2.0` | MIT | 顶层 |
| `safe-buffer@5.2.1` | MIT | 顶层 |
| `safe-decode-uri-component@1.2.1` | MIT | 顶层 |
| `safer-buffer@2.1.2` | MIT | 顶层 |
| `sax@1.6.0` | BlueOak-1.0.0 | 顶层 |
| `secure-json-parse@2.7.0` | BSD-3-Clause | 顶层 |
| `send@1.2.1` | MIT | 顶层 |
| `serve-static@2.2.1` | MIT | 顶层 |
| `set-blocking@2.0.0` | ISC | 顶层 |
| `setprototypeof@1.2.0` | ISC | 顶层 |
| `side-channel@1.1.1` | MIT | 顶层 |
| `side-channel-list@1.0.1` | MIT | 顶层 |
| `side-channel-map@1.0.1` | MIT | 顶层 |
| `side-channel-weakmap@1.0.2` | MIT | 顶层 |
| `smart-buffer@4.2.0` | MIT | 顶层 |
| `socks@2.8.10` | MIT | 顶层 |
| `socks-proxy-agent@8.0.5` | MIT | 顶层 |
| `agent-base@7.1.4` | MIT | 嵌套 |
| `sonic-boom@1.4.1` | MIT | 顶层 |
| `source-map@0.6.1` | BSD-3-Clause | 顶层 |
| `split2@4.2.0` | ISC | 顶层 |
| `statuses@2.0.2` | MIT | 顶层 |
| `stream-shift@1.0.3` | MIT | 顶层 |
| `streamsearch@1.1.0` | MIT（随包 LICENSE 实测；package.json 无 license 字段） | 顶层 |
| `string_decoder@1.3.0` | MIT | 顶层 |
| `strip-ansi@7.2.0` | MIT | 顶层 |
| `strip-json-comments@3.1.1` | MIT | 顶层 |
| `strtok3@10.3.5` | MIT | 顶层 |
| `toidentifier@1.0.1` | MIT | 顶层 |
| `token-types@6.1.2` | MIT | 顶层 |
| `tslib@2.8.1` | 0BSD | 顶层 |
| `tunnel@0.0.6` | MIT | 顶层 |
| `type-is@2.1.0` | MIT | 顶层 |
| `content-type@2.0.0` | MIT | 嵌套 |
| `media-typer@1.1.0` | MIT | 嵌套 |
| `uint8array-extras@1.5.0` | MIT | 顶层 |
| `unpipe@1.0.0` | MIT | 顶层 |
| `util-deprecate@1.0.2` | MIT | 顶层 |
| `utils-merge@1.0.1` | MIT | 顶层 |
| `vary@1.1.2` | MIT | 顶层 |
| `which-module@2.0.1` | ISC | 顶层 |
| `win-guid@0.2.1` | MIT | 顶层 |
| `wrap-ansi@9.0.2` | MIT | 顶层 |
| `ansi-styles@6.2.3` | MIT | 嵌套 |
| `emoji-regex@10.6.0` | MIT | 嵌套 |
| `string-width@7.2.0` | MIT | 嵌套 |
| `wrappy@1.0.2` | ISC | 顶层 |
| `xml@1.0.1` | MIT | 顶层 |
| `xml2js@0.6.2` | MIT | 顶层 |
| `xmlbuilder@11.0.1` | MIT | 顶层 |
| `y18n@5.0.8` | ISC | 顶层 |
| `yargs@18.0.0` | MIT | 顶层 |
| `yargs-parser@21.1.1` | ISC | 顶层 |
| `emoji-regex@10.6.0` | MIT | 嵌套 |
| `string-width@7.2.0` | MIT | 嵌套 |
| `yargs-parser@22.0.0` | ISC | 嵌套 |

### 3.2 许可分布汇总（与 NOTICES §五 一致）

| 许可 | 条数 | 备注 |
|---|---|---|
| MIT | 218 | 216 条随包 `package.json` 实测 + busboy / streamsearch 2 条随包 `LICENSE` 实测（package.json 无 license 字段） |
| ISC | 18 | |
| BSD-2-Clause | 5 | |
| BSD-3-Clause | 4 | |
| BSD-3-Clause OR GPL-2.0 | 1 | node-forge@1.4.0——本项目依 BSD-3-Clause 选项使用 |
| LGPL-3.0-only | 1 | @unblockneteasemusic/server@0.28.0（许可全文随镜像与材料仓库；运行时未启用） |
| BlueOak-1.0.0 | 1 | |
| 0BSD | 1 | |
| **合计** | **249** | 另有 7 个无 license 字段的辅助清单（SDK/helpers/benchmarks）不计入 |

## 四、前端构建产物运行时依赖（4）

| 包@版本 | 许可 | 版权主体 | 许可全文 |
|---|---|---|---|
| `react@18.3.1` | MIT | Facebook, Inc. and its affiliates | [`licenses/react-LICENSE`](licenses/react-LICENSE) |
| `react-dom@18.3.1` | MIT | Facebook, Inc. and its affiliates | [`licenses/react-LICENSE`](licenses/react-LICENSE)（与 react 的 LICENSE 逐字节相同，共用一份） |
| `react-router-dom@6.30.4` | MIT | React Training LLC 2015-2019；Remix Software Inc. 2020-2021；Shopify Inc. 2022-2023 | [`licenses/react-router-dom-LICENSE.md`](licenses/react-router-dom-LICENSE.md) |
| `pinyin-pro@3.28.2` | MIT | zh-lx（2022-present） | [`licenses/pinyin-pro-LICENSE`](licenses/pinyin-pro-LICENSE) |

> 前端以**构建产物**（静态 JS bundle）形态随镜像分发；上述 4 个依赖的 MIT 许可全文随镜像分发（`licenses/`）。`react-router-dom` 的许可文本亦覆盖其依赖 `react-router@6.30.4` 与 `@remix-run/router@1.23.3`（三者 `LICENSE.md` 逐字节相同）。字形轮廓烘焙自 Google Sans Flex（SIL OFL 1.1，见 [`licenses/OFL.txt`](licenses/OFL.txt)），字体文件本身不随镜像分发（OFL 1.1 §5：用字体创建的作品不受字体许可约束）。

## 五、校验与一致性

- Python：镜像内 `pip freeze` × `requirements.lock` 双向零差异；每包哈希见 lock 文件。
- npm：本清单 249 条 = `package-lock.json` 生产路径 249 条 = 镜像内 257 个 `package.json` 全量扫描口径（1 根 + 249 生产 + 7 辅助）。
- 源码级组件（FFmpeg / LAME / musl / unm）哈希见 [`sources/SHA256SUMS`](sources/SHA256SUMS)；产物参考哈希见 [`verify/product-sha256.txt`](verify/product-sha256.txt)。

---
*数据来源与统计口径如上，可由依赖锁文件与镜像实测复现。*
