**中文** | [上游源代码](https://github.com/P3TERX/Actions-OpenWrt)

<div align="center">
<h1>Actions-OpenWrt(多设备固件云编译)</h1>

[![LICENSE](https://img.shields.io/github/license/mashape/apistatus.svg?style=flat-square&label=LICENSE)](https://github.com/fichenx/OpenWrt/blob/main/LICENSE)
![GitHub Stars](https://img.shields.io/github/stars/fichenx/OpenWrt.svg?style=flat-square&label=Stars&logo=github)
![GitHub Forks](https://img.shields.io/github/forks/fichenx/OpenWrt.svg?style=flat-square&label=Forks&logo=github)
![GitHub download](https://img.shields.io/github/downloads/fichenx/OpenWrt/total.svg?style=flat-square&label=Download&logo=github)
</div>

## 项目说明 [![](https://img.shields.io/badge/-项目基本介绍-FFFFFF.svg)](#项目说明-)
- 固件来源：[![Lean](https://img.shields.io/badge/Lede-Lean-ff69b4.svg?style=flat&logo=appveyor)](https://github.com/coolsnowwolf/lede)[![immortalwrt](https://img.shields.io/badge/immortalwrt-immortalwrt-ff69b4.svg?style=flat&logo=appveyor)](https://github.com/immortalwrt/immortalwrt) [![P3TERX](https://img.shields.io/badge/OpenWrt-P3TERX-blueviolet.svg?style=flat&logo=appveyor)](https://github.com/P3TERX/Actions-OpenWrt) [![Flippy](https://img.shields.io/badge/Package-Flippy-orange.svg?style=flat&logo=appveyor)](https://github.com/unifreq/openwrt_packit)  [![breakings](https://img.shields.io/badge/OpenWrt-breakings-orange.svg?style=flat&logo=appveyor)](https://github.com/breakings/OpenWrt)
- 项目使用 Github Actions 拉取 [Lean](https://github.com/coolsnowwolf/lede) 和[immortalwrt](https://github.com/immortalwrt/immortalwrt) 的 Openwrt 源码仓库进行云编译
- 提供适配于NEWIFI D2、Redmi AX6、 ARMv8 电视盒子（斐讯N1、Tanix-TX3）的 OpenWrt 固件
- Redmi AX6固件分为 原厂分区版和合并分区版，合并分区版固件较大，使用前需对Redmi AX6进行合并分区；**因lede源码无线驱动问题，Redmi AX6（lede固件）暂时维持源码版本在20230501。**
- 固件集成的所有 ipk 插件全部打包在 Packages 文件中，可以在 [Releases](https://github.com/fichenx/Actions-OpenWrt/releases) 内进行下载

## 固件下载 [![](https://img.shields.io/badge/-编译状态及下载链接-FFFFFF.svg)](#固件下载-)
点击下表中 [![](https://img.shields.io/badge/下载-链接-blueviolet.svg?style=flat&logo=hack-the-box)](https://github.com/fichenx/Actions-OpenWrt/releases) 即可跳转到该设备固件下载页面
| 平台+设备名称 | 固件编译状态 | 配置文件 | 固件下载 |
| :-------------: | :-------------: | :-------------: | :-------------: |
| [![](https://img.shields.io/badge/NEWIFI-D2-32C955.svg?logo=openwrt)](https://github.com/fichenx/Actions-OpenWrt/blob/main/.github/workflows/Build_OpenWrt_Newifi-D2.yml) | [![](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Build_OpenWrt_Newifi-D2.yml/badge.svg)](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Build_OpenWrt_Newifi-D2.yml) | [![](https://img.shields.io/badge/编译-配置-orange.svg?logo=apache-spark)](https://github.com/fichenx/Actions-OpenWrt/blob/main/config/Newifi_D2.config) | [![](https://img.shields.io/badge/下载-链接-blueviolet.svg?logo=hack-the-box)](https://github.com/fichenx/Actions-OpenWrt/releases?q=Newifi_D2&expanded=true) |
| [![](https://img.shields.io/badge/Redmi-AX6(lede)-32C955.svg?logo=openwrt)](https://github.com/fichenx/Actions-OpenWrt/blob/main/.github/workflows/Build_OpenWrt_Redmi-AX6.yml) | [![](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Build_OpenWrt_Redmi-AX6.yml/badge.svg)](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Build_OpenWrt_Redmi-AX6.yml) | [![](https://img.shields.io/badge/编译-配置-orange.svg?logo=apache-spark)](https://github.com/fichenx/Actions-OpenWrt/blob/main/config/AX6.config) | [![](https://img.shields.io/badge/下载-链接-blueviolet.svg?logo=hack-the-box)](https://github.com/fichenx/Actions-OpenWrt/releases?q=Redmi-AX6%28原厂分区%29+lede&expanded=true) |
| [![](https://img.shields.io/badge/Redmi-AX6(lede_plus)-32C955.svg?logo=openwrt)](https://github.com/fichenx/Actions-OpenWrt/blob/main/.github/workflows/Build_OpenWrt_Redmi-AX6_plus.yml) | [![](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Build_OpenWrt_Redmi-AX6_plus.yml/badge.svg)](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Build_OpenWrt_Redmi-AX6_plus.yml) | [![](https://img.shields.io/badge/编译-配置-orange.svg?logo=apache-spark)](https://github.com/fichenx/Actions-OpenWrt/blob/main/config/AX6_plus.config) | [![](https://img.shields.io/badge/下载-链接-blueviolet.svg?logo=hack-the-box)](https://github.com/fichenx/Actions-OpenWrt/releases?q=Redmi-AX6%28%E5%90%88%E5%B9%B6%E5%88%86%E5%8C%BA%29+lede&expanded=true) |
| [![](https://img.shields.io/badge/Redmi-AX6(immortalwrt_plus)-32C955.svg?logo=openwrt)](https://github.com/fichenx/Actions-OpenWrt/blob/main/.github/workflows/Build_immortalwrt_Redmi-AX6.yml) | [![](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Build_immortalwrt_Redmi-AX6.yml/badge.svg)](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Build_immortalwrt_Redmi-AX6.yml) | [![](https://img.shields.io/badge/编译-配置-orange.svg?logo=apache-spark)](https://github.com/fichenx/Actions-OpenWrt/blob/main/config/AX6_5.15(ImmortalWrt).config) | [![](https://img.shields.io/badge/下载-链接-blueviolet.svg?logo=hack-the-box)](https://github.com/fichenx/Actions-OpenWrt/releases?q=Redmi-AX6%EF%BC%88%E5%90%88%E5%B9%B6%E5%88%86%E5%8C%BA%EF%BC%89+immortalwrt&expanded=true) |
| [![](https://img.shields.io/badge/OpenWrt-ArmV8-32C955.svg?logo=openwrt)](https://github.com/fichenx/Actions-OpenWrt/blob/main/.github/workflows/Releases_ARMv8_OpenWrt.yml) | [![](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Releases_ARMv8_OpenWrt.yml/badge.svg)](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Releases_ARMv8_OpenWrt.yml) | [![](https://img.shields.io/badge/编译-配置-orange.svg?logo=apache-spark)](https://github.com/fichenx/Actions-OpenWrt/blob/main/config/ARMv8.config) | [![](https://img.shields.io/badge/下载-链接-blueviolet.svg?logo=hack-the-box)](https://github.com/fichenx/Actions-OpenWrt/releases?q=ARMv8&expanded=true) |
| [![](https://img.shields.io/badge/MiWifi-mini-32C955.svg?logo=openwrt)](https://github.com/fichenx/Actions-OpenWrt/blob/main/.github/workflows/Build_OpenWrt_MiWifi-mini.yml) | [![](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Build_OpenWrt_MiWifi-mini.yml/badge.svg)](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Build_OpenWrt_MiWifi-mini.yml) | [![](https://img.shields.io/badge/编译-配置-orange.svg?logo=apache-spark)](https://github.com/fichenx/Actions-OpenWrt/blob/main/config/mini.config) | [![](https://img.shields.io/badge/下载-链接-blueviolet.svg?logo=hack-the-box)](https://github.com/fichenx/Actions-OpenWrt/releases?q=MiWifi-mini&expanded=true) |

## 维护自用固件 [![](https://img.shields.io/badge/-维护自用固件插件及预览-FFFFFF.svg)](#维护自用固件-)

### 1、NEWIFI D2 [![](https://img.shields.io/badge/-NEWIFI_D2-FFFFFF.svg)](#1、NEWIFI_D2-)
- 使用源码：https://github.com/coolsnowwolf/lede
- 内核：5.4
- 默认IP：192.168.124.1
- 用户名：root
- 密码：password
<details>
<summary><b>&nbsp;NEWIFI D2插件及预览</b><br/></summary>
<br/>
- 编译插件：<br/>
- 主题：Design<br/>
- 系统：磁盘管理、文件传输<br/>
- 服务：微信推送、openclash、SmartDNS、KMS服务器、Upnp<br/>
- 网络存储：usb打印服务器、硬盘休眠、FTP服务器、网络共享<br/>
- VPN：N2N VPN、NPS内网穿透<br/>
- 网络：多线多拨、负载均衡、Turbo ACC 网络加速。<br/>
<img src="https://github.com/fichenx/OpenWrt/assets/86181542/a1768d5b-1646-4c6d-8e07-893943415dc5"/>
</details>



### 2、Redmi AX6[![](https://img.shields.io/badge/-Redmi_AX6-FFFFFF.svg)](#2、Redmi_AX6-)
- 使用源码（lede原厂分区）：https://github.com/coolsnowwolf/lede (5.10)
- 使用源码（lede合并分区）：https://github.com/coolsnowwolf/lede (5.10)
- 使用源码（immortalwrt合并分区）：https://github.com/immortalwrt/immortalwrt (5.15)
- 默认IP：192.168.123.1
- 用户名：root
- 密码：password
<details>
<summary><b>&nbsp;Redmi AX6插件及预览</b><br/></summary>
<br/>
 编译插件：<br/>
- 主题：Argon、Design<br/>
- 系统：文件传输<br/>
- 服务：上网时间控制、SmartDNS、网络唤醒、Upnp、KMS服务器、微信推送、动态DNS、bypass（lede原厂分区、lede合并分区）、KoolProxyR plus+（lede合并分区）、 openclash（lede合并分区、immortalwrt合并分区）、Watchcat(lede合并分区、immortalwrt合并分区)、passwall（immortalwrt合并分区）、helloword（immortalwrt合并分区）<br/>
- VPN：N2N VPN、nps内网穿透（lede合并分区、immortalwrt合并分区）<br/>
- 网络：多线多拨、负载均衡(lede原厂分区、lede合并分区)、Turbo ACC 网络加速（lede原厂分区、lede合并分区）。<br/>
<img src="https://github.com/fichenx/OpenWrt/assets/86181542/a640d3d9-b935-40ca-9e16-3cc94bdc6a58"/>
</details>



### 3、ARMV8[![](https://img.shields.io/badge/-ARMV8-FFFFFF.svg)](#3、ARMV8-)
- 使用源码：https://github.com/coolsnowwolf/lede 
- 内核：5.4、5.10、5.15、6.1
- 默认IP：192.168.123.2
- 用户名：root
- 密码：password
<details>
<summary><b>&nbsp;ARMV8插件及预览</b><br/></summary>
<br/>
编译插件：<br/>
- 主题：Argon、Design<br/>
- 系统：Argon主题设置、文件传输、磁盘管理、晨晶宝盒<br/>
- 服务：PassWall、ikoolproxy、bypass、ShadowSocksR Plus+、上网时间控制、微信推送、openclash、动态DNS、SmartDNS、watchcat、网络唤醒、uhttpd、Upnp、KMS服务器、MWAN3 分流助手
- docker：DockerMan<br/>
- 网络存储：filebrowser、NFS管理、usb打印服务器、硬盘休眠、打印服务器、minidlna、网络共享、Aria2、MJPG-streamer、FTP服务器、MiniDLNA<br/>
- VPN：N2N VPN、IPsec VPN服务器、PPTP VPN服务器、Frps、Frp内网穿透、NPS内网穿透<br/>
- 网络：SQM Qos、socat、Turbo ACC 网络加速、u多线多拨、负载均衡。<br/>
<img src="https://github.com/fichenx/OpenWrt/assets/86181542/a7ff319a-8875-4f58-a185-af6c1af979fc"/>
</details>

---------------------------

## 感谢

- [OpenWrt](https://github.com/openwrt/openwrt)
- [Lean's OpenWrt](https://github.com/coolsnowwolf/lede)
- [immortalwrt OpenWrt](https://github.com/immortalwrt/immortalwrt)
- [unifreq/openwrt_packit](https://github.com/unifreq/openwrt_packit)
- [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)
- [ophub/flippy-openwrt-actions](https://github.com/ophub/flippy-openwrt-actions)
- [breakings/OpenWrt](https://github.com/breakings/OpenWrt)

## License

[MIT](https://github.com/fichenx/OpenWrt/blob/main/LICENSE) © [**尘事尘飞**]
