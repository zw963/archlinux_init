#!/bin/bash

# 要安装 intel 驱动，因为启动时要使用 intel 驱动,
# 稍后要使用 intel-virtual-output 实现 triple screen.
pacman -S xf86-video-intel

# 安装 lts (注意和内核一致)
pacman -S nvidia-lts nvidia-settings lib32-nvidia-utils mesa-demos

pacman -S bumblebee lib32-virtualgl
gpasswd -a zw963 bumblebee
systemctl enable bumblebeed

sed -r -i -e "s/# (WaylandEnable=false)/\1/g" /etc/gdm/custom.conf

if ! [ -e /usr/share/X11/xorg.conf.d/20-intel.conf ]; then
    cat <<'HEREDOC' > /usr/share/X11/xorg.conf.d/20-intel.conf
Section "Device"
  Identifier "intelgpu0"
  Driver "intel"
  Option "VirtualHeads" "2"
EndSection
HEREDOC
fi

if [ -e /etc/bumblebee/xorg.conf.nvidia ]; then
    # "AutoAddDevices" "false" 替换为 "true"
    # "UseDisplayDevice" "none" 替换为 "true"
    # 新增 Option "AllowEmptyInitialConfiguration"
    # 新增最后的 screen config
    cat <<'HEREDOC' > /etc/bumblebee/xorg.conf.nvidia
Section "ServerLayout"
  Identifier  "Layout0"
  Option      "AutoAddDevices" "true"
  Option      "AutoAddGPU" "false"
EndSection

Section "Device"
  Identifier  "DiscreteNvidia"
  Driver      "nvidia"
  VendorName  "NVIDIA Corporation"
  Option "ProbeAllGpus" "false"
  Option "NoLogo" "true"
  Option "AllowEmptyInitialConfiguration" "true"
EndSection

Section "Screen"
  Identifier "Screen0"
  Device "DiscreteNvidia"
EndSection
HEREDOC
fi

# 测试显卡是否工作:
# optirun glxspheres64 # 64 bit
# optirun glxspheres32 # 32 bit

# 注意: DP 接口的外接显示器, DISPLAY 数字为 :8
# 查看 nvidia 设定: optirun -b none nvidia-settings -c :8