If the graphics card is not supported by Intel®, AMD® or NVIDIA® drivers, then VESA or SCFB modules should be used.
VESA module must be used when booting in BIOS mode and SCFB module must be used when booting in UEFI mode.

This command can be used to check the booting mode:

% sysctl machdep.bootmethod
The output should be similar to the following:
machdep.bootmethod: UEFI
////////////// my old laptop config
Partitioning Using Root-on-ZFS
Partition Scheme: GPT (BIOS+UEFI) // dành cho máy laptop củ của tui, các máy mới thì chỉ cần GPT (UEFI)
//////////////
freebsd-update fetch install
sysctl machdep.bootmethod
pkg
pkg update
pkg upgrade
pkg install emacs nano inxi 
pkg install nvidia-driver-390
sysrc kld_list+=nvidia
sysrc kld_list+=nvidia-modeset
pkg install xorg xorg-server xorg-fonts
startx
xrandr
////// https://forums.linuxmint.com/viewtopic.php?t=266554 ////
If command xrandr output tells something like ' xrandr: Failed to get size of gamma for output default ' .
the graphic driver may not work properly.
May be my nvidia card error or nvidia-driver-390 may not work properly.
Command inxi -G can tell something like. OpenGl or Renderer: null .or wrong
////// https://forums.linuxmint.com/viewtopic.php?t=266554 ////
inxi -G
//////
so i remove nvidia-driver-390, setup intel built-in card
pkg install drm-kmod
sysrc kld_list+=i915kms
pkg install libva-intel-driver mesa-libs mesa-dri
// murt@murt-laptop:~ $ inxi -G
inxi -G
Graphics:
  Device-1: Intel 3rd Gen Core processor Graphics driver: vgapci
  Device-2: NVIDIA GF119M [GeForce 610M] driver: vgapci
  Display: server: X.Org 1.21.1.7 driver: loaded: modesetting
    unloaded: vesa resolution: 1366x768~60Hz
  OpenGL: renderer: Mesa Intel HD Graphics 4000 (IVB GT2)
    v: 4.2 Mesa 22.3.7
// murt@murt-laptop:~ $
////////// my laptop is machdep.bootmethod: UEFI
So my xorg run SCFB modules.
murt@murt-laptop:~ $ cat /usr/local/etc/X11/xinit/xinitrc
so default, xinit run startx on all users with twm & xterm & exec xterm.
//// with https://wiki.freebsd.org/LXDE ////
1. INSTALL LXDE:
pkg install lxde-meta
OR: # cd /usr/ports/x11/lxde-meta && make install clean
2. PREPARE .xinitrc file in user`s home directory:
cd /usr/home/username - Switch to users home directory.
vi .xinitrc or ee .xinitrc - Create the new .xinitrc file & add the next two lines to the file.
ck-launch-session dbus-launch --exit-with-session startlxde
exec startlxde
3. ENABLE D-BUS:
Add this line to the existing /etc/rc.conf file:
dbus_enable="YES"
4. MOUNT PROC:
Add procfs like this to existing /etc/fstab file:
proc /proc procfs rw 0 0
5. RE-BOOT, LOGIN AS USER, AND RUN startx:
% startx
/!\ Remember, NEVER RUN STARTX AS ROOT, only as a user.
//// with https://wiki.freebsd.org/LXDE ////
So you could run multiple desktop environments on FreeBSD

////// nhập tiếng việt trong môi trường x window system (twm và xterm) /////////
------------------>Cách 1: dùng ibus 
$ pkg search ibus-m17n
ibus-m17n-1.4.27               m17n IM engine for IBus framework
$ pkg install ibus-m17n
$ ibus address
(null)
Vậy là ibus chưa start ibus-daemon, giờ ta setup ibus
$ ibus-setup 
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
Cửa sổ IBus Preferences xuất hiện, chọn Tab Input Method và chọn Add, rồi tìm vietnamese sẻ ra:
Danh sách mặt định 3 cái Vietnamese,Vietnamese(France),Vietnamese(US) và cái còn lại là của m17n: vi-vni hay vi-telex,...
Chọn 1 cái mà add vào
$ ibus restart
$ ibus address
unix:path=/tmp/dbus-XbG6xP6q,guid=0d5bbec7b0cf5630a02994e565b53f96
$ ibus-daemon 
current session already has an ibus-daemon.
$ ibus-daemon -d &        // run ibus as background process.
$ ibus list-engine|grep vie
  xkb:vn::vie - Vietnamese
  xkb:vn:us:vie - Vietnamese (US)
  xkb:vn:fr:vie - Vietnamese (France)  // 3 cái mặc định của system
$ ibus list-engine|grep vi:
  m17n:vi:nomvni - vi-nomvni (m17n)
  m17n:vi:han - vi-han (m17n)
  m17n:vi:telex - vi-telex (m17n)
  m17n:vi:nomtelex - vi-nomtelex (m17n)
  m17n:vi:vni - vi-vni (m17n)
  m17n:vi:viqr - vi-viqr (m17n)
  m17n:vi:tcvn - vi-tcvn (m17n)
$ ibus engine
m17n:vi:telex
$ ibus engine xkb:vn::vie     // thay đổi engine mình muốn
$ ibus engine
xkb:vn::vie
$ 
--------------------->Cách 2: không cần Start ibus và ibus-m17n
Dùng 3 cái mặc định của system
$ setxkbmap -query      // lấy thông tin hiện tại
rules:      evdev
model:      pc105
layout:     vn
$ setxkbmap -layout vn -variant basic
$ setxkbmap -layout vn -variant us
$ setxkbmap -layout vn -variant fr
$ setxkbmap -layout vn -variant aderty
$ setxkbmap -layout vn -variant qderty
$ setxkbmap -layout vn
$ setxkbmap -layout us
$ setxkbmap vn
$ setxkbmap us
$ cat /usr/local/share/X11/xkb/symbols/vn       //3 cái mặc định của system nằm ở đây
murt@murt-laptop:~ $ setxkbmap vn // (vn::vie) không cần Start ibus-daemon
các lệnh liên quan:
murt@murt-laptop:~ $ ibus read-config
Mặc định trên os khi Start ibus-daemon lên:
murt@murt-laptop:~ $ ibus list-engine
Sẻ show các engine, Vietnamese có ba cái mặc định: vn::vie, vn:us:vie, vn:fr:vie,
https://gist.github.com/jatcwang/ae3b7019f219b8cdc6798329108c9aee

////// nhập tiếng việt trong môi trường x window system (twm và xterm) /////////
////// copy/paste trong môi trường x window system (twm và xterm) /////////
-Trường hợp là dùng một con mouse gắn ngoài:
Nhấn giữ trái chuột chọn vùng TEXT mình muốn COPY, mình muốn PASTE ở đâu thì đến đó nhấn nút giữa chuột hay Shift + Insert
Nhấn giữ Ctrl + Chuột trái or chuột phải or con lăn ở giữ để  Main Options/ VT Fonts/ VT Options của Terminal
Nhấn giữ Alt + chuột trái or phải để di chuyển Terminal
-Trường hợp dùng touchpad:
Nhấn giữ trái chuột hay nhấn Shift chọn vùng TEXT mình muốn COPY, mình muốn PASTE ở đâu thì đến đó nhấn nút Shift và nhấn cùng lúc chuột trái và phải hay Shift + Insert
Nhấn giữ Ctrl + Chuột trái or chuột phải or nhấn cùng lúc chuột trái và phải  Main Options/ VT Fonts/ VT Options của Terminal
Nhấn giữ Alt + chuột trái or phải để di chuyển Terminal
Thêm các tính năng:
Để xuất hiện thanh Scrollbar kéo lên kéo xuống thì Nhấn giữ Ctrl + nhấn cùng lúc chuột trái và phải -> VT Options của Terminal rồi chọn "Enable Scrollbar"
Để copy & paste được từ Terminal ra bên ngoài và ngược lại thì chọn "Keep Selection" và "Select to Clipboard"
Để di chuyển thanh cuộn thì bạn di chuyển con trỏ chuột đến vị trí thanh cuộn, rồi nhấn chuột trái & phải để kéo thanh cuộn lên xuống. 
/////// copy/paste trong môi trường x window system (twm và xterm) /////////
///// Để tăng giảm vol âm lượng ////////
Dùng lệnh >mixer vol 100
là tăng âm lượng lên 100
///// Để tăng giảm vol âm lượng ////////
///// Cách dùng USB hdd-box ////////
>gpart show  ; để xem thông tin các ổ cứng trong máy
>ls -al /dev/da*	; hay dmesg để xem các usb hdd-box đả được máy nhận chưa
Thêm autofs,fusefs vào file /boot/loader.conf
autofs_enable="YES"
fusefs_load="YES"
và 
autofs_enable="YES" vào file /etc/rc.conf

Nếu máy tính nhận được thì nên check thư mục /media
$ ls -al /media/
total 10
drwxr-xr-x   4 root  wheel   4 Jan 22 17:00 .
drwxr-xr-x  20 root  wheel  27 Jan 23 10:32 ..
drwxrwxr-x   2 root  wheel   2 Jan 22 17:00 da0s1
drwxrwxr-x   2 root  wheel   2 Jan 22 17:00 da0s2
là có thể truy cập hdd-box
///// Cách dùng USB hdd-box ////////
///// KẾT NỐI WIFI //////////
# sysctl net.wlan.devices
net.wlan.devices: iwn0
# pciconf -lv | grep -B3 network
[...]
iwn0@pci0:3:0:0:	class=0x028000 rev=0x34 hdr=0x00 vendor=0x8086 device=0x0085 subvendor=0x8086 subdevice=0x1311
    vendor     = 'Intel Corporation'
    device     = 'Centrino Advanced-N 6205 [Taylor Peak]'
    class      = network
# apropos intel | grep wireless
iwm, if_iwm(4) - Intel IEEE 802.11ac wireless network driver
iwn, if_iwn(4) - Intel IEEE 802.11n wireless network driver
# man iwn
[...]
# ee /etc/rc.conf
[...]
# echo 'wlans_iwn0="wlan0"' >> /etc/rc.conf
# echo 'ifconfig_wlan0="WPA SYNCDHCP"' >> /etc/rc.conf
# cat /etc/rc.conf
[...]
wlans_iwn0="wlan0"
ifconfig_wlan0="WPA SYNCDHCP"
# ee /etc/wpa_supplicant.conf
[...]
# wpa_passphrase "SSID" "WPA2passphrase" >> /etc/wpa_supplicant.conf
# cat /etc/wpa_supplicant.conf
network={
        ssid="SSID"
        #psk="WPA2passphrase"
        psk=8f0022337a28144c1ee2ae9b7f570d978c9c014b9e3b6e7ad3bfaf816d272f60
}
# service netif restart
[...]
# ifconfig
[...]
wlan0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> metric 0 mtu 1500
        ether 8c:70:5a:bd:39:3c
# ifconfig wlan0 list scan | more
SSID/MESH ID                      BSSID              CHAN RATE    S:N     INT CAPS
[...]
GuestWiFi                         1c:af:f7:dd:9c:3b    2   54M  -66:-95   100 EPS  RSN WPA WME HTCAP ATH WPS
[...]
# wpa_passphrase "GuestWiFi" "WPA2passphrase" >> /etc/wpa_supplicant.conf
# cat /etc/wpa_supplicant.conf
[...]
network={
        ssid="GuestWiFi"
        #psk="WPA2passphrase"
        psk=8f0022337a28144c1ee2ae9b7f570d978c9c014b9e3b6e7ad3bfaf816d272f60
}
# service netif restart
[...]
# ping google.com
[...]
# bsdconfig 
# bsdconfig wireless 
///// KẾT NỐI WIFI //////////

The following command, when run on a FreeBSD 13.1 system, will upgrade it to FreeBSD 13.2:
root# freebsd-update -r 13.2-RELEASE upgrade
root# /usr/sbin/freebsd-update install
root# freebsd-update install
/// khi ko load bat ky` GPU Device na`o
murt@murt-laptop:~ $ inxi -G
Graphics:
  Device-1: Intel 3rd Gen Core processor Graphics driver: vgapci
  Device-2: NVIDIA GF119M [GeForce 610M] driver: vgapci
  Display: server: X.Org 1.21.1.8 driver: loaded: vgapci
    note: n/a (using device driver) unloaded: modesetting,vesa
    resolution: 1366x768
  OpenGL: renderer: llvmpipe (LLVM 15.0.7 256 bits) v: 4.5 Mesa 22.3.7
murt@murt-laptop:~ $ 
9
# pw group mod -n wheel -m murt
# pw group mod -n wheel -d murt
# pw group show -n wheel
pkg install vscode firefox-esr chromium 
/// config git  
  git config --global credential.helper store
  git config --global user.name "teonho"
  git config --global user.email "teo2020nho@gmail.com"
/// cau hinh git
/////////// cai dat webcam
https://vermaden.wordpress.com/2021/05/26/freebsd-desktop-part-26-configuration-conferencing-and-meetings/
root@murt_asus:/home/murt # dmesg
...
ugen1.4: <Azurewave USB2.0 UVC HD Webcam> at usbus1
...
root@murt_asus:/home/murt # pkg install v4l-utils v4l_compat webcamd pwcview
webcamd requires the cuse(3) kernel module.  
To load the driver as	a module at boot time, place the following line	in loader.conf(5):
root@murt_asus:/home/murt # nano /boot/loader.conf
	    cuse_load="YES"
To start webcamd automatically at system startup, place the following line in rc.conf(5):
root@murt_asus:/home/murt # nano /etc/rc.conf
	  webcamd_enable="YES"
root@murt_asus:/home/murt # usbconfig
ugen1.1: <Intel EHCI root HUB> at usbus1, cfg=0 md=HOST spd=HIGH (480Mbps) pwr=SAVE (0mA)
ugen0.1: <Intel XHCI root HUB> at usbus0, cfg=0 md=HOST spd=SUPER (5.0Gbps) pwr=SAVE (0mA)
ugen2.1: <Intel EHCI root HUB> at usbus2, cfg=0 md=HOST spd=HIGH (480Mbps) pwr=SAVE (0mA)
ugen0.2: <Logitech USB Optical Mouse> at usbus0, cfg=0 md=HOST spd=LOW (1.5Mbps) pwr=ON (100mA)
ugen0.3: <Generic USB2.0-CRW> at usbus0, cfg=0 md=HOST spd=HIGH (480Mbps) pwr=ON (500mA)
ugen1.2: <vendor 0x8087 product 0x0024> at usbus1, cfg=0 md=HOST spd=HIGH (480Mbps) pwr=SAVE (0mA)
ugen2.2: <vendor 0x8087 product 0x0024> at usbus2, cfg=0 md=HOST spd=HIGH (480Mbps) pwr=SAVE (0mA)
ugen1.3: <Atheros Communications Bluetooth USB Host Controller> at usbus1, cfg=0 md=HOST spd=FULL (12Mbps) pwr=ON (100mA)
ugen1.4: <Azurewave USB2.0 UVC HD Webcam> at usbus1, cfg=0 md=HOST spd=HIGH (480Mbps) pwr=ON (500mA)
root@murt_asus:/home/murt # 
root@murt_asus:/home/murt # webcamd -l
Available device(s):
webcamd [-d ugen1.1] -N Intel-EHCI-root-HUB -S unknown -M 0
webcamd [-d ugen0.1] -N Intel-XHCI-root-HUB -S unknown -M 0
webcamd [-d ugen2.1] -N Intel-EHCI-root-HUB -S unknown -M 1
webcamd [-d ugen0.2] -N Logitech-USB-Optical-Mouse -S unknown -M 0
webcamd [-d ugen0.3] -N Generic-USB2-0-CRW -S 20090516388200000 -M 0
webcamd [-d ugen1.2] -N vendor-0x8087-product-0x0024 -S unknown -M 0
webcamd [-d ugen2.2] -N vendor-0x8087-product-0x0024 -S unknown -M 1
webcamd [-d ugen1.3] -N Atheros-Communications-Bluetooth-USB-Host-Controller -S Alaska-Day-2006 -M 0
webcamd [-d ugen1.4] -N Azurewave-USB2-0-UVC-HD-Webcam -S NULL -M 0
Show webcamd usage:
webcamd -h
root@murt_asus:/home/murt # 
root@murt_asus:/home/murt # nano /etc/rc.conf
# for webcamd
webcamd_enable="YES"
webcamd_0_flags="-d ugen1.4"
root@murt_asus:/home/murt # 
root@murt_asus:/home/murt # pw groupmod webcamd -m murt
root@murt_asus:/home/murt # service webcamd onestart
Starting webcamd.
webcamd 82811 - - Webcamd is already running for ugen1.4.0
root@murt_asus:/home/murt # 
root@murt_asus:/home/murt # ls -l /dev/video*
crw-rw----  1 webcamd  webcamd  0xa3 Jul 15 21:04 /dev/video0
crw-rw----  1 webcamd  webcamd  0xa4 Jul 15 21:04 /dev/video1
root@murt_asus:/home/murt # 
root@murt_asus:/home/murt # pwcview
Webcam set to: 320x240 (sif) at 5 fps
root@murt_asus:/home/murt # pwcview -d /dev/video0 -f 30 -s uxga
Webcam set to: 1280x720 (uxga) at 30 fps
root@murt_asus:/home/murt # pkg install multimedia/cheese
root@murt_asus:/home/murt # cheese

/////////// cai dat webcam
//////// setup XDM va XSM
root@murt_asus:/home/murt # pkg install xdm xsm
# la` X display manager va` X session manager
root@murt_asus:/home/murt # nano /etc/ttys 
ttyv8   "/usr/local/bin/xdm -nodaemon"  xterm   off secure
Thay off tha`nh on:
ttyv8   "/usr/local/bin/xdm -nodaemon"  xterm   on secure
root@murt_asus:/home/murt # reboot
//////// setup XDM va XSM
$ cat /usr/local/share/X11/twm/system.twmrc
//// add background images in desktop va` setup trong suo't ca'c windows
root@murt_asus:/home/murt # pkg install feh picom
root@murt_asus:/usr/home/murt # nano /usr/local/etc/X11/xsm/system.xsm
! $Xorg: system.xsm,v 1.3 2000/08/17 19:55:06 cpqbld Exp $
picom --no-vsync
smproxy
xrdb -load /usr/home/murt/online/my_github/teonho/freebsd/twm/config/Xdefaults
xset b 100 600 50
# setxkbmap vn

# Sample .xinitrc ---------------------------------------------------------------
#
# Sets mouse cursor type unless you like the black X
xsetroot -cursor_name left_ptr
# Sets my background wallpaper
hsetroot -cover /usr/home/murt/online/my_github/teonho/freebsd/twm/themes/ecsi/ecsi_by_fkant.jpg
#xv /usr/home/murt/Downloads/uwp3838467.jpeg -root -quit
#feh --bg-fill /usr/home/murt/Downloads/pngegg.png &
# Sets the mouse behaviour / speed etc
xset m 30/10 4
# Sets the keyboard repeat rate
xset r rate 200 40
# Switch off annoying default beeps
xset -b
# Switch off X screen blanking and dpms blanking
xset s off
xset -dpms
#  Switch on chosen screensaver
xautolock -time 1 -locker "xlock -enablesaver -mode random" 
# Launch Conky
#conky --config=/usr/home/murt/online/my_github/teonho/freebsd/twm/themes/ecsi/conkyrc 
#conky 
# Launch VDesk for Virtual Desktops in TWM
vdesk 
# Finally launch TWM (The Window Manager!)
exec twm
# -------------------------------------------------------------------------------

//// add background images in desktop va` setup trong suo't ca'c windows
