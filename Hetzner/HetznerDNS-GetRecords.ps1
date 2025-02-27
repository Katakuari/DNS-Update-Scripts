# 27.02.2025
# Script by Katakuari - dev@felesadastra.xyz
# Hetzner API Docs: https://dns.hetzner.com/api-docs

$DnsConfigFile = Get-ChildItem -Path "$PSScriptRoot" -Filter "dnsconfig.json" -Recurse
$DnsConfig = Get-Content $DnsConfigFile | ConvertFrom-Json

$Headers = @{
    "Auth-API-Token" = "$($DnsConfig.apiToken)"
}

$Response = Invoke-RestMethod "https://dns.hetzner.com/api/v1/records?zone_id=$($DnsConfig.zoneId)" -Method "GET" -Headers $Headers
$Response.records | Where-Object { $_.type -eq "A" -or $_.type -eq "AAAA" }