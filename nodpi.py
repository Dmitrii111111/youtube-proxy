import random
import asyncio

# Загружаем чёрный список доменов
try:
    with open("blacklist.txt", "r", encoding="utf-8") as f:
        BLOCKED = [line.strip().encode() for line in f.readlines()]
except FileNotFoundError:
    BLOCKED = []

PORT = 8881
TASKS = []

async def main():
    """Запуск сервера"""
    server = await asyncio.start_server(new_conn, '0.0.0.0', PORT)
    print(f"Прокси запущен на 127.0.0.1:{PORT}")
    await server.serve_forever()

async def pipe(reader, writer):
    """Передача данных между клиентом и сервером"""
    try:
        while not reader.at_eof() and not writer.is_closing():
            data = await reader.read(1024)
            if not data:
                break
            writer.write(data)
            await writer.drain()
    except Exception as e:
        print(f"Pipe error: {e}")
    finally:
        writer.close()

async def new_conn(local_reader, local_writer):
    """Обрабатывает новое подключение"""
    try:
        http_data = await local_reader.read(1500)

        # Проверяем корректность HTTP-запроса
        if not http_data or b"\r\n" not in http_data:
            print(f"Invalid HTTP request: {http_data[:50]}")
            local_writer.close()
            return

        try:
            type, target = http_data.split(b"\r\n")[0].split(b" ")[0:2]
        except ValueError:
            print(f"Malformed HTTP request: {http_data[:50]}")
            local_writer.close()
            return

        if b":" not in target:
            print(f"Invalid target format: {target}")
            local_writer.close()
            return

        host, port = target.split(b":")

        # Отклоняем неподдерживаемые HTTP-запросы
        if type != b"CONNECT":
            print(f"Unexpected connection type: {type}")
            local_writer.write(b'HTTP/1.1 405 Method Not Allowed\r\n\r\n')
            local_writer.close()
            return

        # Отправляем подтверждение клиенту
        local_writer.write(b'HTTP/1.1 200 OK\r\n\r\n')
        await local_writer.drain()

        # Подключаемся к удалённому серверу
        try:
            remote_reader, remote_writer = await asyncio.open_connection(host.decode(), int(port.decode()))
        except Exception as e:
            print(f"Error connecting to remote host: {e}")
            local_writer.close()
            return

        # Если HTTPS (порт 443), обрабатываем фрагментацию данных
        if port == b'443':
            await fragment_data(local_reader, remote_writer)

        # Создаем асинхронные задачи для проксирования данных
        TASKS.append(asyncio.create_task(pipe(local_reader, remote_writer)))
        TASKS.append(asyncio.create_task(pipe(remote_reader, local_writer)))

    except Exception as e:
        print(f"Error in new connection: {e}")
        local_writer.close()

async def fragment_data(local_reader, remote_writer):
    """Фрагментирует данные перед отправкой на сервер"""
    try:
        head = await local_reader.read(5)
        data = await local_reader.read(1024)  # Уменьшаем размер данных для стабильности
        parts = []

        # Проверяем, заблокирован ли сайт
        if all([data.find(site) == -1 for site in BLOCKED]):
            remote_writer.write(head + data)
            await remote_writer.drain()
            return

        # Фрагментируем трафик, чтобы сбить с толку DPI
        while data:
            part_len = random.randint(1, len(data))  # Разбиваем на случайные части
            parts.append(bytes.fromhex("1603") + bytes([random.randint(0, 255)]) + int(
                part_len).to_bytes(2, byteorder='big') + data[0:part_len])

            data = data[part_len:]

        remote_writer.write(b''.join(parts))
        await remote_writer.drain()

    except Exception as e:
        print(f"Fragmentation error: {e}")

# Запускаем сервер
asyncio.run(main())

