<#
.SYNOPSIS
    Creates 5 Organizational Units and 30 users in each (150 users total).
 
.DESCRIPTION
    Run on the domain controller in an elevated PowerShell session.
    Safe to re-run: existing OUs and users are skipped.
    The initial password is requested at runtime so it is never stored in this file.
 
    Usernames look like it01..it30, hr01..hr30, sales01..sales30, etc.
#>
 
Import-Module ActiveDirectory
 
$domain    = Get-ADDomain
$domainDN  = $domain.DistinguishedName
$upnSuffix = $domain.DNSRoot
$ous       = "IT", "HR", "Sales", "Finance", "Engineering"
$perOU     = 30
 
$password = Read-Host "Initial password for lab users (12+ chars, mixed case, number, symbol)" -AsSecureString
 
foreach ($ou in $ous) {
 
    # Create the OU if it does not exist
    $existingOU = Get-ADOrganizationalUnit -Filter "Name -eq '$ou'" -SearchBase $domainDN -SearchScope OneLevel
    if (-not $existingOU) {
        New-ADOrganizationalUnit -Name $ou -Path $domainDN -ProtectedFromAccidentalDeletion $false
        Write-Host "Created OU: $ou"
    }
 
    # Create the users in that OU
    foreach ($i in 1..$perOU) {
        $sam = "{0}{1:D2}" -f $ou.ToLower(), $i
 
        if (-not (Get-ADUser -Filter "SamAccountName -eq '$sam'")) {
            New-ADUser `
                -Name $sam `
                -GivenName $ou `
                -Surname ("User{0:D2}" -f $i) `
                -DisplayName ("$ou User{0:D2}" -f $i) `
                -SamAccountName $sam `
                -UserPrincipalName "$sam@$upnSuffix" `
                -Path "OU=$ou,$domainDN" `
                -AccountPassword <REDACTED> `
                -Enabled $true `
                -ChangePasswordAtLogon $false
        }
    }
    Write-Host "Finished OU: $ou"
}
 
# Summary
Write-Host ""
Write-Host "Summary" -ForegroundColor Cyan
foreach ($ou in $ous) {
    $count = (Get-ADUser -Filter * -SearchBase "OU=$ou,$domainDN").Count
    Write-Host ("{0,-12} {1} users" -f $ou, $count)
}
$total = (Get-ADUser -Filter * -SearchBase $domainDN | Where-Object { $_.DistinguishedName -match "OU=(IT|HR|Sales|Finance|Engineering)," }).Count
Write-Host "Total lab users: $total"
 
