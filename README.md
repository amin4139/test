-------------------------------------------------------------------------------------------------------------------------------
### 9月更新第一期WARP视频。每更新一期，脚本内容也会随之更新。

### 甬哥博客正式上线：https://ygkkk.blogspot.com/

------------------------------------------------------------------------------------------------------------------------------

一键脚本：
```
wget -N --no-check-certificate https://gitlab.com/rwkgyg/CFwarp/raw/main/CFwarp.sh && bash CFwarp.sh
```

## CFwarp脚本更新说明：

### 2022.3.24 更新 BETA 8，添加快捷键功能

### 视频教程及应用简析注意点后续发布。大家自行“摸鱼”！！！以下版面很乱，后续即将重新整理
----------------------------------------------------------------------------------------------------------------------

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

