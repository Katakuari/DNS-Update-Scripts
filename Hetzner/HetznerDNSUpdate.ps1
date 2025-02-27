# 27.02.2025
# Script by Katakuari - dev@felesadastra.xyz
# Hetzner API Docs: https://dns.hetzner.com/api-docs

$DnsConfigFile = Get-ChildItem -Path "$PSScriptRoot" -Filter "dnsconfig.json" -Recurse
$DnsConfig = Get-Content $DnsConfigFile | ConvertFrom-Json

$Headers = @{
    "Auth-API-Token" = "$($DnsConfig.apiToken)"
    "Content-Type"   = "application/json"
}

# Start logging
Start-Transcript -UseMinimalHeader -Path "$PSScriptRoot\DnsUpdate.log" -Append

foreach ($Record in $DnsConfig.records) {
    if ($Record.type -eq "A") {
        $NewRecordValue = (curl.exe https://ifconfig.co/ip -4 -s).Trim()
    }
    
    if ($Record.type -eq "AAAA") {
        $NewRecordValue = (curl.exe https://ifconfig.co/ip -6 -s).Trim()
        if ($null -eq $NewRecordValue) { break }
    }

    $Body = @{
        zone_id = $DnsConfig.zoneId
        type    = $Record.type
        name    = $Record.name
        value   = $NewRecordValue
    } | ConvertTo-Json

    Write-Host "Updating following entry:`n$Body" -ForegroundColor Yellow
    
    $ApiUri = "https://dns.hetzner.com/api/v1/records/$($Record.id)"
    $Response = Invoke-RestMethod -Uri $ApiUri -Method 'PUT' -Headers $Headers -Body $Body
    $Response.record
}

Stop-Transcript