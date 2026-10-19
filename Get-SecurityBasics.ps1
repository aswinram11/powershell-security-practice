# Get-SecurityBasics.ps1
# Shows basic security information about this computer.

Write-Host "=== Security basics for $env:COMPUTERNAME ===" -ForegroundColor Cyan

# 1. Operating system
$os = Get-CimInstance -ClassName Win32_OperatingSystem
Write-Host "OS: $($os.Caption) (build $($os.BuildNumber))"

# 2. Microsoft Defender status
$defender = Get-MpComputerStatus
Write-Host "Defender real-time protection on: $($defender.RealTimeProtectionEnabled)"
Write-Host "Defender signatures last updated: $($defender.AntivirusSignatureLastUpdated)"

# 3. Firewall profiles
Get-NetFirewallProfile | Select-Object Name, Enabled | Format-Table