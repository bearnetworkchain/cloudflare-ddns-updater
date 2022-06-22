# Cloudflare Dynamic DNS IP Updater


此腳本用於更新基於 Cloudflare 的動態DNS (DDNS)服務！ 通過自定義域名遠程訪問您的網站，無需固定IP！ 用純 BASH 編寫。

出處來源為 : https://github.com/K0p1-Git


## 安裝

```bash
git clone https://github.com/bearnetworkchain/cloudflare-ddns-updater.git
```

打開cloudflare-template.sh，對其參數進行設定

```bash
#auth_email=""                                       # 用於登錄的電子郵件'https://dash.cloudflare.com'
#auth_method="Global"                                # 為 Global API Key 設置為 "global" 或為 Scoped API Token 設置為 "token"
#auth_key=""                                         # 您的 API 令牌或全局 API 密鑰
#zone_identifier=""                                  # API 區域識別碼
#record_name=""                                      # IP更新同步的DNS: 這邊填入您的域名
#ttl="3600"                                          # 設置DNS TTL（秒）
#proxy="true"                                        # 設置端口為true或false
```

## 設定自動更新頻率

此腳本與 crontab 一起使用，通過 crontab 指定執行頻率。

我設15分鐘檢查一次


```bash
crontab -e
 
*/15 * * * * /bin/bash /etc/cloudflare-bearnetwork.sh
```  

```bash

#以下是設定模式供參考

# ┌───────────── 分鐘 (0 - 59)
# │ ┌───────────── 小時 (0 - 23)
# │ │ ┌───────────── 一個月中的哪一天 (1 - 31)
# │ │ │ ┌───────────── 月份 (1 - 12)
# │ │ │ │ ┌───────────── 一星期中的哪一天 (0 - 6) (週六到週日 7 在某些系統上也是周日)
# │ │ │ │ │ ┌───────────── 發出命令                              
# │ │ │ │ │ │
# │ │ │ │ │ │
# * * * * * /bin/bash {Location of the script}
``` 



## Reference
此腳本參考 [Keld Norman](https://www.youtube.com/watch?v=vSIBkH7sxos) 視頻製作。

## License
[MIT](https://github.com/K0p1-Git/cloudflare-ddns-updater/blob/main/LICENSE)
