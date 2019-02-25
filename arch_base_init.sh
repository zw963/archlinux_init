
# 确保设定键盘为 US 布局.
loadkeys us
# 确保网络畅通. (使用 dhcpcd)
ping -c3 archlinux.org

# 如果这一步网络不畅通, 需要手动连接 wifi

# 确保 Wifi 设备驱动正确
lspci -k |grep 'Wireless'

# 查看当前 wifi 是那个 interface.
iwconfig

# 启动这个 interface
ip link set dev wls1 up

# 扫描 wifi
iwlist wls1 scan |grep 'SSID'
# 运行 wifi-menu 连接 wifi, 这个新的 wpa 模式似乎不工作.
# WPA/WPA2 模式下连接到 WIFI
wpa_supplicant -B -i wls1 -c < (wpa_passphrase AC66U password)

# 验证连接是否成功:
iw dev wls1 link
# 使用 DHCP, --noarp 加速分配.
dhcpcd --noarp wls1

# 如果是固定 ip 的服务器, 需要执行下面的两步, 假设 ip 为: 202.56.13.13, 网络接口为: eth0
# 注意: 这里的网络接口可能是很奇怪的名字, 需要通过 ip link 来查找.
# ip addr add 202.56.13.13/24 dev wls1
# ip route add default via 网关

# 禁用一个 interface 之前, 执行下面的两步:
# ip addr flush dev wls1
# ip route flush dev wls1

# 查看分区, 创建分区, 使用 cfdisk, 界面比较友好.
fdisk -l

# 拷贝文件到 mount 的分区, 如果没加参数, 默认只安装 base
pacstrap /mnt base base-devel cmake

pacstrap /mnt linux-lts linux-lts-headers

# 网络相关工具
pacstrap /mnt net-tools ntp openssh

# 无线网络相关联的包
pacstrap /mnt iw wpa_supplicant dialog wireless_tools
# network manager.
pacstrap /mnt networkmanager network-manager-applet

pacstrap /mnt xorg xorg-xinit xterm

# 如果是笔记本, 触摸板的 synclient 命令需要这个包.
pacstrap /mnt xf86-input-keyboard xf86-input-mouse xf86-inputpacstrap /mnt gnome

# genfstab -U /home >> /mnt/etc/fstab  # 要先 mount /home

# 设定 wpa_supplicant 配置文件, 下面的配置文件也允许 wpa_cli 工作.
cat <<'HEREDOC' > /etc/wpa_supplicant/wpa_supplicant.conf
# Giving configuration update rights to wpa_cli
ctrl_interface=/run/wpa_supplicant
ctrl_interface_group=wheel
update_config=1

# AP scanning
ap_scan=1
HEREDOC

echo 'noarp' >> /etc/dhcpcd.conf

wpa_passphrase AC66U password >> /etc/wpa_supplicant/wpa_supplicant.conf
# 开启 dhcpcd 的 hook, 当运行 dhcpcd wls1 时, 自动连接 wifi
ln -s /usr/share/dhcpcd/hooks/10-wpa_supplicant /usr/lib/dhcpcd/dhcpcd-hooks/

# 然后运行 wpa_supplicant -B -i interface -c /etc/wpa_supplicant/wpa_supplicant.conf 启动 wifi

# 修改 root 密码
passwd
# 添加新用户 zw963
useradd -m zw963
passwd zw963
echo 'zw963 ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

systemctl disable dhcpcd
systemctl enable wicd
wicd_policy_group=$(cat /etc/dbus-1/system.d/wicd.conf |grep 'policy group'|cut -d'"' -f2)
gpasswd -a zw963 $wicd_policy_group

# 安装和配置 grub, 注意, 在更改了内核版本后, 也需要运行 grub-mkconfig
# 注意：grub2-mkconfig -o /boot/grub/grub.cfg 则是升级内核后，使用 grub 启动通用的办法。
# 注意目录名，例如：centos 是 /boot/grub2/grub.cfg
pacman -Sy grub && grub-install /dev/sda && grub-mkconfig -o /boot/grub/grub.cfg
# 安装 yaourt 包管理, FIXME: bash-completion 没有安装
pacman -Sy yaourt bash-completion

# 安装 patched 版本的 wicd, 这个版本修复了 wicd-curses 总是崩溃的问题。
yaourt -S wicd-patched

# 创建一些必须的空目录, (安装 vmware 客户端工具必须)
for x in {0..6}; do mkdir -p /etc/init.d/rc${x}.d; done

# # 替换 Linux 内核为 RTS 内核:

# # 先安装 lts 版本
# sudo pacman -S linux-lts
# sudo pacman install linux-lts-headers

# # 移除当前最新版本.
# sudo pacman -Rs linux
# # 生成新的 grub 配置.
# grub-mkconfig -o /boot/grub/grub.cfg

# 重启后, 运行 dhcpcd wls1 服务, 否则上不了网.
# 最后,切记不要开启 dhcpcd 服务, 这和启动 X 之后的 NetworkManager 冲突
