# Test-SecurityBaseline.ps1
# Checks basic security settings and shows PASS or FAIL for each one.

# A reusable "machine" that builds one result row
function New-CheckResult {
    param (
        [string]$Check,
        [bool]$Passed,
        [string]$Detail
    )
    [PSCustomObject]@{
        Check  = $Check
        Status = if ($Passed) { 'PASS' } else { 'FAIL' }
        Detail = $Detail
    }
}

$results = @()   # an empty list to collect results

# Check 1: Defender real-time protection is on
$defender = Get-MpComputerStatus
$results += New-CheckResult -Check 'Defender real-time protection' `
    -Passed $defender.RealTimeProtectionEnabled `
    -Detail "Enabled: $($defender.RealTimeProtectionEnabled)"

# Check 2: Defender signatures are 3 days old or newer
$ageDays = ((Get-Date) - $defender.AntivirusSignatureLastUpdated).Days
$results += New-CheckResult -Check 'Defender signatures up to date' `
    -Passed ($ageDays -le 3) `
    -Detail "$ageDays day(s) old"

# Check 3: Firewall is on for every profile
$profilesOff = Get-NetFirewallProfile | Where-Object { $_.Enabled -ne 'True' }
$firewallDetail = if ($profilesOff) { "Off: $($profilesOff.Name -join ', ')" } else { 'All profiles on' }
$results += New-CheckResult -Check 'Firewall enabled (all profiles)' `
    -Passed (-not $profilesOff) `
    -Detail $firewallDetail

# Check 4: The built-in Guest account is disabled
$guest = Get-LocalUser -Name 'Guest'
$results += New-CheckResult -Check 'Guest account disabled' `
    -Passed (-not $guest.Enabled) `
    -Detail "Enabled: $($guest.Enabled)"

# Show the results
$results | Format-Table -AutoSize
$failed = ($results | Where-Object Status -eq 'FAIL').Count
Write-Host "$($results.Count) checks run, $failed failed." -ForegroundColor Yellow