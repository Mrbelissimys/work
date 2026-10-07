[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Принудительно включаем английский вывод системных ошибок
[System.Threading.Thread]::CurrentThread.CurrentUICulture = [System.Globalization.CultureInfo]::GetCultureInfo('en-US')
[System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo]::GetCultureInfo('en-US')

Write-Host "1. Soft-closing Outlook..."
Stop-Process -Name "OUTLOOK" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

Write-Host "2. Locating active interactive user..."
try {
    # Ищем процесс explorer.exe текущего сеанса
    $explorerProcess = Get-CimInstance -ClassName Win32_Process -Filter "Name = 'explorer.exe'" -ErrorAction Stop
    
    if (-not $explorerProcess) {
        Write-Host "ERROR: No active user session found."
        Start-Sleep -Seconds 5
        exit
    }

    # Берем владельца процесса
    $owner = Invoke-CimMethod -InputObject $explorerProcess[0] -MethodName GetOwner
    $targetUser = "$($owner.Domain)\$($owner.User)"
    Write-Host "Found active user: $targetUser"
} catch {
    Write-Host "ERROR: Failed to query explorer.exe process. Run script with Administrator privileges."
    Write-Host $_.Exception.Message
    Start-Sleep -Seconds 5
    exit
}

# Получаем SID пользователя
try {
    $objUser = New-Object System.Security.Principal.NTAccount($targetUser)
    $sid = $objUser.Translate([System.Security.Principal.SecurityIdentifier]).Value
    Write-Host "User SID: $sid"
} catch {
    Write-Host "ERROR: Failed to translate user to SID: $targetUser"
    Start-Sleep -Seconds 5
    exit
}

Write-Host "3. Updating registry profiles for IMAP/SMTP (Port 993/465 & SSL)..."

# Возможные ветки реестра профилей Outlook и MAPI
$profilePaths = @(
    "Registry::HKEY_USERS\$sid\Software\Microsoft\Office\14.0\Outlook\Profiles",
    "Registry::HKEY_USERS\$sid\Software\Microsoft\Office\15.0\Outlook\Profiles",
    "Registry::HKEY_USERS\$sid\Software\Microsoft\Office\16.0\Outlook\Profiles",
    "Registry::HKEY_USERS\$sid\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles"
)

# GUID для стандартных IMAP учетных записей и сюда же можно добавить GUID вашего коннектора
$accountGuids = @(
    "9375CFF0413111d3B88A00104B2A6676"
    # Сюда при необходимости можно дописать GUID вашего стороннего коннектора в кавычках:
    # "ВАШ_НОВЫЙ_GUID_КОННЕКТОРА"
)

$changesMade = $false

foreach ($profilesPath in $profilePaths) {
    if (Test-Path $profilesPath) {
        $profiles = Get-ChildItem -Path $profilesPath
        
        foreach ($profile in $profiles) {
            foreach ($guid in $accountGuids) {
                $accountKeysPath = "$($profile.PSPath)\$guid"
                
                if (Test-Path $accountKeysPath) {
                    $accounts = Get-ChildItem -Path $accountKeysPath
                    
                    foreach ($account in $accounts) {
                        $regPath = $account.PSPath
                        
                        try {
                            # Устанавливаем параметры IMAP и SMTP (SSL + порты)
                            Set-ItemProperty -Path $regPath -Name "IMAP Port" -Value 993 -Type DWord -Force
                            Set-ItemProperty -Path $regPath -Name "IMAP Use SSL" -Value 1 -Type DWord -Force
                            Set-ItemProperty -Path $regPath -Name "SMTP Port" -Value 465 -Type DWord -Force
                            Set-ItemProperty -Path $regPath -Name "SMTP Secure Connection" -Value 1 -Type DWord -Force
                            Set-ItemProperty -Path $regPath -Name "SMTP Use SSL" -Value 1 -Type DWord -Force
                            
                            Write-Host "SUCCESS: Updated account keys in profile: $($profile.PSChildName)"
                            $changesMade = $true
                        } catch {
                            Write-Host "WARNING: Failed to write to $($account.Name): $($_.Exception.Message)"
                        }
                    }
                }
            }
        }
    }
}

if ($changesMade) {
    Write-Host "DONE: All requested registry branches were successfully updated!"
} else {
    Write-Host "NOTICE: Profiles or GUID keys were not found in registry for this user."
}

Start-Sleep -Seconds 5