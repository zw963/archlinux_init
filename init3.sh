#!/bin/bash

set -xeu

useradd -m zw963
echo 'zw963 ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && hwclock --systohc

function add_config () {
    pattern="$1"
    cat "$2" |grep "^${pattern}" || echo "$pattern" >> "$2"
}

# 开启需要的 locale
add_config 'en_US.UTF-8 UTF-8' /etc/locale.gen
add_config 'zh_CN.UTF-8 UTF-8' /etc/locale.gen
add_config 'zh_TW.UTF-8 UTF-8' /etc/locale.gen

locale-gen

echo 'LANG=en_US.UTF-8' > /etc/locale.conf

echo 'zbook' > /etc/hostname

echo '127.0.0.1 localhost' >> /etc/hosts
echo '127.0.0.1 zbook' >> /etc/hosts

function pacman () {
    command pacman --noconfirm "$@"
}

function yay () {
    command yay --noconfirm "$@";
}

sed -i '1iServer = https://mirrors.bfsu.edu.cn/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
cat <<'HEREDOC' >> /etc/pacman.conf
[archlinuxcn]
# SigLevel = Optional TrustAll
Server = https://mirrors.bfsu.edu.cn/archlinuxcn/$arch
HEREDOC
sed -i 's#\#\[multilib\]#[multilib]\nInclude = /etc/pacman.d/mirrorlist#' /etc/pacman.conf

pacman -Sy
pacman -Fy

# must update this first, othersize, may install failed due required key missing from keyring.
pacman -S archlinuxcn-keyring

# 如果没有安装 X, 为了重启后可以连接 wifi, 需要安装 iwd, dhcpcd.
# 但是如果安装了 gnome, 安装了 network-manager(替代iwd), 则只需要 systemd-networkd(替代 dhcpcd) 就够了。
# pacman -S iwd
# systemctl enable iwd

# 似乎 ntp 也不需要了。
pacman -S systemd
systemctl enable systemd-networkd systemd-timesyncd.service

pacman -S rsync wget net-tools man netcat cronie mlocate ntfs-3g bind exfat-utils bash-completion
systemctl enable ntpdate
systemctl enable cronie

pacman -S alsa-utils # pavucontrol is seem like not necessory.
# 将当前用户加入 audio 分组.
sudo gpasswd -a zw963 audio

pacman -S gnome gnome-tweaks dconf-editor networkmanager network-manager-applet konsole firefox google-chrome gparted copyq flameshot
systemctl enable NetworkManager
systemctl enable gdm # use GDM as display manager
# systemctl enable bluetooth

# pacman -S fcitx-im fcitx-sunpinyin fcitx-configtool
pacman -S fcitx5-chinese-addons fcitx5-gtk fcitx5-pinyin-zhwiki fcitx5-config-qt

# ttf-dejavu + xorg-mkfontscale is need for emacs support active fcitx.
# jansson for better json performance for emacs 27.1
# libgccjit for support native compilation.
pacman -S emacs ttf-dejavu xorg-mkfontscale jansson libgccjit ttf-hanazono libotf m17n-lib

pacman -S virtualbox virtualbox-guest-iso virtualbox-host-modules-arch virtualbox-ext-oracle
sudo gpasswd -a zw963 vboxusers
# sudo modprobe vboxdrv

# Emacs telega 客户端用 telegram-tdlib
pacman -S telegram-desktop telegram-tdlib

# 好几个软件，例如，mu 依赖这个。
pacman -S xapian-core

pacman -S gimp gimp-help-zh_cn

# https://extensions.gnome.org/extension/120/system-monitor/
pacman -S gnome-usage chrome-gnome-shell gnome-shell-extension-appindicator

# pacman -S plasma kde-applications

echo '[0m[33mremember change password of zw963 and root.[0m'
