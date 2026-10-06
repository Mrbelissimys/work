#!/bin/bash

# Конфигурация
PROJECT_NAME="da"
SOURCE_DIR="/var/www/html"
BACKUP_DIR="/backup/archives"
DATE=$(date +'%Y-%m-%d_%H-%M')
ARCHIVE_NAME="${PROJECT_NAME}_${DATE}.tar.gz"

# Настройки Telegram
TG_BOT_TOKEN=" "
TG_CHAT_ID=" "

send_tg_alert() {
    local MESSAGE=$1
    curl -s -X POST "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage" \
        -d chat_id="${TG_CHAT_ID}" \
        -d text="${MESSAGE}" > /dev/null
}

# Создание директории бэкапа, если её нет
mkdir -p "$BACKUP_DIR"

# Выполнение бэкапа
echo "Начинаем бэкап директории $SOURCE_DIR..."
if tar -czf "${BACKUP_DIR}/${ARCHIVE_NAME}" -C "$SOURCE_DIR" . ; then
    BACKUP_SIZE=$(du -h "${BACKUP_DIR}/${ARCHIVE_NAME}" | awk '{print $1}')
    MSG="✅ Бэкап ${PROJECT_NAME} успешно создан!%0AРазмер: ${BACKUP_SIZE}%0AФайл: ${ARCHIVE_NAME}"
    send_tg_alert "$MSG"
    
    # Удаление старых бэкапов (старше 7 дней)
    find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +7 -exec rm {} \;
else
    MSG="❌ ОШИБКА: Бэкап ${PROJECT_NAME} завершился с ошибкой! Срочно проверьте сервер."
    send_tg_alert "$MSG"
    exit 1
fi