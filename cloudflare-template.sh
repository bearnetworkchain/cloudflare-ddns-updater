#!/bin/bash
## 必要時更改為“bin/sh”

## 終端輸入以下指令:
## cp cloudflare-template.sh /etc/cloudflare-bearnetwork.sh
## chmod +x /etc/cloudflare-bearnetwork.sh
## nano /etc/cloudflare-bearnetwork.sh


auth_email=""                                       # 用於登錄的電子郵件'https://dash.cloudflare.com'
auth_method="Global"                                # 為 Global API Key 設置為 "global" 或為 Scoped API Token 設置為 "token"
auth_key=""                                         # 您的 API 令牌或全局 API 密鑰
zone_identifier=""                                  # API 區域識別碼
record_name=""                                      # IP更新同步的DNS
ttl="3600"                                          # 設置DNS TTL（秒）
proxy="true"                                        # 設置端口為true或false

###########################################
## 檢查我們是否有公共 IP
###########################################
ipv4_regex='([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])\.([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])\.([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])\.([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])'
ip=$(curl -s -4 https://cloudflare.com/cdn-cgi/trace | grep -E '^ip'); ret=$?
if [[ ! $ret == 0 ]]; then # 在 cloudflare 未能返回 ip 的情況下。
    # 嘗試從其他網站獲取IP。
    ip=$(curl -s https://api.ipify.org || curl -s https://ipv4.icanhazip.com)
else
    # 僅從 cloudflare的 IP行中提取 IP。
    ip=$(echo $ip | sed -E "s/^ip=($ipv4_regex)$/\1/")
fi

# 使用正則表達式檢查正確的 IPv4 格式。
if [[ ! $ip =~ ^$ipv4_regex$ ]]; then
    logger -s "DDNS Updater: Failed to find a valid IP."
    exit 2
fi

###########################################
## 檢查並設置正確的身份驗證頭
###########################################
if [[ "${auth_method}" == "global" ]]; then
  auth_header="X-Auth-Key:"
else
  auth_header="Authorization: Bearer"
fi

###########################################
## 尋找A記錄
###########################################

logger "DDNS Updater: Check Initiated"
record=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?type=A&name=$record_name" \
                      -H "X-Auth-Email: $auth_email" \
                      -H "$auth_header $auth_key" \
                      -H "Content-Type: application/json")

###########################################
## 檢查域是否有 A 記錄
###########################################
if [[ $record == *"\"count\":0"* ]]; then
  logger -s "DDNS Updater: Record does not exist, perhaps create one first? (${ip} for ${record_name})"
  exit 1
fi

###########################################
## 獲取現有 IP
###########################################
old_ip=$(echo "$record" | sed -E 's/.*"content":"(([0-9]{1,3}\.){3}[0-9]{1,3})".*/\1/')
# Compare if they're the same
if [[ $ip == $old_ip ]]; then
  logger "DDNS Updater: IP ($ip) for ${record_name} has not changed."
  exit 0
fi

###########################################
## 從結果中設置記錄標識符
###########################################
record_identifier=$(echo "$record" | sed -E 's/.*"id":"(\w+)".*/\1/')

###########################################
## 使用 API 更改 IP@Cloudflare
###########################################
update=$(curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" \
                     -H "X-Auth-Email: $auth_email" \
                     -H "$auth_header $auth_key" \
                     -H "Content-Type: application/json" \
                     --data "{\"type\":\"A\",\"name\":\"$record_name\",\"content\":\"$ip\",\"ttl\":\"$ttl\",\"proxied\":${proxy}}")

###########################################
## 報告狀態
###########################################
case "$update" in
*"\"success\":false"*)
  echo -e "DDNS Updater: $ip $record_name DDNS failed for $record_identifier ($ip). DUMPING RESULTS:\n$update" | logger -s 
  if [[ $slackuri != "" ]]; then
    curl -L -X POST $slackuri \
    --data-raw '{
      "channel": "'$slackchannel'",
      "text" : "'"$sitename"' DDNS Update Failed: '$record_name': '$record_identifier' ('$ip')."
    }'
  fi
  if [[ $discorduri != "" ]]; then
    curl -i -H "Accept: application/json" -H "Content-Type:application/json" -X POST \
    --data-raw '{
      "content" : "'"$sitename"' DDNS Update Failed: '$record_name': '$record_identifier' ('$ip')."
    }' $discorduri
  fi
  exit 1;;
*)
  logger "DDNS Updater: $ip $record_name DDNS updated."
  if [[ $slackuri != "" ]]; then
    curl -L -X POST $slackuri \
    --data-raw '{
      "channel": "'$slackchannel'",
      "text" : "'"$sitename"' Updated: '$record_name''"'"'s'""' new IP Address is '$ip'"
    }'
  fi
  if [[ $discorduri != "" ]]; then
    curl -i -H "Accept: application/json" -H "Content-Type:application/json" -X POST \
    --data-raw '{
      "content" : "'"$sitename"' Updated: '$record_name''"'"'s'""' new IP Address is '$ip'"
    }' $discorduri
  fi
  exit 0;;
esac
