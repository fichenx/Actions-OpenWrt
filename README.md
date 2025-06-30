**中文** | [上游源代码](https://github.com/P3TERX/Actions-OpenWrt)

<div align="center">
<h1>Actions-OpenWrt(多设备固件云编译)</h1>

[![LICENSE](https://img.shields.io/github/license/mashape/apistatus.svg?style=flat-square&label=LICENSE)](https://github.com/fichenx/Actions-OpenWrt/blob/main/LICENSE)
![GitHub Stars](https://img.shields.io/github/stars/fichenx/Actions-OpenWrt.svg?style=flat-square&label=Stars&logo=github)
![GitHub Forks](https://img.shields.io/github/forks/fichenx/Actions-OpenWrt.svg?style=flat-square&label=Forks&logo=github)
![GitHub download](https://img.shields.io/github/downloads/fichenx/Actions-OpenWrt/total.svg?style=flat-square&label=Download&logo=github)
</div>

## 项目说明 [![](https://img.shields.io/badge/-项目基本介绍-FFFFFF.svg)](#项目说明-)
- 固件来源：[![Lean](https://img.shields.io/badge/Lede-coolsnowwolf-ff69b4.svg?style=flat&logo=appveyor)](https://github.com/coolsnowwolf/lede)[![immortalwrt](https://img.shields.io/badge/immortalwrt-immortalwrt-ff69b4.svg?style=flat&logo=appveyor)](https://github.com/immortalwrt/immortalwrt) [![VIKINGYFY](https://img.shields.io/badge/immortalwrt-VIKINGYFY-ff69b4.svg?style=flat&logo=appveyor)](https://github.com/VIKINGYFY/immortalwrt)
- 脚本使用及参考： [![P3TERX](https://img.shields.io/badge/OpenWrt-P3TERX-blueviolet.svg?style=flat&logo=appveyor)](https://github.com/P3TERX/Actions-OpenWrt) [![Flippy](https://img.shields.io/badge/Package-Flippy-orange.svg?style=flat&logo=appveyor)](https://github.com/unifreq/openwrt_packit)  [![breakingbadboy](https://img.shields.io/badge/OpenWrt-breakingbadboy-orange.svg?style=flat&logo=appveyor)](https://github.com/breakingbadboy/OpenWrt)  [![ZqinKing](https://img.shields.io/badge/wrt_release-ZqinKing-orange.svg?style=flat&logo=appveyor)](https://github.com/ZqinKing/wrt_release)
- 项目使用 Github Actions 拉取 [coolsnowwolf](https://github.com/coolsnowwolf/lede) | [immortalwrt](https://github.com/immortalwrt/immortalwrt) |  [VIKINGYFY](https://github.com/VIKINGYFY/immortalwrt)的 Openwrt 源码仓库进行云编译
- 提供适配于NEWIFI D2、Redmi AX6、 ARMv8 电视盒子（斐讯N1、Tanix-TX3）的 OpenWrt 固件
- Redmi AX6固件使用[VIKINGYFY](https://github.com/VIKINGYFY/immortalwrt)添加NSS的immortalwrt源码。
- 固件集成的所有 ipk 插件全部打包在 Packages 文件中，可以在 [Releases](https://github.com/fichenx/Actions-OpenWrt/releases) 内进行下载

## 固件下载 [![](https://img.shields.io/badge/-编译状态及下载链接-FFFFFF.svg)](#固件下载-)
点击下表中 [![](https://img.shields.io/badge/下载-链接-blueviolet.svg?style=flat&logo=hack-the-box)](https://github.com/fichenx/Actions-OpenWrt/releases) 即可跳转到该设备固件下载页面
| 平台+设备名称 | 固件编译状态 | 配置文件 | 固件下载 |
| :-------------: | :-------------: | :-------------: | :-------------: |
| [![](https://img.shields.io/badge/Newifi-D2(lede_lua)-32C955.svg?logo=openwrt)](https://github.com/fichenx/Actions-OpenWrt/blob/main/.github/workflows/Release_Newifi-D2_lede.yml) | [![](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Release_Newifi-D2_lede.yml/badge.svg)](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Release_Newifi-D2_lede.yml) | [![](https://img.shields.io/badge/编译-配置-orange.svg?logo=apache-spark)](https://github.com/fichenx/Actions-OpenWrt/blob/main/config/Newifi-D2_lede_lua.config) | [![](https://img.shields.io/badge/下载-链接-blueviolet.svg?logo=hack-the-box)](https://github.com/fichenx/Actions-OpenWrt/releases?q=Newifi-D2&expanded=true) |
| [![](https://img.shields.io/badge/Redmi-AX6_plus（immortalwrt）-32C955.svg?logo=openwrt)](https://github.com/fichenx/Actions-OpenWrt/blob/main/.github/workflows/Release_Redmi-AX6_plus_imm.yml) | [![](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Release_Redmi-AX6_plus_imm.yml/badge.svg)](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Release_Redmi-AX6_plus_imm.yml) | [![](https://img.shields.io/badge/编译-配置-orange.svg?logo=apache-spark)](https://github.com/fichenx/Actions-OpenWrt/blob/main/config/RedMi-AX6_plus_imm.config) | [![](https://img.shields.io/badge/下载-链接-blueviolet.svg?logo=hack-the-box)](https://github.com/fichenx/Actions-OpenWrt/releases?q=RedMi-AX6_plus&expanded=true) |
| [![](https://img.shields.io/badge/ARM-v8(lede_lua)-32C955.svg?logo=openwrt)](https://github.com/fichenx/Actions-OpenWrt/blob/main/.github/workflows/Releases_ARMv8.yml) | [![](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Releases_ARMv8.yml/badge.svg)](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Releases_ARMv8.yml) | [![](https://img.shields.io/badge/编译-配置-orange.svg?logo=apache-spark)](https://github.com/fichenx/Actions-OpenWrt/blob/main/config/ARMv8_lede_lua.config) | [![](https://img.shields.io/badge/下载-链接-blueviolet.svg?logo=hack-the-box)](https://github.com/fichenx/Actions-OpenWrt/releases?q=ARMv8&expanded=true) |

## 维护自用固件 [![](https://img.shields.io/badge/-维护自用固件插件及预览-FFFFFF.svg)](#维护自用固件-)

### 1、NEWIFI D2 [![](https://img.shields.io/badge/-NEWIFI_D2-FFFFFF.svg)](#1、NEWIFI_D2-)
- 使用源码：https://github.com/coolsnowwolf/lede
- 内核：5.10
- 默认IP：192.168.124.1
- 用户名：root
- 密码：password
<details>
<summary><b>&nbsp;NEWIFI D2插件及预览</b><br/></summary>
<br/>
- 编译插件：<br/>
- 主题：Design<br/>
- 系统：磁盘管理、文件传输<br/>
- 服务：微信推送、openclash、SmartDNS、KMS服务器、Upnp、ShadowSocksR Plus+<br/>
- 网络存储：usb打印服务器、硬盘休眠、FTP服务器、网络共享<br/>
- VPN：N2N VPN、NPS内网穿透<br/>
- 网络：多线多拨、负载均衡、Turbo ACC 网络加速。<br/>
<img src="https://github.com/fichenx/OpenWrt/assets/86181542/a1768d5b-1646-4c6d-8e07-893943415dc5"/>
</details>



### 2、Redmi AX6[![](https://img.shields.io/badge/-Redmi_AX6-FFFFFF.svg)](#2、Redmi_AX6-)
- 使用源码：https://github.com/VIKINGYFY/immortalwrt
- 内核：6.12
- 默认IP：192.168.123.1
- 用户名：root
- 密码：password
<details>
<summary><b>&nbsp;Redmi AX6插件及预览</b><br/></summary>
<br/>
 编译插件：<br/>
- 主题：Argon、Design<br/>
- 系统：文件管理器、定时重启、终端<br/>
- 服务：AdGuard Home（不含二进制文件，可在界面下载）、应用过滤、HomeProxy、watchcat-plus、wechatpush 、OpenClash、Lucky、ddns、msd_lite、SmartDNS、网络唤醒、UHTTPd、UPnP IGD 和 PCP、Vlmcsd KMS 服务器<br/>
- 管控：时间控制<br/>
- VPN：N2N VPN<br/>
- 网络：SQM 队列管理、多线多拨、MultiWAN 管理器 <br/>
<img src="https://github.com/user-attachments/assets/5451cbc3-a334-4438-9a8a-3fda02efdfc8"/>
</details>



### 3、ARMV8[![](https://img.shields.io/badge/-ARMV8-FFFFFF.svg)](#3、ARMV8-)
- 使用源码：https://github.com/coolsnowwolf/lede 
- 内核：5.4、5.10、5.15、6.1、6.6、6.12
- 默认IP：192.168.123.2
- 用户名：root
- 密码：password
<details>
<summary><b>&nbsp;ARMV8插件及预览</b><br/></summary>
<br/>
编译插件：<br/>
- 主题：Argon、Design<br/>
- 系统：Argon主题设置、文件传输、磁盘管理、晨晶宝盒<br/>
- 服务：PassWall、ikoolproxy、bypass、Adbyby Plus+ 、AdGuard Home（不含二进制文件，可在界面下载）、ShadowSocksR Plus+、watchcat plus、上网时间控制、微信推送、openclash、DDNS-GO、动态DNS、Privoxy 网络代理、SmartDNS、组播转换 Lite、网络唤醒、uhttpd、Upnp、KMS服务器、MWAN3 分流助手、homeassistant。
- docker：DockerMan<br/>
- 网络存储：filebrowser、NFS管理、usb打印服务器、硬盘休眠、打印服务器、minidlna、网络共享、Aria2、MJPG-streamer、FTP服务器、MiniDLNA<br/>
- VPN：N2N VPN、IPsec VPN服务器、PPTP VPN服务器、Frps、Frp内网穿透、NPS内网穿透<br/>
- 网络：SQM Qos、socat、Turbo ACC 网络加速、u多线多拨、负载均衡、ipv6helper。<br/>
<img src="https://github.com/fichenx/OpenWrt/assets/86181542/a7ff319a-8875-4f58-a185-af6c1af979fc"/>
</details>

---------------------------

## 感谢

- [OpenWrt](https://github.com/openwrt/openwrt)
- [coolsnowwolf OpenWrt](https://github.com/coolsnowwolf/lede)
- [immortalwrt OpenWrt](https://github.com/immortalwrt/immortalwrt)
- [VIKINGYFY OpenWrt](https://github.com/VIKINGYFY/immortalwrt)
- [unifreq/openwrt_packit](https://github.com/unifreq/openwrt_packit)
- [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)
- [ophub/flippy-openwrt-actions](https://github.com/ophub/flippy-openwrt-actions)
- [breakingbadboy/OpenWrt](https://github.com/breakingbadboy/OpenWrt)
- [ZqinKing/wrt_release](https://github.com/ZqinKing/wrt_release)

## License

[MIT](https://github.com/fichenx/OpenWrt/blob/main/LICENSE) © [**尘事尘飞**]
