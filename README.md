-------------------------------------------------------------------------------------------------------------------------------
### 已收到很多意见和建议，7月将彻底更新本项目及说明，同步油管视频教程。。。

### 广告：

### 甬哥博客正式上线：https://ygkkk.blogspot.com/

------------------------------------------------------------------------------------------------------------------------------

一键脚本：
```
wget -N --no-check-certificate https://gitlab.com/rwkgyg/cfwarp/raw/main/CFwarp.sh && bash CFwarp.sh
```

## CFwarp脚本更新说明：

### 2022.3.24 更新 BETA 8，添加快捷键功能

### 视频教程及应用简析注意点后续发布。大家自行“摸鱼”！！！以下版面很乱，后续即将重新整理
----------------------------------------------------------------------------------------------------------------------

## 支持KVM、lxc、openvz等架构VPS的WARP一键综合脚本

- [x] 支持自动识别系统类型，CPU架构(X86/ARM)，内核版本，虚拟化架构类型！
- [x] 支持Ubuntu 18 /Centos 7/Debain 10 以上最新系统，包含Centos各类衍生版本！
- [x] 支持纯IPV4，纯IPV6，双栈IPV4+IPV6三大类VPS，每类三种Wgcf-WARP安装形式，以及Socks5-WARP客户端！
- [x] 支持主菜单实时显示当前可用IP是否解锁奈飞Netflix，可选择前台手动、前后台自动、重启自动刷支持奈飞Netflix的IP！
- [x] 支持WARP普通账户升级：1、WARP+Teams无限流量账户，2、WARP+有限流量账户！
- [x] 支持screen管理菜单，以方便对一键screen无限刷流量、一键screen刷奈飞IP的管理及查询相关状态！
- [x] 支持自定义刷奈飞时间段间隔与选定奈飞国家区域

### 相关视频教程及项目

待更新 

---------------------------------------------------------------------------------------------

加入无限刷WARP+流量功能（方法如下）

下载好手机APP名称：1.1.1.1

添加WARP+账户提示26字符：右上角设置-账户-按键-复制许可证秘钥

刷WARP+流量提示36字符：右上角设置-高级-诊断-复制客户端配置ID

APP显示warp+流量更新：右上角设置-高级-连接选项-重置安全密钥，再回到APP主界面即可显示最新WARP+流量数据

提示400 bad request：密钥ID输入错误或者绑定设备数超过4个

超过5个设备如何删减：右上角设置-账户-管理设备，点暗不要的设备

有意见提ISSUES！！

关注甬哥侃侃侃油管频道：https://www.youtube.com/channel/UCxukdnZiXnTFvjF5B5dvJ5w

echo -e "search blue.kundencontroller.de\noptions rotate\nnameserver 2a02:180:6:5::1c\nnameserver 2a02:180:6:5::4\nnameserver 2a02:180:6:5::1e\nnameserver 2a02:180:6:5::1d" > /etc/resolv.conf

# 目录

* [vps的ip套上warp功能的优势及不足](#vps的ip套上warp功能的优势及不足)

* [warp多功能一键脚本](#warp多功能一键脚本)

* [warp多功能一键脚本各功能简析](#warp多功能一键脚本各功能简析)

* [自定义ip分流配置模板说明](#自定义ip分流配置模板说明)

* [相关附加说明](#相关附加说明)

-----------------------------------------------------------------------------------------
### vps的ip套上warp功能的优势及不足

<details>
<summary>给纯IPV4/纯IPV6 VPS添加WARP的好处</summary>

```bash
1：使只有IPV4/IPV6的VPS获取访问IPV6/IPV4的能力，套上WARP的ip，变成双栈VPS！

2：基本能隐藏VPS的真实IP！

3：加速VPS到CloudFlare CDN节点访问速度！

4：避开原VPS的IP需要谷歌验证码问题！

5：原IPV4下，WARP的IPV6替代HE tunnelbroker IPV6的隧道代理方案，做IPV6 VPS跳板机代理更加稳定！
```
</details>

<details>
<summary>给IPV4+IPV6双栈VPS添加WARP的好处</summary>
    
```bash
1：基本能隐藏VPS的真实IP！

2：WARP分配的IPV4或者IPV6的IP段，都支持奈非Netflix流媒体，无视VPS原IP限制！

3：加速VPS到CloudFlare CDN节点访问速度！

4：避开原VPS的IP需要谷歌验证码问题！
```
</details>

<details>
<summary>不稳定或者不足点</summary>
    
```bash
1：warp的IP与原生IP在Youtube上速度对比，并不一定有优势，具体看网络环境！
    
2：warp的IP归属国家一般与原生IP一致，但可能会自动改变！

3：由于warp是虚拟的IP，类似宝塔面板等相关工具可能需要另外的设置，请自行谷歌。
```
</details>

-------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------

### warp多功能一键脚本各功能简析

待更新

注意：域名解析所填写的IP必须是VPS本地IP，与WARP分配的IP没关系！

------------------------------------------------------------------------------------------------------
### 自定义ip分流配置模板说明（Socks5代理分流-待更新）

分流配置文件：outbounds配置文件或者routing配置文件，让IP、域名自定义。待更新

----------------------------------------------------------------------------------------------

### 相关附加说明

- 提示：配置文件wgcf.conf和注册文件wgcf-account.toml都已备份在/etc/wireguard目录下！

- 查看WARP当前统计状态：wg

- 相关WARP进程命令

手动临时关闭WARP网络接口

wg-quick down wgcf

手动开启WARP网络接口

wg-quick up wgcf

启动systemctl enable wg-quick@wgcf

开始systemctl start wg-quick@wgcf

状态systemctl status wg-quick@wgcf

重启systemctl restart wg-quick@wgcf

停止systemctl stop wg-quick@wgcf

关闭systemctl disable wg-quick@wgcf

systemctl is-active warp-svc
systemctl is-enabled warp-svc
warp-cli --accept-tos status
warp-cli --accept-tos account
warp-cli --accept-tos settings

---------------------------------------------------------------------------------------------------------
#### 感谢P3terx，参考来源：https://github.com/P3TERX/warp.sh

