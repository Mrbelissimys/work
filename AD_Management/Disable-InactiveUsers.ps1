<#
.SYNOPSIS
    Скрипт для поиска, отключения и переноса неактивных пользователей в архивную OU.
.DESCRIPTION
    Ищет пользователей, которые не логинились более 90 дней.
    Отключает учетную запись, убирает из всех групп безопасности (кроме Domain Users)
    и перемещает объект в отдельную OU для отключенных учеток.
#>

Import-Module ActiveDirectory

$DaysInactive = 90
$LimitDate = (Get-Date).AddDays(-$DaysInactive)
$SearchOU = "OU=ActiveUsers,DC=domain,DC=local"
$ArchiveOU = "OU=Archive,DC=domain,DC=local"
$LogFile = "C:\Admin\Logs\AD_Cleanup_$(Get-Date -Format 'yyyy-MM-dd').txt"

# Конвертация даты в формат AD
$LimitDateAD = $LimitDate.ToFileTime()

$InactiveUsers = Get-ADUser -SearchBase $SearchOU -Filter {LastLogonTimeStamp -lt $LimitDateAD -and Enabled -eq $true} -Properties LastLogonTimeStamp, MemberOf

foreach ($User in $InactiveUsers) {
    try {
        # 1. Отключаем учетку
        Disable-ADAccount -Identity $User.DistinguishedName
        
        # 2. Удаляем из всех групп (оставляем только первичную)
        $User.MemberOf | Remove-ADGroupMember -Members $User.DistinguishedName -Confirm:$false
        
        # 3. Перемещаем в архив
        Move-ADObject -Identity $User.DistinguishedName -TargetPath $ArchiveOU
        
        $LogMsg = "[SUCCESS] Отключен и перенесен: $($User.sAMAccountName). Последний вход: $([datetime]::FromFileTime($User.LastLogonTimeStamp))"
        Write-Host $LogMsg -ForegroundColor Yellow
        Add-Content -Path $LogFile -Value $LogMsg
    } catch {
        $ErrMsg = "[ERROR] Ошибка при обработке $($User.sAMAccountName): $_"
        Write-Error $ErrMsg
        Add-Content -Path $LogFile -Value $ErrMsg
    }
}