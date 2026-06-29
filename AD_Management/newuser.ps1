<#
.SYNOPSIS
    Скрипт для массового создания пользователей в Active Directory из CSV-файла.
.DESCRIPTION
    Читает CSV файл с полями FirstName, LastName, Department, Title.
    Генерирует sAMAccountName, устанавливает дефолтный пароль, требует смены при первом входе.
    Ведет логирование успешных и неуспешных операций.
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$CsvPath,
    
    [string]$LogPath = "C:\Admin\Logs\AD_Creation_Log.txt",
    [string]$TargetOU = "OU=Users,OU=Company,DC=domain,DC=local"
)

Import-Module ActiveDirectory

$users = Import-Csv -Path $CsvPath -Delimiter ";"
$SecurePassword = ConvertTo-SecureString "P@ssw0rd2026!" -AsPlainText -Force

foreach ($user in $users) {
    # Генерация логина: первая буква имени + фамилия (например, JSmith)
    $samAccountName = ($user.FirstName.Substring(0,1) + $user.LastName).ToLower()
    $upn = "$samAccountName@domain.local"
    
    try {
        # Проверка, существует ли уже такой логин
        if (Get-ADUser -Filter "sAMAccountName -eq '$samAccountName'") {
            Write-Warning "Пользователь $samAccountName уже существует."
            Add-Content -Path $LogPath -Value "[SKIP] $(Get-Date) - $samAccountName уже существует."
            continue
        }

        New-ADUser -Name "$($user.FirstName) $($user.LastName)" `
                   -GivenName $user.FirstName `
                   -Surname $user.LastName `
                   -sAMAccountName $samAccountName `
                   -UserPrincipalName $upn `
                   -Path $TargetOU `
                   -AccountPassword $SecurePassword `
                   -ChangePasswordAtLogon $true `
                   -Enabled $true `
                   -Department $user.Department `
                   -Title $user.Title

        Write-Host "Создан пользователь: $samAccountName" -ForegroundColor Green
        Add-Content -Path $LogPath -Value "[SUCCESS] $(Get-Date) - Создан $samAccountName ($($user.Department))"
        
    } catch {
        Write-Error "Ошибка при создании $($user.FirstName) $($user.LastName): $_"
        Add-Content -Path $LogPath -Value "[ERROR] $(Get-Date) - Ошибка создания $samAccountName: $_"
    }
}