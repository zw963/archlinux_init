
# 如果是 vmware, 下面的包安装显卡驱动

# 安装显卡驱动, 不同的平台使用不同的包

# ATI 显卡
# pacman -S xf86-video-ati

# Nvidia
# pacman -S xf86-video-nouveau

# vmware
# pacman -S xf86-video-vmware

# Intel
pacman -S xf86-video-intel

# 如果希望安装 Nvidia 闭源驱动, 并且安装 32 程序支持
pacman -S nvidia nvidia-settings lib32-nvidia-utils mesa-demos

# 这个装上问题多多, 不装反而更好
# pacman -S bumblebee lib32-virtualgl
# gpasswd -a zw963 bumblebee
# systemctl enable bumblebeed

# 1. 取消 /etc/gdm/custom.conf 当中 WaylandEnable=false 的注释.
# 2. 修改 /etc/bumblebee/xorg.conf.nvidia
#    "AutoAddDevices" "false" 替换为 "true"
#    "UseDisplayDevice" "none" 替换为 "true"
#    Option "AllowEmptyInitialConfiguration" 新增至 Device section.

#    添加下面的 config:
#    Section "Screen"
#         Identifier "Screen0"
#         Device "DiscreteNvidia"
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
