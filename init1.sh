#!/bin/bash

set -xe

# echo '::1 localhost' >> /etc/hosts

function ins () {
    pacman -S --noconfirm "$@"
}

function yao () {
    sudo -u zw963 yaourt --m-arg "--skippgpcheck" -S --noconfirm "$@"
}

pacman -Sy

# 安装和配置 grub, 注意, 在更改了内核版本后, 也需要运行 grub-mkconfig
# 注意：grub2-mkconfig -o /boot/grub/grub.cfg 则是升级内核后，使用 grub 启动通用的办法。
# 注意目录名，例如：centos 是 /boot/grub2/grub.cfg

# 注意: 新版安装程序貌似不需要这个步骤了.
# ins grub
# grub-install /dev/sda
# grub-mkconfig -o /boot/grub/grub.cfg

# 网络相关工具

ins bash-completion

# ins nfs-utils
# systemctl enable nfs-server
# systemctl enable rpcbind

# # 最新的 Gnome3 不含 xorg 的, 使用的是 Wayland.
# ins xorg
# ins xorg-xinit
# ins xterm
# # intel 集成显卡驱动
# ins xf86-video-intel libxss

ins cinnamon
ins mupdf                       # 一个很简单的 pdf reader.

# 类似于 mac 下的 alfred
ins albert

# 安装 patched 版本的 wicd, 这个版本修复了 wicd-curses 总是崩溃的问题。
yao wicd-patched

echo 'Run before boot:'

echo 'arch-chroot /mnt /bin/bash'
echo 'passwd'
echo 'passwd zw963'

echo 'Run after boot:'

echo 'alsamixer'
echo 'aplay /usr/share/sounds/alsa/Front_Center.wav'
echo '/usr/sbin/alsactl store'
