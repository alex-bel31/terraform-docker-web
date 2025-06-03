# Итоговый проект модуля «Облачная инфраструктура». Terraform

### Описание проекта

Проект демонстрирует автоматизированное развёртывание инфраструктуры и web-приложения в Yandex Cloud с использованием Terraform, Docker, Docker Compose и cloud-init. Вся конфигурация разбита на модули, используется remote state и state locking на базе Yandex Object Storage и YDB.


## Развёртывание инфраструктуры. Модули Terraform

* **VPC и подсети**: создаются с помощью модуля `vpc`, с двумя подсетями в зонах **ru-central1-a** и **ru-central1-b**.
* **Группы безопасности**:

  * `app-sg`: разрешает входящие подключения на порты:

    * **22** — SSH
    * **80** — HTTP
    * **443** — HTTPS
    * Все egress соединения разрешены
  * `db-sg`: разрешает входящие подключения на порт **3306** только из `app-sg`. Также разрешены все egress соединения.

* **Виртуальные машины**:

  * Создаются с помощью модуля `vm`.
  * Используется образ **ubuntu-2004-lts**.
  * Назначается публичный IP.
  * Присваивается **сервисный аккаунт** с ролью `container-registry.puller`, чтобы VM могла скачивать образы из Yandex Container Registry.

* **База данных**:

  * Создаётся с помощью модуля `mysql`, как управляемый кластер `yandex_mdb_mysql_cluster`.
  * Параметры базы (БД, пользователь, пароль) передаются через cloud-init.

* **Container Registry**:

  * Создаётся реестр с помощью `yandex_container_registry`.
  * Сборка и пуш Docker-образа происходит с помощью `null_resource` и `local-exec`.

Реализация все модулей описана в [/modules]()

## Cloud-init (user-data)

Для настройки виртуальной машины используется **cloud-init**, который:

* Обновляет пакеты.
* Устанавливает зависимости (curl, git, jq, docker,docker-compose).
* Создаёт пользователя и настраивает авторизацию по SSH.
* Подготавливает **.env** файл для запуска приложения, подставляя IP MySQL-инстанса (через **getent hosts**):

    ```bash
    MYSQL_IP=$(getent hosts ${mysql_host} | awk '{ print $1 }')
    ```
* Клонирует [git-репозиторий](https://github.com/alex-bel31/conf-docker-nginx) с проектом.
* Запускает [deploy-scripts.sh](https://github.com/alex-bel31/conf-docker-nginx/blob/main/deploy-scripts.sh) — скрипт развёртывания, содержащий запуск **docker compose**.

Сам шаблон cloud-init лежит в [cloud-init/app.yaml.tpl]().

## Dockerfile

Dockerfile включает мультисборку:

1. Стадия **builder:**

   * Устанавливаются зависимости из **requirements.txt**.
   * Устанавливаются в директорию **/install** с минимальным образом `python:3.9-slim`.

2. Финальный образ:

   * Копируются библиотеки и код.
   * Устанавливается рабочая директория **/app**.
   * Запускается **main.py**.

Образ сохранен в Yandex Container Registry с тегом `webapp:latest`.

## Интеграция с БД

* В **cloud-init** на основе значения `${mysql_host}` происходит разрешение имени в IP.

* Эти данные подставляются в **.env**, где описаны переменные подключения:

  ```env
    DB_USER=${db_user}
    DB_PASSWORD=${db_password}
    DB_NAME=${db_name}
    DB_HOST=$${MYSQL_IP}
  ```

* Далее приложение запускается через Docker Compose и использует эти параметры для подключения к БД.

Приложение доступно по адресу: http://158.160.110.14/

## Terraform remote state

* Используется для удаленного хранения state используется S3 бакет в Yandex Object Storage.
* Блокировка состояний обеспечивается через совместимую с DynamoDB таблицу **tfstate-lock** в Yandex Cloud через docapi endpoint.
* Все значения бэкенда вынесены в отдельный файл и подставляются через CLI при инициализации проекта:

    ```bash
    terraform init -backend-config=env/backend.tfbackend
    ```