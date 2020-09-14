#!/bin/bash

set -xe

# 运行的前提条件:
# 1. 网络已经配置好. (不配置好, 没办法使用 curl 从 github 下载这个文件.)
# 2. 已经分区(cfidsk)并格式化(mkfs.ext4 /dev/sda1), 并且成功的 mount 这个分区到 /mnt (mount /dev/sda1 /mnt)

loadkeys us # 确保设定键盘为 US 布局.

# 确保系统时间是准确的, 一定确保同步, 否则会造成签名错误.
timedatectl set-ntp true

# 是否需要运行下面的命令, 来使用本地时钟?
# timedatectl set-local-rtc true

# 设定上海交大源为首选源, 速度更快
# sed -i '1iServer = http://ftp.sjtu.edu.cn/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
# 如果是北方网通, 清华源更快
sed -i '1iServer = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist

# wol 是 wake on line 工具
pacstrap /mnt linux linux-headers linux-firmware base base-devel nano

# 添加交大的 AUR 源
cat <<'HEREDOC' >> /mnt/etc/pacman.conf
[archlinuxcn]
# SigLevel = Optional TrustAll
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch
# Server = https://mirrors.sjtug.sjtu.edu.cn/archlinux-cn/$arch
HEREDOC

# 升级时, 忽略内核和所有 nvidia 包.
# sed -i 's/#IgnorePkg.*=/IgnorePkg = linux linux-headers linux-lts linux-lts-headers nvidia nvidia-lts nvidia-settings nvidia-utils virtualbox virtualbox-guest-iso virtualbox-guest-iso/' /mnt/etc/pacman.conf
sed -i 's#\#\[multilib\]#[multilib]\nInclude = /etc/pacman.d/mirrorlist#' /mnt/etc/pacman.conf

# 生成 root 分区的 fstab 信息
# genfstab -U /mnt >> /mnt/etc/fstab
genfstab -U /home >> /mnt/etc/fstab
sed -i 's#/#/home#' /mnt/etc/fstab
genfstab -U /mnt >> /mnt/etc/fstab

# 切换到目标 root
arch-chroot /mnt /bin/bash

useradd -m zw963
echo 'zw963 ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
# remember change password of zw963 and root.

# 设定上海为当前时区, 并保存时间到主机, hwclock 会生成: /etc/adjtime
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && hwclock --systohc --localtime

function add_config () {
    pattern="$1"
    cat "$2" |grep "^${pattern}" || echo "$pattern" >> "$2"
}

# 开启需要的 locale
add_config 'en_US.UTF-8 UTF-8' /etc/locale.gen
add_config 'zh_CN.UTF-8 UTF-8' /etc/locale.gen
add_config 'zh_TW.UTF-8 UTF-8' /etc/locale.gen
# 生成 locale 信息.
locale-gen

# 设定 LANG 环境变量 (FIXME: 这个不执行， 看看效果)
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

# 设定 hostname
echo 'lg_gram' > /etc/hostname

echo '127.0.0.1 localhost' >> /etc/hosts
echo '127.0.0.1 lg_gram' >> /etc/hosts

function pacman () {
    pacman --noconfirm "$@"
}

function yay () {
    yay --noconfirm "$@";
}

function init_necessory () {
    pacman -Sy
    pacman -Fy

    # pacman -S pacman-contrib

    # must update this first, othersize, may install failed due required key missing from keyring.
    pacman -S archlinuxcn-keyring

    pacman -S yay

    pacman -S rsync wget net-tools man netcat cronie

    systemctl enable cronie

    pacman -S fcitx-im fcitx-sunpinyin fcitx-configtool
    # 声卡驱动, this is need for support macrophone.
    # pavucontrol is seem like not necessory.
    pacman -S alsa-utils
    # 将当前用户加入 audio 分组.
    sudo gpasswd -a zw963 audio

    pacman -S gnome gnome-extra gnome-shell-extension-appindicator \
           networkmanager network-manager-applet \
           konsole okular gparted yay

    systemctl enable NetworkManager
    systemctl enable gdm # use GDM as display manager
    systemctl enable bluetooth

    # ttf-dejavu + xorg-mkfontscale is need for emacs support active fcitx.
    # jansson for better json performance for emacs 27.1
    # hunspell for ispell
    # paps for emacs to use lpr(new_lpr) print chinese character.
    pacman -S emacs ttf-dejavu xorg-mkfontscale jansson hunspell hunspell-en_US paps
}

function init_tools () {
    pacman -S mlocate

    # pdf-printer need setup from http://127.0.0.1:631/admin
    pacman -S cups cups-pdf

    systemctl enable org.cups.cupsd

    # python-pyqt5 is need for hp-systray
    # 安装后, 运行 hp-setup -i 192.168.51.145, 来初始化打印机
    pacman -S hplip python-pyqt5
}

function init_programming () {
    # js
    pacman -S nodejs npm yarn

    # mysql, 或者 mysql-clients (archlinuxcn)
    pacman -S mariadb-clients

    # pg not split to server and client.
    pacman -S postgresql

    pacman -S libfaketime
}

pacman -S ntp mlocate ntfs-3g git tree bind tcpdump at \
       iw wpa_supplicant dialog wireless_tools \
       wol cmake

systemctl enable ntpdate
systemctl enable atd

# 分析磁盘 IO 的工具.
pacman -S sysstat iotop

# printer
# settings printer with:
# hp-setup -i 192.168.50.145 (192.168.50.145 is printer IP)
# another way is to use CUPS, http://127.0.0.1:631

# mtr工具的主要作用是在于两点丢包时候的异常点排查及路径搜集，是ping和tracert的结合。
# 相比于ping它会有路由节点的展示，而相对于tracert它会展示中间路由节点的丢包情况，
# 可以根据丢包梯度情况简单分析出可能的异常节点并向对应运营商进行反馈。
# 由于骨干外网路径可能存在的异步路由（即数据包来回路径不一致，可能在某一方向看无明显异常点，
# 另一方向才会显示异常）与ECMP（运营商在多根路径上做负载均衡，某一根异常导致部分IP丢包），
# 建议提供双向 mtr。
pacman -S traceroute mtr

# xorg-fonts is need for emacs active IM.(已验证,非必须)
# mesa-demos add glxgears command to detect display card.
pacman -S xorg-xprop xorg-xset xorg-xrandr mesa-demos

# xf86-input-libinput 提供了替代 synaptics 的接口，同时在 X 和 Wayland 下可用。
# 并且开启类似苹果的多键滑动
# xinput 用来通过命令方式设定 libinput 参数。(类似于 synclient)
pacman -S libinput-gestures
usermod -a -G input input
libinput-gestures-setup autostart

# 必装，它提供了 daemon 用来检测当前键盘是否在 typing, 并关闭 touch.
# pacman -S xf86-input-synaptics

# synaptics make touchpad can working.
# if only install synaptics, will make xmodmap broken.
# need install xf86-input-keyboard to fix it.
# xf86-input-mouse no reason to install, just try.
pacman -S xf86-input-keyboard xf86-input-mouse

pacman -S firefox chromium flashplugin next-browser

pacman -S gconf \
       wireshark-qt \
       wps-office ttf-wps-fonts \
       flameshot peek copyq albert \
       leafpad pamac-aur neofetch

pacman -S skype telegram-desktop

# 安装 tws, 如果没有声音，安装下面的包。

# use xorg
sed -r -i -e "s/#(WaylandEnable=false)/\1/" /etc/gdm/custom.conf

# poppler-data needed for pdf show chinese chars.
pacman -S poppler-data

pacman -S proxychains-ng redsocks

# qt5 is need for bcompare.
pacman -S qt5

# wine 以及浏览器支持, .NET 支持
pacman -S wine wine_gecko wine-mono

# image tools
pacman -S gimp imagemagick

# library
pacman -S llvm jdk8-openjdk nodejs npm yarn postgresql

# 安装多媒体相关的解码库及 H.264 解码支持
yay -S ffmpeg vlc gst-libav

yay -S deepin.com.qq.office
yay -S deepin.com.thunderspeed
yay -S deepin-wine-wechat
yay -S deepin-baidu-pan

# following package need be install manually after reboot.
pacman -S lutris lib32-vulkan-intel vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader

# pacman -S steam steam-native-runtime

# # nvidia tools
# pacman -S nvidia nvidia-settings nvidia-utils lib32-nvidia-utils

pacman -S virtualbox virtualbox-guest-iso virtualbox-host-modules-arch
yay -S virtualbox-ext-oracle
sudo gpasswd -a zw963 vboxusers
sudo modprobe vboxdrv

yay -S vmware-workstation

# VMWARE 网络访问
systemctl enable vmware-networks.service
# VMWARE USB 共享
systemctl enable vmware-usbarbitrator.service
# VMWARE 目录共享
systemctl enable vmware-hostd.service
# 创建一些必须的空目录, (安装 vmware 客户端工具必须)
for x in {0..6}; do mkdir -p /etc/init.d/rc${x}.d; done

# # if use linux kernel(non lts), must use virtualbox-host-modules-arch
# pacman -S virtualbox-host-modules-arch
# virtualbox_version=$(pacman -Qi virtualbox |grep 'Version' |awk -F: '{print $2}'|grep -o '[0-9]*\.[0-9]*\.[0-9]')
# wget https://download.virtualbox.org/virtualbox/6.0.8/Oracle_VM_VirtualBox_Extension_Pack-${virtualbox_version}.vbox-extpack -P ~/Downloads/
# pci=nommconf
