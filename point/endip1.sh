#!/bin/bash
red(){ echo -e "\033[31m\033[01m$1\033[0m";}
green(){ echo -e "\033[32m\033[01m$1\033[0m";}
yellow(){ echo -e "\033[33m\033[01m$1\033[0m";}
white(){ echo -e "\033[37m\033[01m$1\033[0m";}
readp(){ read -p "$(yellow "$1")" $2;}
case "$(uname -m)" in
	x86_64 | x64 | amd64 )
	    cpu=amd64
	;;
	i386 | i686 )
        cpu=386
	;;
	armv8 | armv8l | arm64 | aarch64 )
        cpu=arm64
	;;
	armv7l )
        cpu=arm
	;;
	* )
	echo "当前架构为$(uname -m)，暂不支持"
	exit
	;;
esac

cfwarpreg(){
white "下载warp注册程序"
if [[ -n $cpu ]]; then
curl -L -o warpreg -# --retry 2 https://proxy.freecdn.ml?url=https://gitlab.com/rwkgyg/CFwarp/-/raw/main/point/cpu1/$cpu
fi

chmod +x warpreg
output=$(./warpreg)
private_key=$(echo "$output" | awk -F ': ' '/private_key/{print $2}')
v6=$(echo "$output" | awk -F ': ' '/v6/{print $2}')
res=$(echo "$output" | awk -F ': ' '/reserved/{print $2}' | tr -d '[:space:]')
cat > warp-wg-wg.txt <<EOF
[Interface]
PrivateKey = $private_key
Address = 172.16.0.2/32, $v6/128
DNS = 1.1.1.1
MTU = 1280

[Peer]
PublicKey = bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = 162.159.193.10:2408
EOF

cat > warp-wg-clash.txt <<EOF
proxies:
  - name: "warp-wg-clash"
    type: wireguard
    server: 162.159.193.10
    port: 2408
    ip: 172.16.0.2
    ipv6: $v6
    private-key: $private_key
    public-key: bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=
    udp: true
EOF
echo
yellow "reserved值：$res" && sleep 1
echo
green "warp-wireguard客户端配置文件如下" && sleep 1 
white "$(cat warp-wg-wg.txt)"
green "Endpoint值可更改为使用平台的warp优选IP端口" && sleep 1
echo
green "warp-wireguard配置二维码如下" && sleep 1
qrencode -t ansiutf8 < warp-wg-wg.txt
echo
green "warp-wg-clash客户端配置文件如下" && sleep 1
white "$(cat warp-wg-clash.txt)"
green "server与port值可更改为使用平台的warp优选IP端口" && sleep 1
rm -rf warpreg warp-wg-clash.txt warp-wg-wg.txt
exit
}

cfwarpIP(){
white "下载warp优选程序"
if [[ -n $cpu ]]; then
curl -L -o warpendpoint -# --retry 2 https://proxy.freecdn.ml?url=https://gitlab.com/rwkgyg/CFwarp/raw/main/point/$cpu
fi
	n=0
	iplist=100
	while true
	do
		temp[$n]=$(echo 162.159.192.$(($RANDOM%256)))
		n=$[$n+1]
		if [ $n -ge $iplist ]
		then
			break
		fi
		temp[$n]=$(echo 162.159.193.$(($RANDOM%256)))
		n=$[$n+1]
		if [ $n -ge $iplist ]
		then
			break
		fi
		temp[$n]=$(echo 162.159.195.$(($RANDOM%256)))
		n=$[$n+1]
		if [ $n -ge $iplist ]
		then
			break
		fi
		temp[$n]=$(echo 188.114.96.$(($RANDOM%256)))
		n=$[$n+1]
		if [ $n -ge $iplist ]
		then
			break
		fi
		temp[$n]=$(echo 188.114.97.$(($RANDOM%256)))
		n=$[$n+1]
		if [ $n -ge $iplist ]
		then
			break
		fi
		temp[$n]=$(echo 188.114.98.$(($RANDOM%256)))
		n=$[$n+1]
		if [ $n -ge $iplist ]
		then
			break
		fi
		temp[$n]=$(echo 188.114.99.$(($RANDOM%256)))
		n=$[$n+1]
		if [ $n -ge $iplist ]
		then
			break
		fi
temp[$n]=$(echo [2606:4700:d0::$(printf '%x\n' $(($RANDOM*2+$RANDOM%2))):$(printf '%x\n' $(($RANDOM*2+$RANDOM%2))):$(printf '%x\n' $(($RANDOM*2+$RANDOM%2))):$(printf '%x\n' $(($RANDOM*2+$RANDOM%2)))])
		n=$[$n+1]
		if [ $n -ge $iplist ]
		then
			break
		fi
		temp[$n]=$(echo [2606:4700:d1::$(printf '%x\n' $(($RANDOM*2+$RANDOM%2))):$(printf '%x\n' $(($RANDOM*2+$RANDOM%2))):$(printf '%x\n' $(($RANDOM*2+$RANDOM%2))):$(printf '%x\n' $(($RANDOM*2+$RANDOM%2)))])
		n=$[$n+1]
		if [ $n -ge $iplist ]
		then
			break
		fi
	done
	while true
	do
		if [ $(echo ${temp[@]} | sed -e 's/ /\n/g' | sort -u | wc -l) -ge $iplist ]
		then
			break
		else
			temp[$n]=$(echo 162.159.192.$(($RANDOM%256)))
			n=$[$n+1]
		fi
		if [ $(echo ${temp[@]} | sed -e 's/ /\n/g' | sort -u | wc -l) -ge $iplist ]
		then
			break
		else
			temp[$n]=$(echo 162.159.193.$(($RANDOM%256)))
			n=$[$n+1]
		fi
		if [ $(echo ${temp[@]} | sed -e 's/ /\n/g' | sort -u | wc -l) -ge $iplist ]
		then
			break
		else
			temp[$n]=$(echo 162.159.195.$(($RANDOM%256)))
			n=$[$n+1]
		fi
		if [ $(echo ${temp[@]} | sed -e 's/ /\n/g' | sort -u | wc -l) -ge $iplist ]
		then
			break
		else
			temp[$n]=$(echo 188.114.96.$(($RANDOM%256)))
			n=$[$n+1]
		fi
		if [ $(echo ${temp[@]} | sed -e 's/ /\n/g' | sort -u | wc -l) -ge $iplist ]
		then
			break
		else
			temp[$n]=$(echo 188.114.97.$(($RANDOM%256)))
			n=$[$n+1]
		fi
		if [ $(echo ${temp[@]} | sed -e 's/ /\n/g' | sort -u | wc -l) -ge $iplist ]
		then
			break
		else
			temp[$n]=$(echo 188.114.98.$(($RANDOM%256)))
			n=$[$n+1]
		fi
		if [ $(echo ${temp[@]} | sed -e 's/ /\n/g' | sort -u | wc -l) -ge $iplist ]
		then
			break
		else
			temp[$n]=$(echo 188.114.99.$(($RANDOM%256)))
			n=$[$n+1]
		fi
if [ $(echo ${temp[@]} | sed -e 's/ /\n/g' | sort -u | wc -l) -ge $iplist ]
		then
			break
		else
			temp[$n]=$(echo [2606:4700:d0::$(printf '%x\n' $(($RANDOM*2+$RANDOM%2))):$(printf '%x\n' $(($RANDOM*2+$RANDOM%2))):$(printf '%x\n' $(($RANDOM*2+$RANDOM%2))):$(printf '%x\n' $(($RANDOM*2+$RANDOM%2)))])
			n=$[$n+1]
		fi
		if [ $(echo ${temp[@]} | sed -e 's/ /\n/g' | sort -u | wc -l) -ge $iplist ]
		then
			break
		else
			temp[$n]=$(echo [2606:4700:d1::$(printf '%x\n' $(($RANDOM*2+$RANDOM%2))):$(printf '%x\n' $(($RANDOM*2+$RANDOM%2))):$(printf '%x\n' $(($RANDOM*2+$RANDOM%2))):$(printf '%x\n' $(($RANDOM*2+$RANDOM%2)))])
			n=$[$n+1]
		fi
	done

echo ${temp[@]} | sed -e 's/ /\n/g' | sort -u > ip.txt
ulimit -n 102400
chmod +x warpendpoint
./warpendpoint
clear
yellow "结果显示为优选后丢包与延迟最低的5个IPV4与5个IPV6，丢包率100%不可选"
white "$(cat result.csv | awk -F, '$3!="timeout ms" {print} ' | sort -t, -nk2 -nk3 | uniq | awk -F, '{if($1~/^[0-9]/ && ipv4_count<5) {print; ipv4_count++} else if($1~/^\[/ && ipv6_count<5) {print; ipv6_count++}}' | awk -F, '{print "端点 "$1" 丢包率 "$2" 平均延迟 "$3}')"
rm -rf ip.txt warpendpoint
exit
}
red "------------------------------------------------------"
white "甬哥Github项目  ：github.com/yonggekkk"
white "甬哥blogger博客 ：ygkkk.blogspot.com"
white "甬哥YouTube频道 ：www.youtube.com/@ygkkk"
white "脚本支持WARP优选IP、WARP配置文件生成，感谢CF网友开发"
red "------------------------------------------------------"
echo
green "1.WARP-V4V6自动优选对端IP"
green "2.WARP配置文件无限生成"
green "0.退出\n"
readp "请选择: " menu
if [ $menu == "1" ];then
cfwarpIP
elif [ $menu == "2" ];then
cfwarpreg
else 
exit
fi
