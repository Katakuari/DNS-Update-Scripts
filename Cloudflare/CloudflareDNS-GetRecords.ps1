# 19.07.2024
# Script by Katakuari - dev@felesadastra.xyz

$DnsConfigFile = Get-ChildItem -Path "$PSScriptRoot" -Filter "dnsconfig.json" -Recurse
$DnsConfig = Get-Content $DnsConfigFile | ConvertFrom-Json

$Headers = @{
    "X-Auth-Email"  = "$($DnsConfig.authEmail)"
    "Authorization" = "Bearer $($DnsConfig.apiToken)"
    "Content-Type"  = "application/json"
}

$Response = Invoke-RestMethod "https://api.cloudflare.com/client/v4/zones/$($DnsConfig.zoneId)/dns_records" -Method "GET" -Headers $Headers
$Response.result | Where-Object { $_.type -eq "A" -or $_.type -eq "AAAA" } | Format-List id, name, type, content, comment