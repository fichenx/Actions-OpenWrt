**中文** | [上游源代码](https://github.com/P3TERX/Actions-OpenWrt)

<div align="center">
<h1>Actions-OpenWrt(多设备固件云编译)</h1>

[![LICENSE](https://img.shields.io/github/license/mashape/apistatus.svg?style=flat-square&label=LICENSE)](https://github.com/fichenx/Actions-OpenWrt/blob/main/LICENSE)
![GitHub Stars](https://img.shields.io/github/stars/fichenx/Actions-OpenWrt.svg?style=flat-square&label=Stars&logo=github)
![GitHub Forks](https://img.shields.io/github/forks/fichenx/Actions-OpenWrt.svg?style=flat-square&label=Forks&logo=github)
![GitHub download](https://img.shields.io/github/downloads/fichenx/Actions-OpenWrt/total.svg?style=flat-square&label=Download&logo=github)
</div>

## 项目说明 [![](https://img.shields.io/badge/-项目基本介绍-FFFFFF.svg)](#项目说明-)
- 固件来源：[![Lean](https://img.shields.io/badge/Lede-coolsnowwolf-ff69b4.svg?style=flat&logo=appveyor)](https://github.com/coolsnowwolf/lede) [![immortalwrt](https://img.shields.io/badge/immortalwrt-immortalwrt-ff69b4.svg?style=flat&logo=appveyor)](https://github.com/immortalwrt/immortalwrt) [![VIKINGYFY](https://img.shields.io/badge/immortalwrt-VIKINGYFY-ff69b4.svg?style=flat&logo=appveyor)](https://github.com/VIKINGYFY/immortalwrt) [![LiBwRT](https://img.shields.io/badge/LiBwRT-openwrt_6.x-ff69b4.svg?style=flat&logo=appveyor)](https://github.com/LiBwRT/openwrt-6.x)
- 脚本使用及参考： [![P3TERX](https://img.shields.io/badge/OpenWrt-P3TERX-blueviolet.svg?style=flat&logo=appveyor)](https://github.com/P3TERX/Actions-OpenWrt) [![Flippy](https://img.shields.io/badge/Package-Flippy-orange.svg?style=flat&logo=appveyor)](https://github.com/unifreq/openwrt_packit) [![ZqinKing](https://img.shields.io/badge/wrt_release-ZqinKing-orange.svg?style=flat&logo=appveyor)](https://github.com/ZqinKing/wrt_release)
- 项目使用 Github Actions 拉取 [coolsnowwolf](https://github.com/coolsnowwolf/lede) | [immortalwrt](https://github.com/immortalwrt/immortalwrt) | [VIKINGYFY](https://github.com/VIKINGYFY/immortalwrt) | [LiBwRT](https://github.com/LiBwRT/openwrt-6.x) 的 OpenWrt 源码仓库进行云编译
- 提供适配于 NEWIFI D2、Redmi AX6、ARMv8 电视盒子（斐讯N1、Tanix-TX3）的 OpenWrt 固件
- 每台设备提供多个变体（lede_lua/lede_js/imm 或 imm/libwrt），详见下表
- Redmi AX6 固件使用 [VIKINGYFY](https://github.com/VIKINGYFY/immortalwrt) 或 [LiBwRT](https://github.com/LiBwRT/openwrt-6.x) 添加 NSS 的源码
- 固件集成的所有 ipk 插件全部打包在 Packages 文件中，可以在 [Releases](https://github.com/fichenx/Actions-OpenWrt/releases) 内进行下载

## 固件下载 [![](https://img.shields.io/badge/-编译状态及下载链接-FFFFFF.svg)](#固件下载-)
点击下表中 [![](https://img.shields.io/badge/下载-链接-blueviolet.svg?style=flat&logo=hack-the-box)](https://github.com/fichenx/Actions-OpenWrt/releases) 即可跳转到该设备固件下载页面
| 设备 / 变体 | 固件编译状态 | 配置文件 | 固件下载 |
| :---: | :---: | :---: | :---: |
| **NEWIFI D2** | | | |
| lede_lua | [![](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Release_Newifi-D2.yml/badge.svg)](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Release_Newifi-D2.yml) | [配置](https://github.com/fichenx/Actions-OpenWrt/blob/main/config/Newifi-D2_lede_lua.config) | [下载](https://github.com/fichenx/Actions-OpenWrt/releases?q=Newifi-D2_lede_lua&expanded=true) |
| lede_js | [![](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Release_Newifi-D2.yml/badge.svg)](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Release_Newifi-D2.yml) | [配置](https://github.com/fichenx/Actions-OpenWrt/blob/main/config/Newifi-D2_lede_js.config) | [下载](https://github.com/fichenx/Actions-OpenWrt/releases?q=Newifi-D2_lede_js&expanded=true) |
| imm | [![](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Release_Newifi-D2.yml/badge.svg)](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Release_Newifi-D2.yml) | [配置](https://github.com/fichenx/Actions-OpenWrt/blob/main/config/Newifi-D2_imm.config) | [下载](https://github.com/fichenx/Actions-OpenWrt/releases?q=Newifi-D2_imm&expanded=true) |
| **Redmi AX6** | | | |
| imm (NSS) | [![](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Release_Redmi-AX6_plus.yml/badge.svg)](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Release_Redmi-AX6_plus.yml) | [配置](https://github.com/fichenx/Actions-OpenWrt/blob/main/config/RedMi-AX6_plus_imm.config) | [下载](https://github.com/fichenx/Actions-OpenWrt/releases?q=RedMi-AX6_plus_imm&expanded=true) |
| libwrt (NSS) | [![](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Release_Redmi-AX6_plus.yml/badge.svg)](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Release_Redmi-AX6_plus.yml) | [配置](https://github.com/fichenx/Actions-OpenWrt/blob/main/config/RedMi-AX6_plus_libwrt.config) | [下载](https://github.com/fichenx/Actions-OpenWrt/releases?q=RedMi-AX6_plus_libwrt&expanded=true) |
| **ARMv8 (N1/TX3)** | | | |
| lede_lua | [![](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Build_ARMv8.yml/badge.svg)](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Build_ARMv8.yml) | [配置](https://github.com/fichenx/Actions-OpenWrt/blob/main/config/ARMv8_lede_lua.config) | [下载](https://github.com/fichenx/Actions-OpenWrt/releases?q=ARMv8_lede_lua&expanded=true) |
| lede_js | [![](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Build_ARMv8.yml/badge.svg)](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Build_ARMv8.yml) | [配置](https://github.com/fichenx/Actions-OpenWrt/blob/main/config/ARMv8_lede_js.config) | [下载](https://github.com/fichenx/Actions-OpenWrt/releases?q=ARMv8_lede_js&expanded=true) |
| imm | [![](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Build_ARMv8.yml/badge.svg)](https://github.com/fichenx/Actions-OpenWrt/actions/workflows/Build_ARMv8.yml) | [配置](https://github.com/fichenx/Actions-OpenWrt/blob/main/config/ARMv8_imm.config) | [下载](https://github.com/fichenx/Actions-OpenWrt/releases?q=ARMv8_imm&expanded=true) |

## 维护自用固件 [![](https://img.shields.io/badge/-维护自用固件插件及预览-FFFFFF.svg)](#维护自用固件-)

### 1、NEWIFI D2 [![](https://img.shields.io/badge/-NEWIFI_D2-FFFFFF.svg)](#1、NEWIFI_D2-)
- 默认IP：192.168.124.1
- 用户名：root
- 密码：password
- 变体：lede_lua / lede_js（源码 coolsnowwolf/lede，MT7621/内核5.10）| imm（源码 immortalwrt，MT7621）
<details>
<summary><b>&nbsp;NEWIFI D2 插件及预览</b><br/></summary>
<br/>

**lede_lua / lede_js**（插件清单相同）<br/>
- 主题：Design<br/>
- 系统：磁盘管理、终端<br/>
- 服务：OpenClash、SmartDNS、微信推送(ServerChan)、UPnP、Watchcat Plus、ShadowSocksR Plus+<br/>
- 网络存储：网络共享(Samba)、USB打印服务器<br/>
- VPN：N2N VPN、NPS内网穿透<br/>
- 网络：多线多拨、MWAN3分流助手、Socat<br/>

**imm**<br/>
- 主题：Bootstrap、Design<br/>
- 系统：磁盘管理、定时重启、终端、软件包管理器<br/>
- 服务：OpenClash、HomeProxy、SmartDNS、微信推送、UPnP、AdGuard Home、Lucky、DDNS、MSD Lite、Watchcat Plus、Turbo ACC、Vlmcsd KMS服务器<br/>
- 网络存储：网络共享(Samba4)、FTP服务器(vsftpd)、USB打印服务器<br/>
- VPN：N2N VPN、NPS内网穿透<br/>
- 网络：多线多拨、MWAN3分流助手、上网时间控制(NFT)<br/>
- 防火墙：firewall4 (nftables)<br/>
<img src="https://github.com/fichenx/OpenWrt/assets/86181542/a1768d5b-1646-4c6d-8e07-893943415dc5"/>
</details>



### 2、Redmi AX6 [![](https://img.shields.io/badge/-Redmi_AX6-FFFFFF.svg)](#2、Redmi_AX6-)
- 使用源码：VIKINGYFY/immortalwrt (imm) 或 LiBwRT/openwrt-6.x (libwrt)，均含 NSS 加速
- 内核：6.12 (NSS)
- 默认IP：192.168.1.1
- 用户名：root
- 密码：password
- 变体：imm / libwrt（插件清单相同，源码不同）
<details>
<summary><b>&nbsp;Redmi AX6 插件及预览</b><br/></summary>
<br/>
- 主题：Argon、Design<br/>
- 系统：文件管理器、定时重启、终端<br/>
- 服务：AdGuard Home、HomeProxy、OpenClash、Lucky、SmartDNS、DDNS、MSD Lite、微信推送、Watchcat Plus、UPnP、UHTTPd、Vlmcsd KMS服务器、时间控制<br/>
- VPN：N2N VPN<br/>
- 网络：SQM QoS、多线多拨、MWAN3分流助手<br/>
- 防火墙：firewall4 (nftables)，UPnP守护进程 miniupnpd-nftables<br/>
<img src="https://github.com/user-attachments/assets/5451cbc3-a334-4438-9a8a-3fda02efdfc8"/>
</details>



### 3、ARMv8 (N1/TX3) [![](https://img.shields.io/badge/-ARMV8-FFFFFF.svg)](#3、ARMV8-)
- 默认IP：192.168.123.2
- 用户名：root
- 密码：password
- 变体：lede_lua / lede_js（源码 coolsnowwolf/lede，armsr/armv8，支持多内核5.4~6.12）| imm（源码 immortalwrt，armsr/armv8）
<details>
<summary><b>&nbsp;ARMv8 插件及预览</b><br/></summary>
<br/>

**lede_lua / lede_js**<br/>
- 主题：Argon、Design<br/>
- 系统：Argon主题设置、文件传输、磁盘管理、晨晶宝盒(Amlogic)、终端<br/>
- 服务：OpenClash、SmartDNS、AdGuard Home、iKoolProxy、Watchcat Plus、时间控制、微信推送、Lucky、DDNS、MSD Lite、UHTTPd、UPnP、Vlmcsd KMS服务器、MWAN3分流助手、HomeAssistant<br/>
- Docker：DockerMan<br/>
- 网络存储：FileBrowser、NFS管理、网络共享(Samba4)、硬盘休眠、MiniDLNA、MJPG-streamer、USB打印服务器、Aria2<br/>
- VPN：N2N VPN、IPsec VPN服务器、PPTP VPN服务器、NPS内网穿透<br/>
- 网络：SQM QoS、多线多拨、Socat、TCPDump<br/>
- lede_js 额外：HomeProxy；防火墙 firewall4 (nftables)<br/>
- lede_lua 额外：ShadowSocksR Plus+；防火墙 iptables；UPnP守护进程 miniupnpd-iptables<br/>

**imm**<br/>
- 主题：Argon、Bootstrap、Design<br/>
- 系统：Argon主题设置、磁盘管理、晨晶宝盒(Amlogic)、定时重启、终端、软件包管理器<br/>
- 服务：OpenClash、HomeProxy、SmartDNS、AdGuard Home、Lucky、DDNS、MSD Lite、微信推送、Watchcat Plus、UPnP、UHTTPd、Vlmcsd KMS服务器、MWAN3分流助手、HomeAssistant<br/>
- Docker：DockerMan<br/>
- 网络存储：FileBrowser、FileAssistant、网络共享(Samba4)、硬盘休眠、MiniDLNA、USB打印服务器<br/>
- VPN：N2N VPN、NPS内网穿透<br/>
- 网络：多线多拨、时间控制<br/>
<img src="https://github.com/fichenx/OpenWrt/assets/86181542/a7ff319a-8875-4f58-a185-af6c1af979fc"/>
</details>

---------------------------

## 感谢

- [OpenWrt](https://github.com/openwrt/openwrt)
- [coolsnowwolf OpenWrt](https://github.com/coolsnowwolf/lede)
- [immortalwrt OpenWrt](https://github.com/immortalwrt/immortalwrt)
- [VIKINGYFY OpenWrt](https://github.com/VIKINGYFY/immortalwrt)
- [LiBwRT OpenWrt](https://github.com/LiBwRT/openwrt-6.x)
- [unifreq/openwrt_packit](https://github.com/unifreq/openwrt_packit)
- [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)
- [ophub/flippy-openwrt-actions](https://github.com/ophub/flippy-openwrt-actions)
- [ZqinKing/wrt_release](https://github.com/ZqinKing/wrt_release)

## License

[MIT](https://github.com/fichenx/OpenWrt/blob/main/LICENSE) © [**尘事尘飞**]
