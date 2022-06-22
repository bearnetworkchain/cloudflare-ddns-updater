# Cloudflare Dynamic DNS IP Updater


此腳本用於更新基於 Cloudflare 的動態DNS (DDNS)服務！ 通過自定義域名遠程訪問您的網站，無需固定IP！ 用純 BASH 編寫。

出處來源為 : https://github.com/K0p1-Git


## Installation

```bash
git clone https://github.com/bearnetworkchain/cloudflare-ddns-updater.git
```

## Usage
此腳本與 crontab 一起使用。 通過 crontab 指定執行頻率。

```bash
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
