Настройка автоформатирования в VSCode для CMake проекта
1. Установите необходимые расширения
bash
# Установите расширения в VSCode:
- C/C++ (Microsoft)
- CMake Tools
- CMake
- Clang-Format
2. Создайте файл .clang-format в корне проекта
yaml
BasedOnStyle: Google
Language: Cpp
AccessModifierOffset: -2
AlignAfterOpenBracket: Align
AlignConsecutiveMacros: true
AlignOperands: true
AlignTrailingComments: true
AllowAllArgumentsOnNextLine: false
AllowAllConstructorInitializersOnNextLine: false
AllowShortBlocksOnASingleLine: Never
AllowShortFunctionsOnASingleLine: InlineOnly
AllowShortIfStatementsOnASingleLine: false
AllowShortLoopsOnASingleLine: false
BreakBeforeBinaryOperators: NonAssignment
ColumnLimit: 80
IndentWidth: 2
UseTab: Never
3. Настройте VSCode (settings.json)
json
{
    "C_Cpp.clang_format_path": "clang-format",
    "C_Cpp.formatting": "clangFormat",
    "editor.formatOnSave": true,
    "editor.formatOnPaste": true,
    "files.associations": {
        "*.cpp": "cpp",
        "*.h": "cpp",
        "*.hpp": "cpp"
    },
    "[cpp]": {
        "editor.defaultFormatter": "ms-vscode.cpptools"
    },
    "cmake.format.enable": true
}
4. Добавьте в CMakeLists.txt
cmake
cmake_minimum_required(VERSION 3.10)
project(MyProject)

# Найти clang-format
find_program(CLANG_FORMAT clang-format)
if(CLANG_FORMAT)
    message(STATUS "Found clang-format: ${CLANG_FORMAT}")

    # Добавить цель для форматирования
    add_custom_target(format
        COMMAND ${CLANG_FORMAT}
        -i
        -style=file
        ${CMAKE_SOURCE_DIR}/src/*.cpp
        ${CMAKE_SOURCE_DIR}/include/*.h
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    )
endif()
5. Альтернативный способ через CMake
cmake
# Более продвинутый вариант
find_program(CLANG_FORMAT NAMES clang-format clang-format-14 clang-format-13)

if(CLANG_FORMAT)
    # Рекурсивный поиск всех исходных файлов
    file(GLOB_RECURSE ALL_SOURCE_FILES
        src/*.cpp
        src/*.h
        include/*.h
        test/*.cpp
    )

    add_custom_target(format
        COMMAND ${CLANG_FORMAT} -i -style=file ${ALL_SOURCE_FILES}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Formatting all source files..."
    )
endif()
6. Использование
В VSCode:

Сохраните файл (Ctrl+S) - автоформатирование

Или Shift+Alt+F - форматирование вручную

Через терминал:

bash
# Если добавили цель в CMake
make format
# или
cmake --build build --target format

# Или напрямую
clang-format -i -style=file src/*.cpp include/*.h
7. Проверка стиля
Добавьте проверку в CI:

bash
# Проверить без изменений
clang-format -style=file --dry-run --Werror src/*.cpp
Быстрая настройка
Установите clang-format:

bash
# Ubuntu/Debian
sudo apt-get install clang-format

# Windows (choco)
choco install llvm

# macOS
brew install clang-format
Создайте базовый .clang-format:

bash
clang-format -style=google -dump-config > .clang-format
Теперь при сохранении C++ файлов в VSCode они будут автоматически форматироваться по Google Style Guide!
