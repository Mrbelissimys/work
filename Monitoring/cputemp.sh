#!/bin/bash

# Скрипт мониторинга температуры процессора (на базе утилиты lm-sensors).
# Если температура превышает критическую отметку, отправляется алерт.

# Настройки
CRITICAL_TEMP=85
LOG_FILE="/var/log/cpu_temp_monitor.log"

# Получаем текущую температуру CPU Package (убираем плюсы, градусы и десятичные)
# Требуется пакет lm-sensors
CURRENT_TEMP=$(sensors | grep 'Package id 0:' | awk '{print $4}' | sed 's/+//;s/°C//;s/\..*//')

# Проверка, удалось ли получить данные
if [ -z "$CURRENT_TEMP" ]; then
    echo "$(date) - ОШИБКА: Не удалось прочитать данные с датчиков." >> "$LOG_FILE"
    exit 1
fi

if [ "$CURRENT_TEMP" -ge "$CRITICAL_TEMP" ]; then
    ALERT_MSG="🔥 КРИТИЧЕСКИЙ АЛЕРТ: Перегрев CPU! Текущая температура: ${CURRENT_TEMP}°C"
    echo "$(date) - $ALERT_MSG" >> "$LOG_FILE"
    
    # Здесь можно добавить вызов curl для отправки в Telegram или Slack
    # curl -s -X POST "https://api.telegram.org/bot<TOKEN>/sendMessage" -d chat_id="<ID>" -d text="$ALERT_MSG"
else
    echo "$(date) - Температура в норме: ${CURRENT_TEMP}°C" >> "$LOG_FILE"
fi