FROM ubuntu:24.04

# Установка зависимостей
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    gdb \
    git \
    wget \
    libboost-all-dev \
    && rm -rf /var/lib/apt/lists/*

# Создание рабочей директории
WORKDIR /workspace

# Установка дополнительных инструментов для отладки (опционально)
RUN apt-get update && apt-get install -y \
    valgrind \
    clang \
    clang-format \
    && rm -rf /var/lib/apt/lists/*

# Настройка для отладки
RUN echo "set print pretty on" >> ~/.gdbinit

CMD ["/bin/bash"]
