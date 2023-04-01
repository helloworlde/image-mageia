DIST = mageia
DIST_VER = 8
CT_NAME := $(DIST)$(DIST_VER)
CT_PATH := $(shell pwd)/$(CT_NAME)
ROOTFS = rootfs
OUT = out

minimal:
	mkdir $(CT_NAME)
	rpm --rebuilddb --root=$(CT_PATH)

	$(info Installing base RPMs...)
	rpm --root=$(CT_PATH) --nodeps -ivh http://ftp.free.fr/mirrors/mageia.org/distrib/$(DIST_VER)/x86_64/media/core/release/mageia-release-Default-8-3.mga$(DIST_VER).x86_64.rpm
	rpm --root=$(CT_PATH) --nodeps -ivh http://ftp.free.fr/mirrors/mageia.org/distrib/$(DIST_VER)/x86_64/media/core/release/mageia-release-common-8-3.mga$(DIST_VER).x86_64.rpm
	rpm --root=$(CT_PATH) --nodeps -ivh http://ftp.free.fr/mirrors/mageia.org/distrib/$(DIST_VER)/x86_64/media/core/release/lsb-release-3.1-2.mga$(DIST_VER).noarch.rpm

	$(info Configuring $(TGT_DIST) repositories...)
	urpmi.addmedia --distrib http://ftp.free.fr/mirrors/mageia.org/distrib/$(DIST_VER)/x86_64 --urpmi-root $(CT_PATH)

	$(info Installing minimal system...)
	urpmi basesystem-minimal urpmi locales locales-en systemd --auto --no-recommends --urpmi-root $(CT_PATH) --root $(CT_PATH)

squash-minimal:
	mksquashfs $(CT_NAME) $(CT_NAME).sqfs || $(error "Need squashfs-tools package.)

lxc:
	distrobuilder || $(error Need package distrobuilder: https://github.com/lxc/distrobuilder)
	$(info Building root FS...)
	distrobuilder build-dir $(DIST).yaml $(ROOTFS)
	$(info Packing container...)
	distrobuilder pack-lxc $(DIST).yaml $(ROOTFS) $(OUT)

	$(info Creating network bridge...)
	brctl || $(error Need package bridge-utils.)
	brctl addbr vmbr0

pack-lxc:

lxc-add:
	lxc-create --name "${CT_NAME}" --template local -- --fstree $(OUT)/rootfs.tar.xz --metadata $(OUT)/meta.tar.xz

lxc-start:
	lxc-start -n $(CT_NAME)

clean:
	lxc-stop $(CT_NAME) || true
	lxc-destroy $(CT_NAME) || true
	rm -rf $(ROOTFS) $(OUT) $(CT_NAME) $(CT_NAME).sqfs
