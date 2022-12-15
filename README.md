**CFwarp脚本相关说明请查看[甬哥博客](https://ygkkk.blogspot.com/2022/09/gitlabcfwarpwarpwarp.html)**


[【甬哥YouTube教程】WARP系列第1期(warp账户篇)：warp、warp+、teams三类账户设置、切换流程及注意点，cloudflare注册teams团队账户详细步骤，提取账户密钥方案，CFwarp脚本第一版发布](https://youtu.be/Se5kI07k9eA)

[【甬哥YouTube教程】WARP系列第2期(WireGuard代理上篇)：无限申请WARP账户？WireGuard客户端配置WARP核心七要素简析，Windows电脑端与VPS端提取WARP配置文件教程，CFwarp脚本第二版发布](https://youtu.be/rGbhnTuCUcw)

------------------------------------------------------------------------------------------------------------------------------------

CFwarp脚本宗旨：添加WARP尽可能做到简单化，适合范围局限于主流系统，让小白一把梭，不懂回车默认即可！！！

当前CFwarp脚本为重置版第二版本，特点及更新如下：

安装成功后，再次进入脚本快捷方式为 cf

1、支持Centos7以上，Debian10以上，Ubuntu18.04以上操作系统，支持amd64与arm64架构

2、自动检测并添加TUN开启功能

3、支持VPS系统信息、奈飞检测结果的显示。IP地域与检测奈飞的识别，直接引用的是sjlleo/netflix-verify脚本，准确率比较高

4、第三方wgcf脚本注册warp方式，支持添加warp的ipv4、ipv6、ipv4+ipv6三种安装类别，可相互切换

5、支持warp普通账户刷流量脚本，引用ALIILAPRO/warp-plus-cloudflare脚本，以支持升级到warp+账户

6、支持升级到warp teams账户，须私KEY与对应的IPV6地址

7、按脚本提示要求，warp、warp+、warp teams三类账户可相互升降级

8、支持warp临时的关闭、开启

9、支持在线自动提示脚本更新

10、加入warp配置文件与二维码的直接显示选项（wireguard协议）


第三版即将更新。。。。。。。。。

------------------------------------------------------------------------------------------------------------------------------

一键脚本：
```
wget -N --no-check-certificate https://gitlab.com/rwkgyg/CFwarp/raw/main/CFwarp.sh && bash CFwarp.sh
```
----------------------------------------------------------------------------------------------------------------------

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
#### 感谢CoiaPrant，WARP-GO源项目地址：https://gitlab.com/ProjectWARP/warp-go
