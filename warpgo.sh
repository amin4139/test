#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en_US.UTF-8
red='\033[0;31m'
bblue='\033[0;34m'
yellow='\033[0;33m'
green='\033[0;32m'
plain='\033[0m'
red(){ echo -e "\033[31m\033[01m$1\033[0m";}
green(){ echo -e "\033[32m\033[01m$1\033[0m";}
yellow(){ echo -e "\033[33m\033[01m$1\033[0m";}
blue(){ echo -e "\033[36m\033[01m$1\033[0m";}
white(){ echo -e "\033[37m\033[01m$1\033[0m";}
bblue(){ echo -e "\033[34m\033[01m$1\033[0m";}
rred(){ echo -e "\033[35m\033[01m$1\033[0m";}
readtp(){ read -t5 -n26 -p "$(yellow "$1")" $2;}
readp(){ read -p "$(yellow "$1")" $2;}
[[ $EUID -ne 0 ]] && yellow "请以root模式运行脚本" && exit

start(){
yellow " 请稍等3秒……正在扫描vps类型及参数中……"
if [[ -f /etc/redhat-release ]]; then
release="Centos"
elif cat /etc/issue | grep -q -E -i "debian"; then
release="Debian"
elif cat /etc/issue | grep -q -E -i "ubuntu"; then
release="Ubuntu"
elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
release="Centos"
elif cat /proc/version | grep -q -E -i "debian"; then
release="Debian"
elif cat /proc/version | grep -q -E -i "ubuntu"; then
release="Ubuntu"
elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
release="Centos"
else 
red "不支持你当前系统，请选择使用Ubuntu,Debian,Centos系统。" && rm -f CFwarp.sh && exit
fi
vsid=`grep -i version_id /etc/os-release | cut -d \" -f2 | cut -d . -f1`
sys(){
[ -f /etc/os-release ] && grep -i pretty_name /etc/os-release | cut -d \" -f2 && return
[ -f /etc/lsb-release ] && grep -i description /etc/lsb-release | cut -d \" -f2 && return
[ -f /etc/redhat-release ] && awk '{print $0}' /etc/redhat-release && return;}
op=`sys`
version=`uname -r | awk -F "-" '{print $1}'`
main=`uname  -r | awk -F . '{print $1}'`
minor=`uname -r | awk -F . '{print $2}'`
bit=`uname -m`
[[ $bit = x86_64 ]] && cpu=amd64
[[ $bit = aarch64 ]] && cpu=arm64
vi=`systemd-detect-virt`
if [[ $vi = openvz ]]; then
TUN=$(cat /dev/net/tun 2>&1)
if [[ ! $TUN =~ 'in bad state' ]] && [[ ! $TUN =~ '处于错误状态' ]] && [[ ! $TUN =~ 'Die Dateizugriffsnummer ist in schlechter Verfassung' ]]; then 
red "检测到未开启TUN，现尝试添加TUN支持" && sleep 4
cd /dev
mkdir net
mknod net/tun c 10 200
chmod 0666 net/tun
TUN=$(cat /dev/net/tun 2>&1)
if [[ ! $TUN =~ 'in bad state' ]] && [[ ! $TUN =~ '处于错误状态' ]] && [[ ! $TUN =~ 'Die Dateizugriffsnummer ist in schlechter Verfassung' ]]; then 
green "添加TUN支持失败，建议与VPS厂商沟通或后台设置开启" && exit
else
cat <<EOF > /root/tun.sh
#!/bin/bash
cd /dev
mkdir net
mknod net/tun c 10 200
chmod 0666 net/tun
EOF
chmod +x /root/tun.sh
grep -qE "^ *@reboot root bash /root/tun.sh >/dev/null 2>&1" /etc/crontab || echo "@reboot root bash /root/tun.sh >/dev/null 2>&1" >> /etc/crontab
green "TUN守护功能已启动"
fi
fi
fi
if [[ ! -f /root/nf || ! -s /root/nf ]]; then
wget -O nf https://raw.githubusercontent.com/rkygogo/netflix-verify/main/nf_linux_$cpu
chmod +x nf
fi
[[ $(type -P yum) ]] && yumapt='yum -y' || yumapt='apt -y'
[[ $(type -P curl) ]] || (yellow "检测到curl未安装，升级安装中" && $yumapt update;$yumapt install curl)
[[ $(type -P bc) ]] || ($yumapt update;$yumapt install bc)
[[ ! $(type -P qrencode) ]] && ($yumapt update;$yumapt install qrencode)
[[ ! $(type -P python3) ]] && (yellow "检测到python3未安装，升级安装中" && $yumapt update;$yumapt install python3)
[[ ! $(type -P screen) ]] && (yellow "检测到screen未安装，升级安装中" && $yumapt update;$yumapt install screen)
}

get_char(){
SAVEDSTTY=`stty -g`
stty -echo
stty cbreak
dd if=/dev/tty bs=1 count=1 2> /dev/null
stty -raw
stty echo
stty $SAVEDSTTY
}

v4v6(){
v6=$(curl -s6m6 ip.p3terx.com -k | sed -n 1p)
v4=$(curl -s4m6 ip.p3terx.com -k | sed -n 1p)
}

dig9(){
if [[ -n $(grep 'DiG 9' /etc/hosts) ]]; then
echo -e "search blue.kundencontroller.de\noptions rotate\nnameserver 2a02:180:6:5::1c\nnameserver 2a02:180:6:5::4\nnameserver 2a02:180:6:5::1e\nnameserver 2a02:180:6:5::1d" > /etc/resolv.conf
fi
}

first4(){
checkwgcf
if [[ $wgcfv4 =~ on|plus && -z $wgcfv6 ]]; then
[[ -n /etc/gai.conf ]] && grep -qE '^ *precedence ::ffff:0:0/96  100' /etc/gai.conf || echo 'precedence ::ffff:0:0/96  100' >> /etc/gai.conf
sed -i '/^label 2002::\/16   2/d' /etc/gai.conf
else
sed -i '/^precedence ::ffff:0:0\/96  100/d;/^label 2002::\/16   2/d' /etc/gai.conf
fi
}

STOPwgcf(){
if [[ -n $(type -P warp-cli) ]]; then
red "已安装Socks5-WARP(+)，不支持当前选择的WARP安装方案" 
systemctl restart warp-go ; bash CFwarp.sh
fi
}

warpwgcf(){
if [[ -n $(type -P wg-quick) ]]; then
red "请先卸载已安装的WGCF-WARP，否则无法安装当前的WARP-GO，脚本退出" && exit
fi
}

lncf(){
if [[ -n $(type -P warp-go) || -n $(type -P warp-cli) ]]; then
chmod +x /root/CFwarp.sh 
ln -sf /root/CFwarp.sh /usr/bin/cf
fi
}

checkwgcf(){
wgcfv6=$(curl -s6m6 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2) 
wgcfv4=$(curl -s4m6 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2) 
}

ShowWGCF(){
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36"
v4v6
warppflow=$((`grep -oP '"quota":\K\d+' <<< $(curl -sm4 "https://api.cloudflareclient.com/v0a884/reg/$(grep 'Device' /usr/local/bin/warp.conf 2>/dev/null | cut -d= -f2 | sed 's# ##g')" -H "User-Agent: okhttp/3.12.1" -H "Authorization: Bearer $(grep 'Device' /usr/local/bin/warp.conf 2>/dev/null | cut -d= -f2 | sed 's# ##g')")`))
flow=`echo "scale=2; $warppflow/1000000000" | bc`
[[ -e /usr/local/bin/warpplus.log ]] && cfplus="WARP+普通账户(有限WARP+流量：$flow GB)，设备名称：$(grep -s 'Device name' /etc/wireguard/wgcf+p.log | awk '{ print $NF }')" || cfplus="WARP+Teams账户(无限WARP+流量)"
if [[ -n $v4 ]]; then
wgcfv4=$(curl -sm4 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2) 
isp4a=`curl -sm6 --user-agent "${UA_Browser}" http://ip-api.com/json/$v4?lang=zh-CN -k | cut -f13 -d ":" | cut -f2 -d '"'`
isp4b=`curl -sm6 --user-agent "${UA_Browser}" https://api.ip.sb/geoip/$v4 -k | awk -F "isp" '{print $2}' | awk -F "offset" '{print $1}' | sed "s/[,\":]//g"`
[[ -n $isp4a ]] && isp4=$isp4a || isp4=$isp4b
nonf=$(curl -sm6 --user-agent "${UA_Browser}" http://ip-api.com/json/$v4?lang=zh-CN -k | cut -f2 -d"," | cut -f4 -d '"')
sunf=$(./nf | awk '{print $1}' | sed -n '4p')
snnf=$(curl -s4m6 ip.p3terx.com -k | sed -n 2p | awk '{print $3}')
if [[ -n $sunf ]]; then
country=$sunf
elif [[ -z $sunf && -n $nonf ]]; then
country=$nonf
else
country=$snnf
fi
case ${wgcfv4} in 
plus) 
WARPIPv4Status=$(white "WARP+状态：\c" ; rred "运行中，$cfplus" ; white " 服务商 Cloudflare 获取IPV4地址：\c" ; rred "$v4  $country" ; white " 奈飞NF解锁情况：\c" ; rred "$(./nf | awk '{print $1}' | sed -n '3p')");;  
on) 
WARPIPv4Status=$(white "WARP状态：\c" ; green "运行中，WARP普通账户(无限WARP流量)" ; white " 服务商 Cloudflare 获取IPV4地址：\c" ; green "$v4  $country" ; white " 奈飞NF解锁情况：\c" ; green "$(./nf | awk '{print $1}' | sed -n '3p')");;
off) 
WARPIPv4Status=$(white "WARP状态：\c" ; yellow "关闭中" ; white " 服务商 $isp4 获取IPV4地址：\c" ; yellow "$v4  $country" ; white " 奈飞NF解锁情况：\c" ; yellow "$(./nf | awk '{print $1}' | sed -n '3p')");; 
esac 
else
WARPIPv4Status=$(white "IPV4状态：\c" ; red "不存在IPV4地址 ")
fi 
if [[ -n $v6 ]]; then
wgcfv6=$(curl -sm6 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2) 
isp6a=`curl -sm6 --user-agent "${UA_Browser}" http://ip-api.com/json/$v6?lang=zh-CN -k | cut -f13 -d":" | cut -f2 -d '"'`
isp6b=`curl -sm6 --user-agent "${UA_Browser}" https://api.ip.sb/geoip/$v6 -k | awk -F "isp" '{print $2}' | awk -F "offset" '{print $1}' | sed "s/[,\":]//g"`
[[ -n $isp6a ]] && isp6=$isp6a || isp6=$isp6b
nonf=$(curl -sm6 --user-agent "${UA_Browser}" http://ip-api.com/json/$v6?lang=zh-CN -k | cut -f2 -d"," | cut -f4 -d '"')
sunf=$(./nf | awk '{print $1}' | sed -n '8p')
snnf=$(curl -s6m6 ip.p3terx.com -k | sed -n 2p | awk '{print $3}')
if [[ -n $sunf ]]; then
country=$sunf
elif [[ -z $sunf && -n $nonf ]]; then
country=$nonf
else
country=$snnf
fi
case ${wgcfv6} in 
plus) 
WARPIPv6Status=$(white "WARP+状态：\c" ; rred "运行中，$cfplus" ; white " 服务商 Cloudflare 获取IPV6地址：\c" ; rred "$v6  $country" ; white " 奈飞NF解锁情况：\c" ; rred "$(./nf | awk '{print $1}' | sed -n '7p')");;  
on) 
WARPIPv6Status=$(white "WARP状态：\c" ; green "运行中，WARP普通账户(无限WARP流量)" ; white " 服务商 Cloudflare 获取IPV6地址：\c" ; green "$v6  $country" ; white " 奈飞NF解锁情况：\c" ; green "$(./nf | awk '{print $1}' | sed -n '7p')");;
off) 
WARPIPv6Status=$(white "WARP状态：\c" ; yellow "关闭中" ; white " 服务商 $isp6 获取IPV6地址：\c" ; yellow "$v6  $country" ; white " 奈飞NF解锁情况：\c" ; yellow "$(./nf | awk '{print $1}' | sed -n '7p')");;
esac 
else
WARPIPv6Status=$(white "IPV6状态：\c" ; red "不存在IPV6地址 ")
fi 
}

docker(){
if [[ -n $(ip a | grep docker) ]]; then
red "检测到VPS已安装docker，如继续安装WARP，docker所有功能会失效"
sleep 3s
yellow "6秒后将继续自动安装，退出安装请按Ctrl+c"
sleep 6s
fi
}

wgo1='sed -i "s#.*AllowedIPs.*#AllowedIPs = 0.0.0.0/0#g" /usr/local/bin/warp.conf'
wgo2='sed -i "s#.*AllowedIPs.*#AllowedIPs = ::/0#g" /usr/local/bin/warp.conf'
wgo3='sed -i "s#.*AllowedIPs.*#AllowedIPs = 0.0.0.0/0,::/0#g" /usr/local/bin/warp.conf'
wgo4='sed -i "/Endpoint6/d" /usr/local/bin/warp.conf && sed -i "s/162.159.*/162.159.193.10:1701/g" /usr/local/bin/warp.conf'
wgo5='sed -i "/Endpoint6/d" /usr/local/bin/warp.conf && sed -i "s/162.159.*/[2606:4700:d0::a29f:c003]:1701/g" /usr/local/bin/warp.conf'
wgo6='sed -i "s#.*PostUp.*#PostUp = ip -4 rule add from $(ip route get 1.1.1.1 | grep -oP "src \K\S+") lookup main#g;s#.*PostDown.*#PostDown = ip -4 rule delete from $(ip route get 1.1.1.1 | grep -oP "src \K\S+") lookup main#g" /usr/local/bin/warp.conf'
wgo7='sed -i "s#.*PostUp.*#PostUp = ip -6 rule add from $(ip route get 2606:4700:4700::1111 | grep -oP "src \K\S+") lookup main#g;s#.*PostDown.*#PostDown = ip -6 rule delete from $(ip route get 2606:4700:4700::1111 | grep -oP "src \K\S+") lookup main#g" /usr/local/bin/warp.conf'
wgo8='sed -i "s#.*PostUp.*#PostUp = ip -4 rule add from $(ip route get 1.1.1.1 | grep -oP "src \K\S+") lookup main; ip -6 rule add from $(ip route get 2606:4700:4700::1111 | grep -oP "src \K\S+") lookup main#g;s#.*PostDown.*#PostDown = ip -4 rule delete from $(ip route get 1.1.1.1 | grep -oP "src \K\S+") lookup main; ip -6 rule delete from $(ip route get 2606:4700:4700::1111 | grep -oP "src \K\S+") lookup main#g" /usr/local/bin/warp.conf'

CheckWARP(){
i=0
systemctl stop warp-go >/dev/null 2>&1
while [ $i -le 4 ]; do let i++
yellow "共执行5次，第$i次获取warp的IP中……"
systemctl restart warp-go >/dev/null 2>&1
checkwgcf
[[ $wgcfv4 =~ on|plus || $wgcfv6 =~ on|plus ]] && green "恭喜！warp的IP获取成功！" && break || red "遗憾！warp的IP获取失败"
done
checkwgcf
if [[ ! $wgcfv4 =~ on|plus && ! $wgcfv6 =~ on|plus ]]; then
yellow "安装WARP失败，还原VPS，卸载WARP组件中……"
unwarp
green "安装WARP失败，建议如下："
[[ $release = Centos && ${vsid} -lt 7 ]] && yellow "当前系统版本号：Centos $vsid \n建议使用 Centos 7 以上系统 " 
[[ $release = Ubuntu && ${vsid} -lt 18 ]] && yellow "当前系统版本号：Ubuntu $vsid \n建议使用 Ubuntu 18 以上系统 " 
[[ $release = Debian && ${vsid} -lt 10 ]] && yellow "当前系统版本号：Debian $vsid \n建议使用 Debian 10 以上系统 "
yellow "1、强烈建议使用官方源升级系统及内核加速！如已使用第三方源及内核加速，请务必更新到最新版，或重置为官方源"
yellow "2、部分VPS系统极度精简，相关依赖需自行安装后再尝试"
exit
else 
green "ok"
fi
xyz(){
att
[[ -e /root/check.sh ]] && screen -S aw -X quit ; screen -UdmS aw bash -c '/bin/bash /root/check.sh'
[[ -e /root/WARP-CR.sh ]] && screen -S cr -X quit ; screen -UdmS cr bash -c '/bin/bash /root/WARP-CR.sh'
[[ -e /root/WARP-CP.sh ]] && screen -S cp -X quit ; screen -UdmS cp bash -c '/bin/bash /root/WARP-CP.sh'
if [[ -e /root/WARP-UP.sh ]]; then
screen -S up -X quit ; screen -UdmS up bash -c '/bin/bash /root/WARP-UP.sh'
else
green "安装warp在线监测守护进程"
cat>/root/WARP-UP.sh<<-\EOF
#!/bin/bash
red(){ echo -e "\033[31m\033[01m$1\033[0m";}
green(){ echo -e "\033[32m\033[01m$1\033[0m";}
checkwgcf(){
wgcfv6=$(curl -s6m6 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2) 
wgcfv4=$(curl -s4m6 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2) 
}
warpclose(){
wg-quick down wgcf >/dev/null 2>&1 ; systemctl stop wg-quick@wgcf >/dev/null 2>&1 ; systemctl disable wg-quick@wgcf >/dev/null 2>&1
}
warpopen(){
wg-quick down wgcf >/dev/null 2>&1 ; systemctl enable wg-quick@wgcf >/dev/null 2>&1 ; systemctl start wg-quick@wgcf >/dev/null 2>&1 ; systemctl restart wg-quick@wgcf >/dev/null 2>&1
}
warpre(){
i=0
while [ $i -le 4 ]; do let i++
warpopen
checkwgcf
[[ $wgcfv4 =~ on|plus || $wgcfv6 =~ on|plus ]] && green "中断后的warp尝试获取IP成功！" && break || red "中断后的warp尝试获取IP失败！"
done
checkwgcf
if [[ ! $wgcfv4 =~ on|plus && ! $wgcfv6 =~ on|plus ]]; then
warpclose
red "由于5次尝试获取warp的IP失败，现执行停止并关闭warp，VPS恢复原IP状态"
fi
}
while true; do
green "检测warp是否启动中…………"
checkwgcf
[[ $wgcfv4 =~ on|plus || $wgcfv6 =~ on|plus ]] && green "恭喜！warp状态为运行中！下轮检测将在你设置的60秒后自动执行" && sleep 60s || (warpre ; green "下轮检测将在你设置的50秒后自动执行" ; sleep 50s)
done
EOF
readp "warp状态为运行时，重新检测warp状态间隔时间（回车默认60秒）,请输入间隔时间（例：50秒，输入50）:" stop
[[ -n $stop ]] && sed -i "s/60s/${stop}s/g;s/60秒/${stop}秒/g" /root/WARP-UP.sh || green "默认间隔60秒"
readp "warp状态为中断时(连续5次失败自动关闭warp)，继续检测WARP状态间隔时间（回车默认50秒）,请输入间隔时间（例：50秒，输入50）:" goon
[[ -n $goon ]] && sed -i "s/50s/${goon}s/g;s/50秒/${goon}秒/g" /root/WARP-UP.sh || green "默认间隔50秒"
[[ -e /root/WARP-UP.sh ]] && screen -S up -X quit ; screen -UdmS up bash -c '/bin/bash /root/WARP-UP.sh'
green "设置screen窗口名称'up'" && sleep 2
grep -qE "^ *@reboot root screen -UdmS up bash -c '/bin/bash /root/WARP-UP.sh' >/dev/null 2>&1" /etc/crontab || echo "@reboot root screen -UdmS up bash -c '/bin/bash /root/WARP-UP.sh' >/dev/null 2>&1" >> /etc/crontab
green "添加warp在线守护进程功能"
fi
}
}

nat4(){
[[ -n $(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+') ]] && wpgo4=$wgo6 || wpgo4=echo
}

WGCFv4(){
yellow "稍等3秒，检测VPS内warp环境"
docker && checkwgcf
if [[ ! $wgcfv4 =~ on|plus && ! $wgcfv6 =~ on|plus ]]; then
v4v6
if [[ -n $v4 && -n $v6 ]]; then
green "当前原生v4+v6双栈vps首次安装warp\n现添加WARP IPV4（IP出站表现：原生 IPV6 + WARP IPV4）" && sleep 2
wpgo1=$wgo1 && wpgo2=$wgo4 && wpgo3=$wgo8 && WGCFins
fi
if [[ -n $v6 && -z $v4 ]]; then
green "当前原生v6单栈vps首次安装warp\n现添加WARP IPV4（IP出站表现：原生 IPV6 + WARP IPV4）" && sleep 2
wpgo1=$wgo1 && wpgo2=$wgo5 && wpgo3=$wgo7 && nat4 && WGCFins
fi
if [[ -z $v6 && -n $v4 ]]; then
green "当前原生v4单栈vps首次安装warp\n现添加WARP IPV4（IP出站表现：仅WARP IPV4）" && sleep 2
STOPwgcf ; wpgo1=$wgo1 && wpgo2=$wgo4 && wpgo3=$wgo6 && WGCFins
fi
first4
else
systemctl stop warp-go >/dev/null 2>&1
sleep 1 && v4v6
if [[ -n $v4 && -n $v6 ]]; then
green "当前原生v4+v6双栈vps已安装warp\n现快速切换WARP IPV4（IP出站表现：原生 IPV6 + WARP IPV4）" && sleep 2
wpgo1=$wgo1 && wpgo2=$wgo4 && wpgo3=$wgo8 && ABC
fi
if [[ -n $v6 && -z $v4 ]]; then
green "当前原生v6单栈vps已安装warp\n现快速切换WARP IPV4（IP出站表现：原生 IPV6 + WARP IPV4）" && sleep 2
wpgo1=$wgo1 && wpgo2=$wgo5 && wpgo3=$wgo7 && nat4 && ABC
fi
if [[ -z $v6 && -n $v4 ]]; then
green "当前原生v4单栈vps已安装warp\n现快速切换WARP IPV4（IP出站表现：仅WARP IPV4）" && sleep 2
STOPwgcf && wpgo1=$wgo1 && wpgo2=$wgo4 && wpgo3=$wgo6 && ABC
fi
CheckWARP && first4 && ShowWGCF && WGCFmenu
fi
}

WGCFv6(){
yellow "稍等3秒，检测VPS内warp环境"
docker && checkwgcf
if [[ ! $wgcfv4 =~ on|plus && ! $wgcfv6 =~ on|plus ]]; then
v4v6
if [[ -n $v4 && -n $v6 ]]; then
green "当前原生v4+v6双栈vps首次安装warp\n现添加WARP IPV6（IP出站表现：原生 IPV4 + WARP IPV6）" && sleep 2
wpgo1=$wgo2 && wpgo2=$wgo4 && wpgo3=$wgo8 && WGCFins
fi
if [[ -n $v6 && -z $v4 ]]; then
green "当前原生v6单栈vps首次安装warp\n现添加WARP IPV6（IP出站表现：仅WARP IPV6）" && sleep 2
wpgo1=$wgo2 && wpgo2=$wgo5 && wpgo3=$wgo7 && nat4 && WGCFins
fi
if [[ -z $v6 && -n $v4 ]]; then
green "当前原生v4单栈vps首次安装warp\n现添加WARP IPV6（IP出站表现：原生 IPV4 + WARP IPV6）" && sleep 2
wpgo1=$wgo2 && wpgo2=$wgo4 && wpgo3=$wgo6 && WGCFins
fi
else
systemctl stop warp-go >/dev/null 2>&1
sleep 1 && v4v6
if [[ -n $v4 && -n $v6 ]]; then
green "当前原生v4+v6双栈vps已安装warp\n现快速切换WARP IPV6（IP出站表现：原生 IPV4 + WARP IPV6）" && sleep 2
wpgo1=$wgo2 && wpgo2=$wgo4 && wpgo3=$wgo8 && ABC
fi
if [[ -n $v6 && -z $v4 ]]; then
green "当前原生v6单栈vps已安装warp\n现快速切换WARP IPV6（IP出站表现：仅WARP IPV6）" && sleep 2
wpgo1=$wgo2 && wpgo2=$wgo5 && wpgo3=$wgo7 && nat4 && ABC
fi
if [[ -z $v6 && -n $v4 ]]; then
green "当前原生v4单栈vps已安装warp\n现快速切换WARP IPV6（IP出站表现：原生 IPV4 + WARP IPV6）" && sleep 2
wpgo1=$wgo2 && wpgo2=$wgo4 && wpgo3=$wgo6 && ABC
fi
CheckWARP && first4 && ShowWGCF && WGCFmenu
fi
}

WGCFv4v6(){
yellow "稍等3秒，检测VPS内warp环境"
docker && checkwgcf
if [[ ! $wgcfv4 =~ on|plus && ! $wgcfv6 =~ on|plus ]]; then
v4v6
if [[ -n $v4 && -n $v6 ]]; then
green "当前原生v4+v6双栈vps首次安装warp\n现添加WARP IPV4+IPV6（IP出站表现：WARP双栈 IPV4 + IPV6）" && sleep 2
STOPwgcf ; wpgo1=$wgo3 && wpgo2=$wgo4 && wpgo3=$wgo8 && WGCFins
fi
if [[ -n $v6 && -z $v4 ]]; then
green "当前原生v6单栈vps首次安装warp\n现添加WARP IPV4+IPV6（IP出站表现：WARP双栈 IPV4 + IPV6）" && sleep 2
STOPwgcf ; wpgo1=$wgo3 && wpgo2=$wgo5 && wpgo3=$wgo7 && nat4 && WGCFins
fi
if [[ -z $v6 && -n $v4 ]]; then
green "当前原生v4单栈vps首次安装warp\n现添加WARP IPV4+IPV6（IP出站表现：WARP双栈 IPV4 + IPV6）" && sleep 2
STOPwgcf ; wpgo1=$wgo3 && wpgo2=$wgo4 && wpgo3=$wgo6 && WGCFins
fi
else
systemctl stop warp-go >/dev/null 2>&1
sleep 1 && v4v6
if [[ -n $v4 && -n $v6 ]]; then
green "当前原生v4+v6双栈vps已安装warp\n现快速切换WARP IPV4+IPV6（IP出站表现：WARP双栈 IPV4 + IPV6）" && sleep 2
STOPwgcf && wpgo1=$wgo3 && wpgo2=$wgo4 && wpgo3=$wgo8 && ABC
fi
if [[ -n $v6 && -z $v4 ]]; then
green "当前原生v6单栈vps已安装warp\n现快速切换WARP IPV4+IPV6（IP出站表现：WARP双栈 IPV4 + IPV6）" && sleep 2
STOPwgcf && wpgo1=$wgo3 && wpgo2=$wgo5 && wpgo3=$wgo7 && nat4 && ABC
fi
if [[ -z $v6 && -n $v4 ]]; then
green "当前原生v4单栈vps已安装warp\n现快速切换WARP IPV4+IPV6（IP出站表现：WARP双栈 IPV4 + IPV6）" && sleep 2
STOPwgcf && wpgo1=$wgo3 && wpgo2=$wgo4 && wpgo3=$wgo6 && ABC
fi
CheckWARP && first4 && ShowWGCF && WGCFmenu
fi
}

ABC(){
echo $wpgo1 | sh
echo $wpgo2 | sh
echo $wpgo3 | sh
echo $wpgo4 | sh
}

WGCFins(){
if [[ $release = Centos ]]; then
if [[ ${vsid} =~ 8 ]]; then
cd /etc/yum.repos.d/ && mkdir backup && mv *repo backup/ 
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-8.repo
sed -i -e "s|mirrors.cloud.aliyuncs.com|mirrors.aliyun.com|g " /etc/yum.repos.d/CentOS-*
sed -i -e "s|releasever|releasever-stream|g" /etc/yum.repos.d/CentOS-*
yum clean all && yum makecache
fi
yum install epel-release -y;yum install iproute iptables wireguard-tools -y
elif [[ $release = Debian ]]; then
apt install lsb-release -y
echo "deb http://deb.debian.org/debian $(lsb_release -sc)-backports main" | tee /etc/apt/sources.list.d/backports.list
apt update -y;apt install iproute2 openresolv dnsutils iptables -y;apt install wireguard-tools --no-install-recommends -y      		
elif [[ $release = Ubuntu ]]; then
apt update -y;apt install iproute2 openresolv dnsutils iptables -y;apt install wireguard-tools --no-install-recommends -y			
fi
wget -N https://github.com/rkygogo/wlgadego/raw/main/warp-go_1.0.5_linux_${cpu} -O /usr/local/bin/warp-go && chmod +x /usr/local/bin/warp-go
until [[ -e /usr/local/bin/warp.conf ]]; do
yellow "正在申请WARP普通账户，请稍等"
/usr/local/bin/warp-go --register --config=/usr/local/bin/warp.conf >/dev/null 2>&1
done
cat > /lib/systemd/system/warp-go.service << EOF
[Unit]
Description=warp-go service
After=network.target
Documentation=https://gitlab.com/ProjectWARP/warp-go
[Service]
WorkingDirectory=/root/
ExecStart=/usr/local/bin/warp-go --config=/usr/local/bin/warp.conf
Environment="LOG_LEVEL=verbose"
RemainAfterExit=yes
Restart=always
[Install]
WantedBy=multi-user.target
EOF
ABC
systemctl daemon-reload
systemctl enable warp-go
systemctl start warp-go
CheckWARP && ShowWGCF && WGCFmenu && lncf
}


warpinscha(){
yellow "提示：VPS的本地出站IP将被你选择的warp的IP所接管，如VPS本地无该出站IP，则被另外生成warp的IP所接管"
echo
yellow "如果你什么都不懂，回车便是！！！"
echo
green "1. 安装/切换WARP单栈IPV4（回车默认）"
green "2. 安装/切换WARP单栈IPV6"
green "3. 安装/切换WARP双栈IPV4+IPV6"
readp "\n请选择：" wgcfwarp
if [ -z "${wgcfwarp}" ] || [ $wgcfwarp == "1" ];then
WGCFv4
elif [ $wgcfwarp == "2" ];then
WGCFv6
elif [ $wgcfwarp == "3" ];then
WGCFv4v6
else 
red "输入错误，请重新选择" && warpinscha
fi
echo
}  

WGCFmenu(){
white "------------------------------------------------------------------------------------"
white " 当前 IPV4 接管出站流量情况如下 "
white " ${WARPIPv4Status}"
white "------------------------------------------------------------------------------------"
white " 当前 IPV6 接管出站流量情况如下"
white " ${WARPIPv6Status}"
white "------------------------------------------------------------------------------------"
}
back(){
white "------------------------------------------------------------------------------------"
white " 回主菜单，请按任意键"
white " 退出脚本，请按Ctrl+C"
get_char && bash CFwarp.sh
}

IP_Status_menu(){
WGCFmenu 
}

warprefresh(){
wget -N https://gitlab.com/rwkgyg/CFwarp/raw/main/wp-plus.py 
sed -i "27 s/[(][^)]*[)]//g" wp-plus.py
readp "客户端配置ID(36个字符)：" ID
sed -i "27 s/input/'$ID'/" wp-plus.py
python3 wp-plus.py
}

WARPup(){
[[ ! $(type -P warp-go) ]] && red "未安装WARP" && bash CFwarp.sh
yellow "稍等3秒，检测VPS内warp环境"
systemctl stop warp-go >/dev/null 2>&1 
v4v6
allowips=$(cat /usr/local/bin/warp.conf | grep AllowedIPs)
if [[ -n $v4 && -n $v6 ]]; then
endpoint=$wgo4
post=$wgo8
elif [[ -n $v6 && -z $v4 ]]; then
endpoint=$wgo5
[[ -n $(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+') ]] && post=$wgo8 || post=$wgo7
elif [[ -z $v6 && -n $v4 ]]; then
endpoint=$wgo4
post=$wgo6
fi

freewarp(){
red "当前执行：申请WARP普通账户"
until [[ -e /usr/local/bin/warp.conf ]]; do
yellow "正在申请WARP普通账户，请稍等"
/usr/local/bin/warp-go --register --config=/usr/local/bin/warp.conf >/dev/null 2>&1
done
sed -i "s#.*AllowedIPs.*#$allowips#g" /usr/local/bin/warp.conf
echo $endpoint | sh
echo $post | sh
systemctl restart warp-go
}

yellow "请选择切换的账户类型"
green "1. 普通WARP免费账户（无限流量）"
green "2. WARP+账户（有限流量）"
green "3. WARP Teams (Zero Trust)团队账户（无限流量）"
readp "请选择账户类型：" warpup
if [[ $warpup == 1 ]]; then
freewarp
CheckWARP && ShowWGCF && WGCFmenu
fi

if [[ $warpup == 2 ]]; then
readp "请确保手机上的warp客户端已处于warp+状态，复制按键许可证秘钥(26个字符):" ID
readp "设备名称重命名(直接回车随机命名): " dname
yellow "正在申请WARP+账户，请稍等"
/usr/local/bin/warp-go --register --config=/usr/local/bin/warp.conf --license=$ID --device-name=$dname >/dev/null 2>&1
sed -i "s#.*AllowedIPs.*#$allowips#g" /usr/local/bin/warp.conf
echo $endpoint | sh
echo $post | sh
systemctl restart warp-go
checkwgcf
if [[ $wgcfv4 = plus || $wgcfv6 = plus ]]; then
echo "$dname" >> /usr/local/bin/warpplus.log && echo "$ID" >> /usr/local/bin/warpplus.log
green "WARP+ 账户升级成功！" 
else
red "WARP+账户升级失败！"
green "建议如下："
yellow "1. 检查1.1.1.1 APP中的WARP+账户是否有流量"
yellow "2. 检查当前WARP许可证密钥绑定的设备超过5台，请进入手机端进行设备移除再尝试升级WARP+账户" && sleep 3
echo
freewarp
CheckWARP && ShowWGCF && WGCFmenu
fi
fi
    
if [[ $warpup == 3 ]]; then
readp "请输入Teams账户TOKEN: " token
rm -f /usr/local/bin/warp.conf
/usr/local/bin/warp-go --register --config=/usr/local/bin/warp.conf --team-config "$token"
sed -i "s#.*AllowedIPs.*#$currallowips#g" /usr/local/bin/warp.conf
echo $endpoint | sh
echo $post | sh
systemctl restart warp-go
checkwgcf
if [[ $wgcfv4 = plus || $wgcfv6 = plus ]]; then
green "WARP Teams账户升级成功！" 
else
red "WARP Teams账户升级失败！"
freewarp
CheckWARP && ShowWGCF && WGCFmenu
fi
fi
}

WARPonoff(){
[[ ! $(type -P warp-go) ]] && red "WARP未安装，建议重新安装" && bash CFwarp.sh
readp "1. 关闭WARP功能\n2. 开启/重启WARP功能\n0. 返回上一层\n 请选择：" unwp
if [ $unwp == "1" ]; then
systemctl stop warp-go >/dev/null 2>&1
systemctl disable warp-go >/dev/null 2>&1
checkwgcf 
[[ ! $wgcfv4 =~ on|plus && ! $wgcfv6 =~ on|plus ]] && green "关闭warp成功" || red "关闭warp失败"
elif [ $unwp == "2" ]; then
systemctl restart warp-go >/dev/null 2>&1
checkwgcf 
[[ $wgcfv4 =~ on|plus || $wgcfv6 =~ on|plus ]] && green "开启warp成功" || red "开启warp失败"
else
bash CFwarp.sh
fi
}

WARPun(){
systemctl disable --now warp-go >/dev/null 2>&1
kill -15 $(pgrep warp-go) >/dev/null 2>&1
/usr/local/bin/warp-go --config=/usr/local/bin/warp.conf --remove >/dev/null 2>&1
rm -rf /usr/local/bin/warp-go /usr/local/bin/warp.conf /usr/local/bin/wgwarp.conf /usr/bin/warp-go /lib/systemd/system/warp-go.service
green "WARP已彻底卸载!"
}

UPwpyg(){
if [[ ! $(type -P warp-go) && ! $(type -P warp-cli) ]] && [[ ! -f '/root/CFwarp.sh' ]]; then
red "未正常安装CFwarp脚本!" && exit
fi
wget -N https://gitlab.com/rwkgyg/CFwarp/raw/main/CFwarp.sh
chmod +x /root/CFwarp.sh 
ln -sf /root/CFwarp.sh /usr/bin/cf
green "CFwarp安装脚本升级成功"
}

WGproxy(){
[[ ! $(type -P warp-go) ]] && red "未安装WARP" && bash CFwarp.sh
green "\n根据网络环境，选择Wireguard代理节点的Endpoint对端IP地址"
readp "1. 使用IPV4地址 (支持v4或v6+v4网络环境，回车默认)\n2. 使用IPV6地址 (仅支持v6+v4网络环境)\n请选择：" IPet
if [ -z "${IPet}" ] || [ $IPet == "1" ];then
endip=162.159.193.10
elif [ $IPet == "2" ];then
endip=[2606:4700:d0::]
else 
red "输入错误，请重新选择" && WGproxy
fi
/usr/local/bin/warp-go --config=/usr/local/bin/warp.conf --export-wireguard=/usr/local/bin/wgwarp.conf >/dev/null 2>&1
sed -i '/PostUp/d;/PostDown/d;/AllowedIPs/d;/Endpoint/d' /usr/local/bin/wgwarp.conf
sed -i "9a AllowedIPs = 0.0.0.0\/0\nAllowedIPs = ::\/0\n" /usr/local/bin/wgwarp.conf
sed -i "11a Endpoint = $endip:1701" /usr/local/bin/wgwarp.conf
yellow "$(cat /usr/local/bin/wgwarp.conf)\n"
green "当前Wireguard节点二维码分享链接如下" && sleep 1
qrencode -t ansiutf8 < /usr/local/bin/wgwarp.conf
}

start_menu(){
ShowWGCF
clear
green "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"           
echo -e "${bblue} ░██     ░██      ░██ ██ ██         ░█${plain}█   ░██     ░██   ░██     ░█${red}█   ░██${plain}  "
echo -e "${bblue}  ░██   ░██      ░██    ░░██${plain}        ░██  ░██      ░██  ░██${red}      ░██  ░██${plain}   "
echo -e "${bblue}   ░██ ░██      ░██ ${plain}                ░██ ██        ░██ █${red}█        ░██ ██  ${plain}   "
echo -e "${bblue}     ░██        ░${plain}██    ░██ ██       ░██ ██        ░█${red}█ ██        ░██ ██  ${plain}  "
echo -e "${bblue}     ░██ ${plain}        ░██    ░░██        ░██ ░██       ░${red}██ ░██       ░██ ░██ ${plain}  "
echo -e "${bblue}     ░█${plain}█          ░██ ██ ██         ░██  ░░${red}██     ░██  ░░██     ░██  ░░██ ${plain}  "
echo
white " 甬哥Gitlab项目  ：gitlab.com/rwkgyg"
white " 甬哥blogger博客 ：ygkkk.blogspot.com"
white " 甬哥YouTube频道 ：www.youtube.com/c/甬哥侃侃侃kkkyg"
green "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
yellow " 安装warp成功后，进入脚本快捷方式：cf"
white " ================================================================="
green "  1. 安装/切换WARP（三模式）" 
green "  2. 卸载WARP"
green "  3. 显示warp代理节点的配置文件、二维码（WireGuard协议）"
white " -----------------------------------------------------------------"
green "  4. 关闭、开启/重启WARP"
green "  5. 更新CFwarp脚本" 
green "  0. 退出脚本 "
white " ================================================================="
if [[ $(type -P warp-go) || $(type -P warp-cli) ]] && [[ -f '/root/CFwarp.sh' ]]; then
if [ "${wpygV}" = "${remoteV}" ]; then
green " 当前CFwarp脚本版本号：${wpygV} 重置版第二版 ，已是最新版本\n"
else
green " 当前CFwarp脚本版本号：${wpygV}"
yellow " 检测到最新CFwarp脚本版本号：${remoteV} ，可选择5进行更新\n"
fi
fi
white " VPS系统信息如下："
white " VPS操作系统: $(blue "$op") \c" && white " 内核版本: $(blue "$version") \c" && white " CPU架构 : $(blue "$cpu") \c" && white " 虚拟化类型: $(blue "$vi")"
IP_Status_menu
echo
readp " 请输入数字:" Input
case "$Input" in     
 1 ) warpinscha;;
 2 ) WARPun;;
 3 ) WGproxy;;
 4 ) WARPonoff;;
 5 ) UPwpyg;;
 * ) exit 
esac
}
if [ $# == 0 ]; then
warpwgcf
start
start_menu
fi
