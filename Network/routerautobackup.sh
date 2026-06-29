ROUTER_IP="192.168.88.1"
SSH_USER="admin"
SSH_PORT="22"
BACKUP_DIR="/opt/network_backups/mikrotik"
DATE=$(date +%Y-%m-%d_%H-%M)
EXPORT_FILENAME="fw_backup_${DATE}.rsc"

mkdir -p "$BACKUP_DIR"

echo "Подключение к MikroTik ($ROUTER_IP)..."

# Создаем экспорт конфигурации на самом роутере
ssh -p $SSH_PORT $SSH_USER@$ROUTER_IP "/export file=$EXPORT_FILENAME"
sleep 5 # Ждем завершения записи файла

# Скачиваем файл на сервер
if scp -P $SSH_PORT $SSH_USER@$ROUTER_IP:${EXPORT_FILENAME} "$BACKUP_DIR/"; then
    echo "✅ Конфигурация успешно скачана: $BACKUP_DIR/$EXPORT_FILENAME"
    
    # Удаляем временный файл с роутера, чтобы не забивать память
    ssh -p $SSH_PORT $SSH_USER@$ROUTER_IP "/file remove $EXPORT_FILENAME"
    
    # Удаляем локальные бэкапы старше 30 дней
    find "$BACKUP_DIR" -type f -name "*.rsc" -mtime +30 -exec rm {} \;
else
    echo "❌ ОШИБКА: Не удалось скачать конфигурацию с $ROUTER_IP"
    exit 1
fi