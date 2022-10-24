# Mageia LXC
Everything to build a Mageia LXC container.

> Please note that the process is in heavy development. Do not use it (for the moment).

## Steps
1. [Build Distrobuilder](https://github.com/lxc/distrobuilder#installing-from-source)
2. Set mapped UID/GID
3. Set config files
4. Create bridge interface
5. Build Mageia container
6. Add container to LXC
7. Start container

## Create bridge interface
Install `bridge-utils`, used to manage bridge interfaces.
Then, create a bridge. 
```Bash
# brctl addbr br0
```

## Build Mageia container
```Bash
# distrobuilder build-lxc ./mageia/scheme.yaml
```

## Add container to LXC
```Bash
# lxc-create -n mageia -t local -- --metadata meta.tar.xz --fstree rootfs.tar.xz
```

## Start container
```Bash
# lxc-start -n mageia -F -f .config/lxc/default.conf
bash-5.1# 
```
