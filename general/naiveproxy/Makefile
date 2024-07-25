include $(TOPDIR)/rules.mk

PKG_NAME:=naiveproxy
PKG_VERSION:=126.0.6478.40-2
PKG_RELEASE:=1

ARCH_PREBUILT:=$(ARCH_PACKAGES)

# intel 80386 & riscv64 & cortex-a76
ifeq ($(ARCH_PREBUILT),aarch64_cortex-a76)
  ARCH_PREBUILT:=aarch64_generic
else ifeq ($(ARCH_PREBUILT),i386_pentium-mmx)
  ARCH_PREBUILT:=x86
else ifeq ($(ARCH_PREBUILT),i386_pentium4)
  ARCH_PREBUILT:=x86
else ifeq ($(ARCH_PREBUILT),riscv64_riscv64)
  ARCH_PREBUILT:=riscv64
endif

PKG_SOURCE:=naiveproxy-v$(PKG_VERSION)-openwrt-$(ARCH_PREBUILT).tar.xz
PKG_SOURCE_URL:=https://github.com/klzgrad/naiveproxy/releases/download/v$(PKG_VERSION)/

ifeq ($(ARCH_PREBUILT),aarch64_cortex-a53)
  PKG_HASH:=6660dd7ce7c9d8ed6f07461cdb41ec1efa5b274a6392d00b66fafe1d449bfb38
else ifeq ($(ARCH_PREBUILT),aarch64_cortex-a72)
  PKG_HASH:=a6c72159ee2a3a8ba2736780bd49d711caa34b8dcf9823ed678b3481ece4b74c
else ifeq ($(ARCH_PREBUILT),aarch64_generic)
  PKG_HASH:=09063b703d161f1e17d00b6bc467baeff823d554624c62ddb47433665fceaa6b
else ifeq ($(ARCH_PREBUILT),arm_arm1176jzf-s_vfp)
  PKG_HASH:=c61be39e4c53a43257652753b1e72b0453edfdda991da80b91e3cdd01c702c45
else ifeq ($(ARCH_PREBUILT),arm_arm926ej-s)
  PKG_HASH:=223cf5c79b8b7d9b2b6a6b1ba2b5e489e62360c04e5412b5951be9053366937a
else ifeq ($(ARCH_PREBUILT),arm_cortex-a15_neon-vfpv4)
  PKG_HASH:=1220b3e041de4ce340e5a160d79358e2560c09852fd21b371c2d9c7aa4a826fe
else ifeq ($(ARCH_PREBUILT),arm_cortex-a5_vfpv4)
  PKG_HASH:=342bfc00577422ae4ee5b91544c40607bddfd4be1becb6aaf6e74ecb87995c85
else ifeq ($(ARCH_PREBUILT),arm_cortex-a7)
  PKG_HASH:=0225969bce91a8e38782ac06a84e40635ceccb85179f5b61637cf0f56c6b30e2
else ifeq ($(ARCH_PREBUILT),arm_cortex-a7_neon-vfpv4)
  PKG_HASH:=6f3e8dbba7125afc157a266d5f4c3142035ab2018eddd16a67e76f7eb069b54d
else ifeq ($(ARCH_PREBUILT),arm_cortex-a7_vfpv4)
  PKG_HASH:=e689e9c26dc7dd80c89c96a49754d7293bcf95f30fce53d01f9ecc269b510aef
else ifeq ($(ARCH_PREBUILT),arm_cortex-a8_vfpv3)
  PKG_HASH:=28adbabd9149a8f6fcbd42cfedcb7c0c05f36f3e2805d7094bce4db7007c42e2
else ifeq ($(ARCH_PREBUILT),arm_cortex-a9)
  PKG_HASH:=7d3bcf98d56badf19bc0a9d862dc7e0f49d4e87512a9e8178536dcac66009a4e
else ifeq ($(ARCH_PREBUILT),arm_cortex-a9_neon)
  PKG_HASH:=cc606689390bab76865b43abf9f08bc20034ba5a8b2547867440b4929fc3823a
else ifeq ($(ARCH_PREBUILT),arm_cortex-a9_vfpv3-d16)
  PKG_HASH:=afcdfcc109ce417b98c169aa67824a5ea93491a00ef44a49bbb7cb98e605ea38
else ifeq ($(ARCH_PREBUILT),arm_mpcore)
  PKG_HASH:=118ec14b62c00a896f93f93634e20e0a4079cb97b142051dba4c12393bdb64a1
else ifeq ($(ARCH_PREBUILT),arm_xscale)
  PKG_HASH:=1f411ecc7c276506066e05b0084b9c482b9ecfa6db720d9b254f505eac920211
else ifeq ($(ARCH_PREBUILT),mipsel_24kc)
  PKG_HASH:=970b370b41db8bcd3b1badce38da00eb7bda512b540f883d6d2bb83fdb9be7f7
else ifeq ($(ARCH_PREBUILT),mipsel_mips32)
  PKG_HASH:=bde9fb31f03b0619e139d43c6de1b9281b1d25f5cdc28608c1949675d0b450b7
else ifeq ($(ARCH_PREBUILT),riscv64)
  PKG_HASH:=82247784168360bf39d4f05cfa0ec65e5e301d1938bf80c7649d93df67638964
else ifeq ($(ARCH_PREBUILT),x86)
  PKG_HASH:=9de8616e56ef78b126fe3b27ad01fc5f9e928bb09257bea5a5b9ca463c389c38
else ifeq ($(ARCH_PREBUILT),x86_64)
  PKG_HASH:=6ba6016f2a00c0441b1e331eb0536ec2fbc9736f8ad25157ff7bd3f2c9759e8d
else
  PKG_HASH:=dummy
endif

PKG_LICENSE:=BSD 3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=sbwml <admin@cooluc.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/naiveproxy-v$(PKG_VERSION)-openwrt-$(ARCH_PACKAGES)

include $(INCLUDE_DIR)/package.mk

define Package/naiveproxy
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=Make a fortune quietly
  URL:=https://github.com/klzgrad/naiveproxy
  DEPENDS:=@(aarch64||arm||i386||mipsel||riscv64||x86_64) +libatomic
endef

define Package/naiveproxy/description
  NaïveProxy uses Chrome's network stack to camouflage traffic with strong
  censorship resistance and low detectability. Reusing Chrome's stack also
  ensures best practices in performance and security.
endef

define Package/naiveproxy/conffiles
/etc/config/naiveproxy
endef

define Build/Prepare
	$(TAR) --strip-components=1 -C $(PKG_BUILD_DIR) -xJf $(DL_DIR)/naiveproxy-v$(PKG_VERSION)-openwrt-$(ARCH_PREBUILT).tar.xz
endef

define Build/Compile
endef

define Package/naiveproxy/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/naive $(1)/usr/bin/naive
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_CONF) $(CURDIR)/files/naiveproxy.config $(1)/etc/config/naiveproxy
	$(INSTALL_BIN) $(CURDIR)/files/naiveproxy.init $(1)/etc/init.d/naiveproxy
endef

$(eval $(call BuildPackage,naiveproxy))
