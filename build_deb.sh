#!/bin/bash

# Скрипт для сборки DEB пакета NoDPI
# Требует установленного пакета build-essential и devscripts

echo "🔨 Сборка DEB пакета NoDPI..."

# Проверяем наличие необходимых инструментов
if ! command -v dpkg-buildpackage &> /dev/null; then
    echo "❌ Ошибка: dpkg-buildpackage не найден"
    echo "Установите пакет devscripts: sudo apt install devscripts"
    exit 1
fi

if ! command -v dh &> /dev/null; then
    echo "❌ Ошибка: dh не найден"
    echo "Установите пакет debhelper: sudo apt install debhelper"
    exit 1
fi

# Проверяем версию Python
python3_version=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
required_version="3.7"
if [ "$(printf '%s\n' "$required_version" "$python3_version" | sort -V | head -n1)" != "$required_version" ]; then
    echo "❌ Ошибка: требуется Python $required_version или выше, установлен $python3_version"
    exit 1
fi
echo "✅ Python версия: $python3_version"

# Очищаем предыдущие сборки
echo "🧹 Очистка предыдущих сборок..."
rm -rf debian/nodpi/
rm -f ../nodpi_*.deb
rm -f ../nodpi_*.changes
rm -f ../nodpi_*.buildinfo
rm -f ../nodpi_*.dsc
rm -f ../nodpi_*.tar.gz

# Собираем пакет
echo "📦 Сборка пакета..."
dpkg-buildpackage -b -us -uc

# Проверяем результат
if [ $? -eq 0 ]; then
    echo "✅ Пакет успешно собран!"
    echo "📁 Файлы пакета:"
    ls -la ../nodpi_*
    
    echo ""
    echo "🚀 Для установки пакета выполните:"
    echo "sudo dpkg -i ../nodpi_1.0.0_all.deb"
    echo ""
    echo "🔧 Для управления сервисом:"
    echo "sudo systemctl start nodpi    # Запустить"
    echo "sudo systemctl stop nodpi     # Остановить"
    echo "sudo systemctl status nodpi   # Статус"
    echo "sudo systemctl restart nodpi  # Перезапустить"
else
    echo "❌ Ошибка при сборке пакета"
    exit 1
fi

