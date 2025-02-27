# 20.07.2024
# Script by Katakuari - dev@felesadastra.xyz

$DnsConfigFile = Get-ChildItem -Path "$PSScriptRoot" -Filter "dnsconfig.json" -Recurse
$DnsConfig = Get-Content $DnsConfigFile | ConvertFrom-Json

$Headers = @{
    "X-Auth-Email"  = "$($DnsConfig.authEmail)"; 
    "Authorization" = "Bearer $($DnsConfig.apiToken)";
    "Content-Type"  = "application/json"
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
        content = $NewRecordValue
        name    = $Record.name
        type    = $Record.type
    } | ConvertTo-Json

    Write-Host "Updating following entry:`n$Body" -ForegroundColor Yellow
    
    $ApiUri = "https://api.cloudflare.com/client/v4/zones/$($DnsConfig.zoneId)/dns_records/$($Record.id)"
    $Response = Invoke-RestMethod -Uri $ApiUri -Method 'PATCH' -Headers $Headers -Body $Body
    $Response.result
}

Stop-Transcript