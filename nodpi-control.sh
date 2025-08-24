#!/bin/bash

# Простой скрипт для показа статуса NoDPI
# Требует установленного zenity

# Проверяем наличие zenity
if ! command -v zenity &> /dev/null; then
    echo "Ошибка: zenity не установлен. Установите: sudo apt install zenity"
    exit 1
fi

# Получаем текущий статус
if systemctl is-active --quiet nodpi; then
    STATUS="🟢 Активен"
    STATUS_COLOR="green"
else
    STATUS="🔴 Остановлен"
    STATUS_COLOR="red"
fi

# Получаем статус автозапуска
if systemctl is-enabled --quiet nodpi; then
    AUTOSTART="✅ Включен"
else
    AUTOSTART="❌ Отключен"
fi

# Получаем информацию о порте
PORT_STATUS=$(sudo netstat -tlnp 2>/dev/null | grep 8881 || echo "Порт 8881 не используется")

# Формируем сообщение
MESSAGE="<b>📊 Статус NoDPI Proxy Server</b>

<b>Сервис:</b> $STATUS
<b>Автозапуск:</b> $AUTOSTART
<b>Порт 8881:</b> $PORT_STATUS

<b>🔧 Управление через терминал:</b>

<b>Статус сервиса:</b>
sudo systemctl status nodpi

<b>Запустить:</b>
sudo systemctl start nodpi

<b>Остановить:</b>
sudo systemctl stop nodpi

<b>Перезапустить:</b>
sudo systemctl restart nodpi

<b>Просмотр логов:</b>
sudo journalctl -u nodpi -f

<b>Проверить порт:</b>
sudo netstat -tlnp | grep 8881

<b>🌐 Проверить работу прокси:</b>
curl -x 127.0.0.1:8881 https://httpbin.org/ip"

# Показываем информацию
zenity --info \
    --title="NoDPI Proxy Server - Статус" \
    --width=600 \
    --height=500 \
    --text="$MESSAGE"
