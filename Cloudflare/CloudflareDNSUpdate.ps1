# 20.07.2024
# Script by Katakuari - dev@felesadastra.xyz

$dnsconfFile = Get-ChildItem -Path "$PSScriptRoot" -Filter "dnsconfig.json" -Recurse
$dnsconf = Get-Content $dnsconfFile | ConvertFrom-Json

$headers = @{
	"X-Auth-Email"  = "$($dnsconf.authEmail)"; 
	"Authorization" = "Bearer $($dnsconf.apiToken)";
	"Content-Type"  = "application/json"
}

for ($i = 0; $i -lt $dnsconf.recordId.Length; $i++) {
	Write-Host $i
	if ($dnsconf.recordType[$i] -eq "A") {
		$recordValue = (curl.exe https://ifconfig.co/ip -4).Trim()
	}
	
	if ($dnsconf.recordType[$i] -eq "AAAA") { 
		$recordValue = (curl.exe https://ifconfig.co/ip -6).Trim()
		if ($null -eq $recordValue) { break }
	}

	$body = "{
		""content"": ""$($recordValue)"",
		""name"": ""$($dnsconf.recordName[$i])"",
		""type"": ""$($dnsconf.recordType[$i])""
		}"

	Write-Host "Updating following entry:`n$body"
	
	$response = Invoke-RestMethod "https://api.cloudflare.com/client/v4/zones/$($dnsconf.recordZoneId)/dns_records/$($dnsconf.recordId[$i])" -Method 'PATCH' -Headers $headers -Body $body
	$response | ConvertTo-Json
}
<#
TODO:
- Logging
#>
