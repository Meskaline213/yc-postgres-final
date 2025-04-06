# 📦 Yandex.Cloud Terraform Deployment with PostgreSQL and Python Web App

## ✅ Что делает этот проект

Этот Terraform-проект автоматически:
1. Создаёт виртуальную машину в Яндекс.Облаке (Ubuntu 22.04, 2 vCPU, 2 GB RAM, 20 GB HDD)
2. Устанавливает Docker и PostgreSQL (нативно, без контейнера)
3. Клонирует репозиторий `DEVOPS-praktikum_Docker`
4. Копирует `web.py` и `web.conf` в директорию `/srv/app/`
5. Подставляет внутренний IP-адрес виртуальной машины в параметр `db_host` в `web.conf`
6. Открывает порт 5432 для внешнего подключения к БД

## 🛠 Как использовать

1. Установите [Yandex.Cloud CLI](https://cloud.yandex.ru/docs/cli/quickstart) и выполните:
   ```bash
   yc iam create-token
   ```

2. Заполните файл `terraform.tfvars`:
   ```hcl
   token     = "ваш_oauth_токен"
   cloud_id  = "ваш_cloud_id"
   folder_id = "ваш_folder_id"
   ```

3. Запустите:
   ```bash
   terraform init
   terraform apply -auto-approve
   ```

## 🔗 После запуска

- IP-адрес ВМ будет выведен как output
- Приложение будет доступно на порту `80` (если вы вручную запустите контейнер на основе web.py)
- Подключение к PostgreSQL:
  ```bash
  psql -h <внешний_ip> -U myuser -d mydb
  ```

## 🧾 Конфигурация PostgreSQL

- Пользователь: `myuser`
- Пароль: `Amsterdamtoday2025!`
- База данных: `mydb`

## ⚠️ Примечание

- Файл `web.py` **не заменяется автоматически** — используется оригинальный из репозитория
- Для запуска приложения нужно вручную собрать Docker-образ и запустить контейнер с монтированием `/srv/app`