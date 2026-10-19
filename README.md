# Sonfly Third-Party Notices

本仓库是 **Sonfly 的第三方分发合规材料仓库**：存放 Sonfly 发行物（Docker 镜像）中所使用的第三方开源组件的**对应源码、许可证全文、构建材料、校验清单与重新链接说明**。

> 本仓库**不包含**任何 Sonfly 业务源码、密钥、用户数据或其他不应公开的内容。Sonfly 自有代码以独立子进程方式调用相关组件，未与之链接。

## 涉及组件与发行物

| 组件 | 版本 | 许可 | 与本发行物的关系 |
|---|---|---|---|
| FFmpeg | 7.0.2 | LGPL-2.1-or-later | 镜像内 `/usr/local/bin/ffmpeg`（从上游源码自行构建的 LGPL 静态构建） |
| LAME / libmp3lame | 3.100 | LGPL-2.0-or-later | **静态编入**上述 ffmpeg 二进制 |
| musl libc | 1.2.5 | MIT | **静态编入**上述 ffmpeg 二进制 |
| UnblockNeteaseMusic | 0.28.0 | LGPL-3.0-only | 镜像内 NCM API 组件（内置）的依赖树成员；以未修改形态与完整可读源码随镜像分发 |

- 发行物中该 ffmpeg 二进制的 SHA256（**按目标架构**；两个架构使用同一源码、同一 configure 参数、同一工具链版本）：
  - `linux/amd64`：`7e58a04d102ee638ae7d5e282b29e1a934baee13ce4655496113a3019f1441d5`（23,493,032 字节）
  - `linux/arm64`：`1fae8f6f82ea46fdaff94e8710476eaeabfc2136df06b8ce98250aaa3008801d`（19,733,736 字节）
- 产物参考哈希与文件大小：见 [`verify/product-sha256.txt`](verify/product-sha256.txt)
- 上述组件的完整声明（含镜像内其他第三方组件）：见 [`notices/THIRD-PARTY-NOTICES.md`](notices/THIRD-PARTY-NOTICES.md)
- 前端构建产物所含 4 个运行时依赖（`react` / `react-dom` / `react-router-dom` / `pinyin-pro`）的 MIT 许可全文亦收录于 [`licenses/`](licenses/)，详见 [`notices/THIRD-PARTY-NOTICES.md`](notices/THIRD-PARTY-NOTICES.md) §六
- 逐包组件明细（Python 36 包 / npm 249 条 / 前端 4 依赖）：见 [`SBOM.md`](SBOM.md)

## 目录结构

```
sources/    上游源码归档（FFmpeg / LAME / musl / UnblockNeteaseMusic，含可用的签名与完整性记录）+ SHA256SUMS
licenses/   各组件许可全文（LGPL-2.1 / LGPL-2.0 / LGPL-3.0 / GPL-3.0 / Apache-2.0 / MIT / OFL-1.1）与来源说明（README.txt）；其中 OFL-1.1 为品牌字标字形所依据字体，仅本仓库收录，字体文件不随镜像分发
build/      构建脚本（build-ffmpeg-lgpl.sh）、工具链记录（amd64 / arm64 各一套）、构建配置（-buildconf）、完整构建日志
notices/    THIRD-PARTY-NOTICES（随镜像分发版本的仓库副本）
SBOM.md     逐包组件物料清单（Python / npm / 前端运行时依赖，与镜像实测口径一致）
verify/     产物参考哈希与校验清单
RELINKING.md  重新链接说明（LGPL §6 相关义务的履行方式）
SHA256SUMS    本仓库全部文件的校验清单
```

## 快速校验

```sh
# 校验本仓库全部文件（在仓库根目录执行）
shasum -a 256 -c SHA256SUMS        # macOS
sha256sum -c SHA256SUMS            # Linux

# 校验源码归档
cd sources && shasum -a 256 -c SHA256SUMS
```

## 如何构建 / 如何修改并重新链接

见 [`RELINKING.md`](RELINKING.md)。其中包含：

1. Sonfly 构建该二进制所使用的脚本与调用方式；
2. 使用本仓库源码归档的**逐条手动构建命令**（离线可用）；
3. 构建**修改过的库**并重新链接的说明（LGPL 授予的权利）；
4. 产物对照与验证方法。

## 关于本仓库内容的权利与许可

本仓库包含**第三方材料**与 **Sonfly 自有内容**，二者适用的权利规则不同，请分别对待。Sonfly 自有内容又分为「Sonfly 本体源码与业务实现」、「Sonfly 自行撰写的说明与记录」和「合规辅助脚本」三类，授权边界各不相同。

### 一、第三方材料

- `sources/` 中的源码归档与签名文件、`licenses/` 中的许可证全文，以及各说明文件中引述的第三方许可与版权信息，均为**第三方材料**，依各自适用的许可证授权（见各文件与 `licenses/`）。
- Sonfly 对自有内容的任何权利主张**不限制、也不取代**上述第三方许可证已经授予的权利；本仓库亦不因该权利主张而省略任何必要的许可证文本、版权声明或其他履约材料。
- 获取、使用、修改与再分发第三方材料时，请遵循对应许可证的条款。

### 二、Sonfly 本体源码与业务实现

- Sonfly 应用本体为闭源软件。本仓库**不包含** Sonfly 本体源码或业务实现；公开本仓库**不授予**对它们的复制、修改、再分发或其他任何许可。
- 本节所述的权利保留**不排除**适用法律（包括著作权法及相关法规）对特定使用情形已作规定的情形；此类情形依法律规定处理，无需由本声明另行授权或禁止。

### 三、Sonfly 自行撰写的说明与记录

- 除上述第三方材料外，本仓库中由 Sonfly 撰写的说明文档、物料清单与记录（如本文件、`RELINKING.md`、`SBOM.md`、`notices/THIRD-PARTY-NOTICES.md` 中由 Sonfly 撰写的说明、`licenses/README.txt` 中的来源说明、`build/` 中的构建记录、`verify/`、`SHA256SUMS`、`sources/SHA256SUMS` 与 `sources/…provenance.txt` 等）的**原创表达**（措辞、结构、编排与说明性论述）的著作权及其他相关权利由 Sonfly 保留；未经 Sonfly 明确授权，不授予额外的复制、修改和再分发许可（适用法律另有规定的情形除外）。
- **边界说明**：`licenses/` 目录下的各**第三方许可证全文**、各**第三方版权声明**及其他**第三方原始材料**，仍属第一小节所述的第三方材料，按各自适用的许可证处理；本节权利保留**不延及**这些文件的内容，亦不对其中任何第三方材料主张 Sonfly 的自有版权。
- Sonfly 就上述文件中**引述、整理或编排**的第三方信息所保留的权利，仅及于 Sonfly 自行撰写的说明、注释与编排方式本身；被引述的第三方信息，其权利归属与授权状态不受影响。
- 上述文件中记载的**单纯事实信息**（版本号、哈希值、许可标识、包名、构建环境与工具链版本等）**通常不因其作为事实而受著作权保护**；对此类信息的记录与引用，一般不属于本节权利保留所限制的范围。
- 本节权利保留**不改变**本仓库作为第三方许可证履约材料渠道的用途。

### 四、合规辅助脚本

- `build/build-ffmpeg-lgpl.sh` 是 Sonfly 为构建发行镜像内 FFmpeg / LAME 而提供的构建脚本。
- 就**该脚本文件本身**，Sonfly 授予以下**有限许可**：允许任何获得本仓库材料的人，为**重新构建、修改 FFmpeg / libmp3lame 并重新链接**之目的，**复制、使用、修改与再分发**该脚本（含其参考哈希比对逻辑，或以 `RELINKING.md` §4 的手动命令替代该校验）。
- 上述**再分发包含下游场景**：为使下游接收者能够行使相关 LGPL 权利（重新构建、修改并重新链接），可随**修改后的 FFmpeg / libmp3lame 产物**一并再分发该脚本。
- 该许可**仅及于上述脚本文件**：不构成对 Sonfly 本体源码、业务实现或本仓库其他未授权内容的许可，也不构成对脚本之外任何用途的授权；同时**不限制、不取代**第三方许可证（含 LGPL）已经授予的任何权利，亦不妨碍接收者行使该等权利。
- 设置该脚本与上述许可的目的，是使接收者能够实际行使 GNU LGPL 就 FFmpeg / libmp3lame 所授予的修改与重新链接权利；本仓库的供应链校验与参考哈希**不应成为妨碍接收者行使该等权利的障碍**。
