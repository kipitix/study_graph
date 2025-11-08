#!/bin/bash

# Путь к директории проекта (где находится скрипт)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Пути к исполняемым файлам
CLIENT_EXEC="$PROJECT_ROOT/bin/build_client/study_graph_client"
SERVER_EXEC="$PROJECT_ROOT/bin/build_server/study_graph_server"

# Функция для вывода сообщений
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >&2
}

# Проверяем существование исполняемых файлов
if [[ ! -x "$SERVER_EXEC" ]]; then
    log "Ошибка: Исполняемый файл сервера не найден или не является исполняемым: $SERVER_EXEC"
    exit 1
fi

if [[ ! -x "$CLIENT_EXEC" ]]; then
    log "Ошибка: Исполняемый файл клиента не найден или не является исполняемым: $CLIENT_EXEC"
    exit 1
fi

log "Найдены исполняемые файлы:"
log "  Сервер: $SERVER_EXEC"
log "  Клиент: $CLIENT_EXEC"

# Проверяем, установлен ли konsole
if ! command -v konsole &> /dev/null; then
    log "Ошибка: konsole не найден. Убедитесь, что он установлен."
    exit 1
fi

log "Запускаю konsole с сервером и клиентом в отдельных вкладках..."

# --- Запуск Konsole с сервером в первой вкладке ---
# --hold: удерживает вкладку/окно открытым после завершения команды
# -e: указывает команду для выполнения
konsole --hold -e bash -c "cd '$PROJECT_ROOT' && echo 'Запускаю сервер...' && '$SERVER_EXEC'; echo 'Сервер остановлен или завершён. Нажмите Enter для выхода.'; read" &

# Сохраняем PID процесса запуска konsole для сервера (опционально, для информации)
KONSOLE_SERVER_PID=$!
log "Konsole для сервера запущен (PID запуска: $KONSOLE_SERVER_PID)."

# Ждем немного, чтобы сервер мог начать работу
sleep 2

# --- Запуск клиента во второй вкладке того же окна Konsole ---
# --hold также удерживает вкладку открытой
konsole --hold -e bash -c "cd '$PROJECT_ROOT' && echo 'Запускаю клиент...' && '$CLIENT_EXEC'; echo 'Клиент остановлен или завершён. Нажмите Enter для выхода.'; read" &

# Сохраняем PID процесса запуска konsole для клиента (опционально, для информации)
KONSOLE_CLIENT_PID=$!
log "Konsole для клиента запущен в новой вкладке (PID запуска: $KONSOLE_CLIENT_PID)."

log "Оба приложения (сервер и клиент) должны быть запущены в Konsole."
log "Окно Konsole останется открытым. Закройте его вручную, когда закончите."

# Ожидаем завершения фоновых процессов (необязательно, но может быть полезно)
wait $KONSOLE_SERVER_PID
wait $KONSOLE_CLIENT_PID
