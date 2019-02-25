
# 如果是 vmware, 下面的包安装显卡驱动
# pacman -S xf86-video-vmware

# ATI 显卡
# pacman -S xf86-video-ati
# Nvidia
# pacman -S xf86-video-nouveau
# Intel
pacman -S xf86-video-intel

# 如果希望安装 Nvidia 闭源驱动, 并且支持 32 位程序.
pacman -S nvidia-lts lib32-nvidia-utils nvidia-settings
pacman -S bumblebee lib32-virtualgl mesa-demos
gpasswd -a zw963 bumblebee
systemctl enable bumblebeed

pacman -S gst-libav # H.264 解码

# 1. 取消 /etc/gdm/custom.conf 当中 WaylandEnable=false 的注释.
# 2. 修改 /etc/bumblebee/xorg.conf.nvidia
#    "AutoAddDevices" "false" 替换为 "true"
#    Option "UseDisplayDevice" "none" 替换为 "true"
#    Option "AllowEmptyInitialConfiguration"
#    添加下面的 config:
#    Section "Screen"
#         Identifier "Screen0"
#         Device "DiscreteNVidia"
#     EndSection
# 3.  create /usr/share/X11/xorg.conf.d/20-intel.conf
# Section "Device"
# Identifier "intelgpu0"
# Driver "intel"
# Option "VirtualHeads" "2"
# EndSection

# 让第二显示器工作.
# run "intel-virtual-output" command.

# 测试显卡是否工作:
# optirun glxspheres64 # 64 bit
# optirun glxspheres32 # 32 bit

# 注意: DP 接口的外接显示器, DISPLAY 数字为 :8
# 查看 nvidia 设定: optirun -b none nvidia-settings -c :8
