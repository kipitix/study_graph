# Данные по сборке проекта

## Подготовка окружения

### userver

[Официальный сайт](https://userver.tech)

Будем запускать в `Dev containers` по [этой](https://userver.tech/de/dab/md_en_2userver_2build_2build.html#autotoc_md197) инструкции.

Там весьма путано написано, но у меня получилось создать проект для сервера следующим образом.

1. Скопировать [скрипт](https://userver.tech/d4/dac/service-template_2userver-create-service_8sh-example.html) себе в репозиторий (etc/scripts/userver/userver-create-service.sh)
2. Перейти в репозитории в директорию `src`
3. И оттуда выполнить `../etc/scripts/userver/userver-create-service.sh study_graph_userver`
4. Установить в `VSCode` требуемые расширения для `Dev containers` (ms-vscode-remote.remote-containers)
5. Открыть директорию `src/study_graph_userver` в `VSCode` и за счёт того, что в корне директории есть директория `.devcontainer` будет предложено переоткрыть проект но в `Dev Containers` (соглашаемся)
6. Будут скачены требуемые образы и переключено в консоль контейнера (первый раз занимает довольно много времени)
7. Для сборки можно использовать команды `make build-debug` или `make build-release`
8. Для запуска можно использовать команды `make start-debug` или `make start-release`

### Qt

[Официальный сайт](https://www.qt.io)

Тут 2 варианта:

1. Через стандартный `Maintenance tool`
2. Если всё заблокировано, то можно использовать [зеркала](https://qt-mirror.dannhauer.de), ТГ-канал энтузиаста `t.me/zqtprog`
3. Рекомендую использовать версию `Qt LTS` (на текущий момент это `6.8`) и `QtCreator` не ниже версии `16` (QML нормально работает)
