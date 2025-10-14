#!/bin/bash

# Скрипт сборки проекта
set -e

# Определяем корневую директорию проекта
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Файл с переменными окружения
ENV_FILE="$SCRIPT_DIR/.env"

# Загружаем переменные окружения из файла, если он существует
if [ -f "$ENV_FILE" ]; then
    echo "Загрузка переменных окружения из $ENV_FILE"
    source "$ENV_FILE"
else
    echo "Файл $ENV_FILE не найден. Создайте его для указания путей к Qt и Boost."
    echo "Пример содержимого .env файла:"
    echo "QT_DIR=/path/to/qt"
    echo "BOOST_DIR=/path/to/boost"
    exit 1
fi

# Создаем директорию bin в корне проекта
BIN_DIR="$PROJECT_ROOT/bin"
echo "Создание директории $BIN_DIR"

# Функция для очистки предыдущих сборок
clean_previous_builds() {
    echo "Очистка предыдущих сборок..."

    # Удаляем билд-директории, но оставляем собранные исполняемые файлы
    if [ -d "$BIN_DIR/build_server" ]; then
        echo "Удаление $BIN_DIR/build_server"
        rm -rf "$BIN_DIR/build_server"
    fi

    if [ -d "$BIN_DIR/build_client" ]; then
        echo "Удаление $BIN_DIR/build_client"
        rm -rf "$BIN_DIR/build_client"
    fi

    # Создаем чистую bin директорию (оставляя существующие исполняемые файлы)
    mkdir -p "$BIN_DIR"
}

# Функция для полной очистки (опционально)
clean_all() {
    echo "Полная очистка билд-директорий..."
    if [ -d "$BIN_DIR" ]; then
        echo "Удаление $BIN_DIR"
        rm -rf "$BIN_DIR"
    fi
    mkdir -p "$BIN_DIR"
}

# Обработка аргументов командной строки
if [ "$1" = "clean" ]; then
    clean_all
    exit 0
elif [ "$1" = "clean-build" ]; then
    clean_previous_builds
fi

# Функция для проверки и настройки Qt
setup_qt() {
    if [ -z "$QT_DIR" ]; then
        echo "Ошибка: QT_DIR не установлен."
        echo "Укажите путь к Qt в файле $ENV_FILE"
        exit 1
    fi

    # Проверяем различные возможные расположения Qt6Config.cmake
    local qt_config_paths=(
        "$QT_DIR/lib/cmake/Qt6"
        "$QT_DIR/lib/cmake/Qt5"  # на всякий случай
        "$QT_DIR"
    )

    for path in "${qt_config_paths[@]}"; do
        if [ -f "$path/Qt6Config.cmake" ] || [ -f "$path/Qt6/Qt6Config.cmake" ]; then
            echo "Найден Qt6 в: $path"
            export CMAKE_PREFIX_PATH="$QT_DIR:${CMAKE_PREFIX_PATH}"
            return 0
        fi
    done

    echo "Ошибка: Не найден Qt6Config.cmake в $QT_DIR"
    echo "Ищем возможные пути..."
    find "$QT_DIR" -name "Qt6Config.cmake" 2>/dev/null | head -5
    exit 1
}

# Функция для проверки Boost
setup_boost() {
    if [ -z "$BOOST_DIR" ]; then
        echo "Предупреждение: BOOST_DIR не установлен. Сервер может не собраться."
        return 1
    fi

    # Проверяем, что это действительно путь к Boost
    if [ -f "$BOOST_DIR/boost/version.hpp" ] || [ -f "$BOOST_DIR/include/boost/version.hpp" ]; then
        echo "Найден Boost в: $BOOST_DIR"
        return 0
    else
        echo "Предупреждение: Не найден Boost в $BOOST_DIR"
        echo "Убедитесь, что это корневая директория Boost (содержит boost/version.hpp)"
        return 1
    fi
}

# Функция для сборки сервера
build_server() {
    local project_name="server"
    local src_dir="src/server"
    local build_dir="$BIN_DIR/build_$project_name"

    echo "=========================================="
    echo "Сборка $project_name"
    echo "=========================================="

    # Проверяем Boost
    if ! setup_boost; then
        echo "Пропуск сборки сервера: Boost не найден"
        return 0
    fi

    # Создаем директорию для сборки
    mkdir -p "$build_dir"
    cd "$build_dir"

    # Подготавливаем аргументы CMake
    local cmake_args=(
        "$PROJECT_ROOT/$src_dir"
        "-DCMAKE_BUILD_TYPE=Release"
    )

    # В зависимости от структуры Boost, передаем разные переменные
    # Пробуем разные варианты, которые понимает find_package(Boost)
    if [ -f "$BOOST_DIR/boost/version.hpp" ]; then
        # Если Boost установлен в BOOST_DIR напрямую
        cmake_args+=("-DBoost_DIR=$BOOST_DIR")
        cmake_args+=("-DBoost_INCLUDE_DIR=$BOOST_DIR")
    elif [ -f "$BOOST_DIR/include/boost/version.hpp" ]; then
        # Если Boost установлен в BOOST_DIR/include
        cmake_args+=("-DBoost_DIR=$BOOST_DIR")
        cmake_args+=("-DBoost_INCLUDE_DIR=$BOOST_DIR/include")
    else
        # Просто передаем как есть
        cmake_args+=("-DBoost_DIR=$BOOST_DIR")
    fi

    # Конфигурируем проект с помощью CMake
    echo "Запуск CMake с аргументами: ${cmake_args[*]}"
    cmake "${cmake_args[@]}"

    # Собираем проект
    cmake --build . --config Release

    # Копируем исполняемые файлы в bin директорию
    copy_executable "$project_name" "$build_dir"

    cd "$PROJECT_ROOT"
}

# Функция для сборки клиента
build_client() {
    local project_name="appclient"
    local src_dir="src/client"
    local build_dir="$BIN_DIR/build_client"

    echo "=========================================="
    echo "Сборка клиента"
    echo "=========================================="

    # Настраиваем Qt
    setup_qt

    # Создаем директорию для сборки
    mkdir -p "$build_dir"
    cd "$build_dir"

    # Конфигурируем проект с помощью CMake
    echo "Запуск CMake для клиента..."
    cmake "$PROJECT_ROOT/$src_dir" \
        -DCMAKE_BUILD_TYPE=Release

    # Собираем проект
    cmake --build . --config Release

    # Копируем исполняемые файлы
    copy_executable "$project_name" "$build_dir"

    cd "$PROJECT_ROOT"
}

# Функция для копирования исполняемых файлов
copy_executable() {
    local project_name=$1
    local build_dir=$2

    # Ищем исполняемый файл в различных возможных местах
    local executable_path=""

    # Проверяем разные возможные расположения
    for path in \
        "$build_dir/Release/$project_name.exe" \
        "$build_dir/$project_name.exe" \
        "$build_dir/Release/$project_name" \
        "$build_dir/$project_name" \
        "$build_dir/$project_name.app/Contents/MacOS/$project_name"
    do
        if [ -f "$path" ] || [ -d "$path" ]; then
            executable_path="$path"
            break
        fi
    done

    if [ -n "$executable_path" ]; then
        if [[ "$executable_path" == *".app" ]]; then
            # macOS bundle
            cp -r "$(dirname "$(dirname "$executable_path")")" "$BIN_DIR/"
            echo "Собран $project_name.app -> $BIN_DIR/"
        elif [[ "$executable_path" == *".exe" ]]; then
            # Windows
            cp "$executable_path" "$BIN_DIR/"
            echo "Собран $project_name.exe -> $BIN_DIR/"
        else
            # Linux
            cp "$executable_path" "$BIN_DIR/"
            echo "Собран $project_name -> $BIN_DIR/"
        fi
    else
        echo "Предупреждение: не удалось найти собранный файл $project_name"
        echo "Ищем в $build_dir:"
        find "$build_dir" -name "$project_name*" -type f 2>/dev/null | head -5 || true
    fi
}

# Основной процесс сборки
echo "Начало сборки проекта..."
echo "Проект: $PROJECT_ROOT"
echo "Выходная директория: $BIN_DIR"

# Очищаем предыдущие сборки (но оставляем исполняемые файлы)
clean_previous_builds

# Собираем клиента
build_client

# Собираем сервер
build_server

echo "=========================================="
echo "Сборка завершена!"
echo "Исполняемые файлы находятся в: $BIN_DIR"
echo "=========================================="

# Выводим список собранных файлов
echo "Содержимое $BIN_DIR:"
ls -la "$BIN_DIR" 2>/dev/null || echo "Директория $BIN_DIR пуста"
