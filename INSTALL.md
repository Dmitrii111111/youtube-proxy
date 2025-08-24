# Инструкция по сборке DEB пакета NoDPI

## 🛠️ Подготовка системы

### 1. Установка необходимых пакетов

```bash
# Обновляем систему
sudo apt update
sudo apt upgrade

# Устанавливаем инструменты для сборки
sudo apt install build-essential devscripts debhelper

# Дополнительные инструменты (опционально)
sudo apt install lintian  # Проверка качества пакета
sudo apt install pbuilder # Сборка в чистой среде
```

### 2. Проверка установки

```bash
# Проверяем наличие необходимых команд
which dpkg-buildpackage
which dh
which lintian

# Версии инструментов
dpkg-buildpackage --version
dh --version
```

## 🔨 Сборка пакета

### 1. Автоматическая сборка (рекомендуется)

```bash
# Делаем скрипт исполняемым
chmod +x build_deb.sh

# Запускаем сборку
./build_deb.sh
```

### 2. Ручная сборка

```bash
# Очищаем предыдущие сборки
rm -rf debian/nodpi/
rm -f ../nodpi_*.deb
rm -f ../nodpi_*.changes
rm -f ../nodpi_*.buildinfo
rm -f ../nodpi_*.dsc
rm -f ../nodpi_*.tar.gz

# Собираем пакет
dpkg-buildpackage -b -us -uc
```

## 📦 Результат сборки

После успешной сборки в родительской директории появятся файлы:

- `nodpi_1.0.0_all.deb` - основной пакет для установки
- `nodpi_1.0.0_all.changes` - информация об изменениях
- `nodpi_1.0.0_all.buildinfo` - информация о сборке
- `nodpi_1.0.0.dsc` - описание исходного кода
- `nodpi_1.0.0.tar.gz` - архив исходного кода

## 🚀 Установка пакета

### 1. Установка через GUI

1. Найдите файл `nodpi_1.0.0_all.deb` в файловом менеджере
2. Дважды кликните на него
3. Откроется Ubuntu Software Center
4. Нажмите "Установить"
5. Введите пароль администратора

### 2. Установка через терминал

```bash
# Переходим в директорию с пакетом
cd ..

# Устанавливаем пакет
sudo dpkg -i nodpi_1.0.0_all.deb

# Если есть проблемы с зависимостями
sudo apt-get install -f
```

## 🔍 Проверка установки

### 1. Проверка статуса сервиса

```bash
# Статус сервиса
sudo systemctl status nodpi

# Проверка автозапуска
sudo systemctl is-enabled nodpi

# Проверка порта
sudo netstat -tlnp | grep 8881
```

### 2. Проверка файлов

```bash
# Основной скрипт
ls -la /usr/bin/nodpi.py

# Systemd сервис
ls -la /etc/systemd/system/nodpi.service

# Дополнительные файлы
ls -la /usr/share/nodpi/

# Иконка в меню
ls -la /usr/share/applications/nodpi.desktop
```

## 🧪 Тестирование

### 1. Запуск сервиса

```bash
# Запускаем сервис
sudo systemctl start nodpi

# Проверяем статус
sudo systemctl status nodpi

# Смотрим логи
sudo journalctl -u nodpi -f
```

### 2. Тест подключения

```bash
# Проверяем, что прокси отвечает
curl -x 127.0.0.1:8881 https://httpbin.org/ip

# Тест HTTPS
curl -x 127.0.0.1:8881 https://httpbin.org/ip
```

## 🐛 Устранение проблем

### Ошибка "dpkg-buildpackage не найден"
```bash
sudo apt install devscripts
```

### Ошибка "dh не найден"
```bash
sudo apt install debhelper
```

### Ошибки при сборке
```bash
# Очищаем и пробуем снова
./build_deb.sh

# Или вручную
dpkg-buildpackage -b -us -uc -nc
```

### Проблемы с правами доступа
```bash
# Проверяем права
ls -la debian/

# Исправляем права
chmod +x debian/rules
chmod +x debian/nodpi/DEBIAN/postinst
chmod +x debian/nodpi/DEBIAN/prerm
```

## 📋 Требования к системе

- **ОС**: Ubuntu 18.04+ или Debian 10+
- **Python**: 3.7 или выше
- **Память**: минимум 128 MB свободной RAM
- **Диск**: минимум 10 MB свободного места
- **Сеть**: доступ к интернету для работы прокси

## 🔧 Дополнительные возможности

### Проверка качества пакета
```bash
# Устанавливаем lintian
sudo apt install lintian

# Проверяем пакет
lintian ../nodpi_1.0.0_all.deb
```

### Сборка в чистой среде
```bash
# Устанавливаем pbuilder
sudo apt install pbuilder

# Создаем базовую среду
sudo pbuilder create

# Собираем в чистой среде
sudo pbuilder build ../nodpi_1.0.0.dsc
```

---

**Готово!** Теперь у вас есть профессиональный DEB пакет, который пользователи смогут легко установить одним кликом.

