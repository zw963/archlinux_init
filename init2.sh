#!/bin/bash

set -xe

# 运行的前提条件:
# 1. 网络已经配置好. (不配置好, 没办法使用 curl 从 github 下载这个文件.)
# 2. 已经分区(cfidsk)并格式化(mkfs.ext4 /dev/sda1), 并且成功的 mount 这个分区到 /mnt (mount /dev/sda1 /mnt)

loadkeys us # 确保设定键盘为 US 布局.

# 确保系统时间是准确的, 一定确保同步, 否则会造成签名错误.
timedatectl set-ntp true && ntpdate pool.ntp.org

# 是否需要运行下面的命令, 来使用本地时钟?
# timedatectl set-local-rtc true

# 设定上海交大源为首选源, 速度更快
sed -i '1iServer = http://ftp.sjtu.edu.cn/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
# 如果是北方网通, 清华源更快
# sed -i '1iServer = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist

# # use lts linux kernel.
# pacman -Sy
# pacman -Sg base | cut -d ' ' -f 2 | sed 's#^linux$#linux-lts#g' | pacstrap /mnt -
# pacstrap /mnt base-devel linux-lts-headers cmake \
    #          iw wpa_supplicant dialog wireless_tools net-tools

# wol 是 wake on line 工具
pacstrap /mnt base base-devel cmake iw wpa_supplicant dialog wireless_tools net-tools wol

# 添加交大的 AUR 源
cat <<'HEREDOC' >> /mnt/etc/pacman.conf
[archlinuxcn]
SigLevel = Optional TrustAll
# Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch
Server = https://mirrors.sjtug.sjtu.edu.cn/archlinux-cn/$arch
HEREDOC

# 升级时, 忽略内核和所有 nvidia 包.
sed -i 's/#IgnorePkg.*=/IgnorePkg = linux linux-headers linux-lts linux-lts-headers nvidia nvidia-lts nvidia-settings nvidia-utils virtualbox virtualbox-guest-iso virtualbox-guest-iso/' /mnt/etc/pacman.conf
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
echo 'arch_linux' > /etc/hostname

echo '127.0.0.1 localhost' >> /etc/hosts
echo '127.0.0.1 arch_linux' >> /etc/hosts

function ins () {
    pacman -S --noconfirm "$@"
}

function yao () {
    # sudo -u zw963 yaourt --m-arg "--skippgpcheck" -S --noconfirm "$@"
    sudo -u zw963 yay -S --noconfirm "$@";
}

pacman -Sy
pacman -Fy
# ins yaourt
ins yay
# sudo -u zw963 yaourt -Sy

# 声卡驱动, this is need for support macrophone.
ins alsa-utils pavucontrol
# 将当前用户加入 audio 分组.
gpasswd -a zw963 audio

ins wget rsync openssh ntp mlocate ntfs-3g git tree bind-tools gnu-netcat tcpdump
systemctl enable ntpdate

# mtr工具的主要作用是在于两点丢包时候的异常点排查及路径搜集，是ping和tracert的结合。
# 相比于ping它会有路由节点的展示，而相对于tracert它会展示中间路由节点的丢包情况，
# 可以根据丢包梯度情况简单分析出可能的异常节点并向对应运营商进行反馈。
# 由于骨干外网路径可能存在的异步路由（即数据包来回路径不一致，可能在某一方向看无明显异常点，
# 另一方向才会显示异常）与ECMP（运营商在多根路径上做负载均衡，某一根异常导致部分IP丢包），
# 建议提供双向 mtr。
ins traceroute mtr

# crontab
ins cronie
systemctl enable cronie

# xorg-fonts is need for emacs active IM.(未验证, 这里没有安装)
# mesa-demos add glxgears command to detect display card.
ins xorg-xprop xorg-xset xorg-xrandr mesa-demos

# xf86-input-libinput 提供了替代 synaptics 的接口，同时在 X 和 Wayland 下可用。
# 并且开启类似苹果的多键滑动
# xinput 用来通过命令方式设定 libinput 参数。(类似于 synclient)
ins xf86-input-libinput libinput-gestures xorg-xinput
usermod -a -G input input
libinput-gestures-setup autostart

# 必装，它提供了 daemon 用来检测当前键盘是否在 typing, 并关闭 touch.
# ins xf86-input-synaptics

# synaptics make touchpad can working.
# if only install synaptics, will make xmodmap broken.
# need install xf86-input-keyboard to fix it.
# xf86-input-mouse no reason to install, just try.
ins  xf86-input-keyboard xf86-input-mouse

# ttf-dejavu is need for emacs support active fcitx.
ins emacs ttf-dejavu wqy-microhei wqy-zenhei

ins firefox chromium flashplugin

ins gnome gnome-extra gconf budgie-desktop gparted \
    networkmanager network-manager-applet \
    konsole wireshark-qt fcitx-im fcitx-sunpinyin fcitx-configtool \
    wps-office ttf-wps-fonts \
    copyq albert \
    peek leafpad pamac-aur

ins skype telegram-desktop

systemctl enable NetworkManager
systemctl enable gdm # use GDM as display manager
systemctl enable bluetooth

# use xorg
sed -r -i -e "s/#(WaylandEnable=false)/\1/" /etc/gdm/custom.conf

# poppler-data needed for pdf show chinese chars.
ins okular poppler-data

ins proxychains-ng redsocks

# qt4 is need for bcompare.
ins qt4

# wine 以及浏览器支持, .NET 支持
ins wine wine_gecko wine-mono

# image tools
ins gimp imagemagick

# library
ins llvm jdk8-openjdk nodejs npm yarn postgresql

# 安装多媒体相关的解码库及 H.264 解码支持
yao ffmpeg vlc gst-libav

yao deepin.com.qq.office
yao deepin.com.thunderspeed
yao deepin-wine-wechat
yao deepin-baidu-pan

# following package need be install manually after reboot.

ins lutris lib32-vulkan-intel vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader

# ins steam steam-native-runtime

# # nvidia tools
# ins nvidia nvidia-settings nvidia-utils lib32-nvidia-utils

ins virtualbox virtualbox-guest-iso virtualbox-host-modules-arch
yao virtualbox-ext-oracle

# # if use linux kernel(non lts), must use virtualbox-host-modules-arch
# ins virtualbox-host-modules-arch
# ins virtualbox virtualbox-guest-iso
# gpasswd -a zw963 vboxusers
# sudo modprobe vboxdrv
# virtualbox_version=$(pacman -Qi virtualbox |grep 'Version' |awk -F: '{print $2}'|grep -o '[0-9]*\.[0-9]*\.[0-9]')
# wget https://download.virtualbox.org/virtualbox/6.0.8/Oracle_VM_VirtualBox_Extension_Pack-${virtualbox_version}.vbox-extpack -P ~/Downloads/
# pci=nommconf
