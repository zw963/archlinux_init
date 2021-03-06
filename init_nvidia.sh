#!/bin/bash

# this can be detect intel card. can be install seperately.
# pacman -S xf86-video-intel libxss

# # 需要以下三个包同时降级.
# # downgrade nvidia-lts nvidia-utils nvidia-settings

# # 安装 lts (注意和内核一致)
# pacman -S nvidia-lts nvidia-settings nvidia-utils lib32-nvidia-utils mesa-demos

# pacman -S nvidia-beta-dkms
# cat /proc/driver/nvidia/gpus/0000:01:00.0/power

pacman -R gdm
pacman -S sddm
systemctl enable sddm
pacman -S nvidia nvidia-settings nvidia-utils mesa-demos
pacman -S lib32-nvidia-utils
yay -S optimus-manager # 需要使用 sddm 来支持.

# 切换:
# optimus-manager --switch nvidia to switch to the Nvidia GPU
# optimus-manager --switch integrated to switch to the integrated GPU and power the Nvidia GPU off
# optimus-manager --switch hybrid to switch to the iGPU but leave the Nvidia GPU available for on-demand offloading, similar to how Optimus works on Windows. See the Wiki for more details.

# pacman -S bumblebee virtualgl lib32-virtualgl

# gpasswd -a zw963 bumblebee
# systemctl enable bumblebeed

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

# Following config definition, see: http://us.download.nvidia.com/XFree86/Linux-x86_64/418.56/README/xconfigoptions.html

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
