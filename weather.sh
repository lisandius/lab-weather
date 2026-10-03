#!/bin/bash
# Использование: weather.sh <город> [файл_вывода]
# Выводит температуру и влажность в указанном городе (wttr.in + jq)
# и записывает результат в HTML-файл (по умолчанию — индекс nginx).
CITY="${1:?Использование: $0 <город> [файл_вывода]}"
OUT="${2:-/var/www/html/index.html}"

# wttr.in иногда отдаёт пустой/обрезанный ответ — повторяем запрос
for attempt in 1 2 3 4 5 6 7 8 9 10; do
    JSON=$(curl -s -4 -m 20 -A "curl/8" "wttr.in/${CITY}?format=j1")
    TEMP=$(echo "$JSON" | jq -r '.current_condition[0].temp_C' 2>/dev/null)
    HUM=$(echo "$JSON" | jq -r '.current_condition[0].humidity' 2>/dev/null)
    [ -n "$TEMP" ] && [ "$TEMP" != "null" ] && break
    TEMP=""; sleep 2
done

if [ -z "$TEMP" ]; then
    echo "Не удалось получить погоду для ${CITY}" >&2
    exit 1   # старый index.html остаётся нетронутым
fi

TMP=$(mktemp)
cat > "$TMP" <<HTML
<!DOCTYPE html>
<html lang="ru">
<head><meta charset="utf-8"><title>Погода: ${CITY}</title></head>
<body>
<h1>Погода: ${CITY}</h1>
<p>Температура: <b>${TEMP}&deg;C</b></p>
<p>Влажность: <b>${HUM}%</b></p>
<p><small>Обновлено: $(date '+%Y-%m-%d %H:%M:%S')</small></p>
</body>
</html>
HTML
cat "$TMP" > "$OUT" && rm -f "$TMP"
echo "${CITY}: ${TEMP}°C, влажность ${HUM}%"
