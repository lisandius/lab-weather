# Лаб. П02 — Автоматизация в Linux: скрипт погоды

Bash-скрипт принимает город, получает текущую температуру и влажность
из [wttr.in](https://github.com/chubin/wttr.in) (JSON, `format=j1`), разбирает
ответ с помощью `jq` и записывает HTML-страницу в `index.html` дефолтного
сайта nginx. Запуск — по cron раз в минуту.

## Содержимое

| Файл | Назначение |
|---|---|
| `weather.sh` | Сам скрипт: `weather.sh <город> [файл_вывода]` |
| `screenshots/` | Подтверждение работы |

## Стенд

VM Ubuntu 24.04 (VMware, NAT-сеть `192.168.227.0/24`), пользователь `runner`,
vm1 = `192.168.227.15`.

## Как воспроизвести

```bash
sudo apt update && sudo apt install -y nginx jq curl
sudo touch /var/www/html/index.html && sudo chmod o+w /var/www/html/index.html
cp weather.sh ~/weather.sh && chmod +x ~/weather.sh

~/weather.sh Perm            # разовый запуск
curl 127.0.0.1               # проверка страницы

crontab -e                   # добавить строку:
# * * * * * /home/runner/weather.sh Perm >> /home/runner/weather.log 2>&1
crontab -l
```

## Особенности реализации

- `wttr.in` иногда отдаёт пустой или обрезанный JSON, поэтому запрос
  повторяется до 10 раз, а `index.html` перезаписывается только при успешном
  разборе ответа (при неудаче остаётся прошлая страница, код выхода 1).
- Файл пишется через `cat > файл`, а не заменой, поэтому права и владелец
  `index.html` сохраняются (достаточно `chmod o+w`, как в лекции).
- Города можно передавать любые, например `weather.sh Moscow`.

## Скриншоты

1. `screenshots/01-cron.png` — `crontab -l`, права на `index.html`, лог запусков.
2. `screenshots/02-script-and-curl.png` — запуск скрипта и ответ nginx.
3. `screenshots/03-browser.png` — страница в браузере (`http://192.168.227.15/`).
