# 19.07.2024
# Script by Katakuari - dev@felesadastra.xyz

$dnsconf = Get-Content "$PSScriptRoot\dnsconfig.json" | ConvertFrom-Json

$headers = @{
	"X-Auth-Email"  = "$($dnsconf.authEmail)"; 
	"Authorization" = "Bearer $($dnsconf.apiToken)";
	"Content-Type"  = "application/json"
}

$response = Invoke-RestMethod "https://api.cloudflare.com/client/v4/zones/$($dnsconf.recordZoneId)/dns_records" -Method 'GET' -Headers $headers
$response.result | Where-Object { $_.type -eq "A" -or $_.type -eq "AAAA" } | Format-List id, name, type, content, comment

