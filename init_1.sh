#!/bin/bash

loadkeys us # 确保设定键盘为 US 布局.

# - fdisk -l 检查所有分区
# - cfdisk /dev/the_disk_to_be_partitioned, 操作该分区
# - mkfs.ext4 /dev/sda1 格式化该分区。
# - mkswap /dev/sda2 建立 swap 分区。
# - mount /dev/sda1 /mnt 加载该分区

ip link # 确保可以正确显示当前的网卡，否则可能续需要 ip link set dev wls1 up 来启动这个 interface

# 如果使用了 wifi, 启动 iwctl, 然后根据补全，键入下面的命令： station TABwlan0 connect TABwifi

# 确保系统时间是准确的, 一定确保同步, 否则会造成签名错误.
timedatectl set-ntp true

# Windows 认为硬件时间是当地时间，而 Linux 认为硬件时间是 UTC+0 标准时间，这就很尴尬了。
# 通过  timedatectl set-local-rtc true  让 Linux 认为硬件时间是当地时间。

# 设定上海交大源为首选源, 速度更快
# sed -i '1iServer = http://ftp.sjtu.edu.cn/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
# 如果是北方网通, 清华源更快
sed -i '1iServer = https://mirrors.bfsu.edu.cn/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist

# wol 是 wake on line 工具
pacstrap /mnt linux linux-headers linux-firmware base base-devel nano curl

genfstab -U /mnt >> /mnt/etc/fstab

# # 切换到目标 root
# arch-chroot /mnt /bin/bash
