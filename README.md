# SKYKEEPERS

Проект по созданию игры на Roblox и Luau о личном острове, магических ресурсах и исследовании. Репозиторий содержит локальные снимки проекта, исходники, модели и отчёты; опубликованная игра в рамках этих этапов не обновлялась.

## Текущее состояние

Последняя рабочая копия — [Stage 0.8](SKYKEEPERS_STAGE_08/SKYKEEPERS_STAGE_08.rbxl): сбор ресурсов, временный серверный инвентарь, торговец и сессионные Sky Coins. DataStore, Robux и межигроковая торговля не включены. Подробности и ограничения — в [состоянии проекта](PROJECT_STATE.md) и [отчёте Stage 0.8](SKYKEEPERS_STAGE_08/STAGE_08_REPORT.md).

## Установка и запуск

1. Клонируйте репозиторий и установите Roblox Studio, VS Code и Rojo. Для моделей нужен Blender; для локальных проверок Luau — Luau CLI.
2. Откройте в Roblox Studio локальный файл [SKYKEEPERS_STAGE_08.rbxl](SKYKEEPERS_STAGE_08/SKYKEEPERS_STAGE_08.rbxl). Работайте с копией, если планируете менять сцену. Файл не публикует игру автоматически.
3. Для синхронизации исходников в PowerShell из каталога `SKYKEEPERS_STAGE_08` запустите `rojo serve default.project.json` и подключите плагин Rojo в этой же тестовой копии. Перед применением проверьте предлагаемые изменения. Mapping не предназначен для замены всей игровой сцены.

Инструменты: [Roblox Studio](https://create.roblox.com/docs/studio/setup), [VS Code](https://code.visualstudio.com/), [Rojo](https://github.com/rojo-rbx/rojo), [Luau CLI](https://github.com/luau-lang/luau/releases), [Blender](https://www.blender.org/). Проверенные версии и ограничения описаны в отчётах этапов; локальные установочные файлы инструментов в репозиторий не включены.

## Структура папок

| Папка | Содержимое |
|---|---|
| [blender_roblox_pipeline_test_20261109](blender_roblox_pipeline_test_20261109/) | Stage 0.2: Sky Heart, Blender, FBX, сохранённый place и отчёт |
| [SKYKEEPERS_ASSET_PIPELINE](SKYKEEPERS_ASSET_PIPELINE/) | Stage 0.3: производство ассетов, модели и каталог |
| [SKYKEEPERS_LUAU_PIPELINE](SKYKEEPERS_LUAU_PIPELINE/) | Stage 0.4: Luau, математические тесты и таблица баланса |
| [SKYKEEPERS_STAGE_05_QA](SKYKEEPERS_STAGE_05_QA/) | Stage 0.5: изолированная QA-копия, тесты и отчёты |
| [SKYKEEPERS_STAGE_06](SKYKEEPERS_STAGE_06/) | Stage 0.6: остров и игровой цикл |
| [SKYKEEPERS_STAGE_07](SKYKEEPERS_STAGE_07/) | Stage 0.7: каталог ресурсов и таблицы выпадения |
| [SKYKEEPERS_STAGE_08](SKYKEEPERS_STAGE_08/) | Stage 0.8: экономика, торговец, тесты и аудит транзакций |

## Выполненные этапы

Stage 0.2 и 0.3 — PASSED с предупреждениями; Stage 0.4 — PASSED с предупреждениями, 51/51 тестов. Stage 0.5 — результаты и оставшиеся замечания в [отчёте](SKYKEEPERS_STAGE_05_QA/STAGE_05_REPORT.md). Stage 0.6 — **PARTIAL**; Stage 0.7 и Stage 0.8 — **PASSED с предупреждениями**. Stage 0.9 не начат. Исторические файлы сохранены как доступные снимки, а не как искусственно созданные прошлые коммиты.

## Запуск тестов

Установите Luau CLI и запускайте команды из указанных каталогов:

```powershell
cd SKYKEEPERS_LUAU_PIPELINE
luau run_tests.luau
cd ../SKYKEEPERS_STAGE_08
luau tests/economy.luau
luau tests/stage07.luau
luau tests/transaction_boundaries.luau
luau stage06_reference/tests/negative_gameplay.luau
```

Тест Stage 0.6 запускает сохранённые модули того этапа; тесты Stage 0.8 отдельно проверяют текущую экономику. Результаты и границы Studio-тестов приведены в [STAGE_08_TEST_RESULTS.md](SKYKEEPERS_STAGE_08/STAGE_08_TEST_RESULTS.md). Утверждённые математические ожидания маршрутов — 72, 158.2 и 211.2 SC; это не гарантированные награды: [ECONOMY_MODEL.md](SKYKEEPERS_LUAU_PIPELINE/ECONOMY_MODEL.md).

## Известные проблемы

- Повторное подключение того же UserId к тому же тестовому серверу — **BLOCKED**.
- Аудио `203785492` — **UNRESOLVED**; источник и влияние не установлены.
- Тайм-ауты загрузки некоторых mesh и animation — **UNRESOLVED**: [аудит](SKYKEEPERS_STAGE_08/ASSET_LOADING_AUDIT.md).
- Редкости ресурсов ожидают утверждения; отдельный GDD с ними в рабочем пространстве не найден.
- Проверка продажи на безопасной границе и её ограничения описаны в [аудите транзакции](SKYKEEPERS_STAGE_08/TRANSACTION_SAFETY_AUDIT.md). Это сессионная экономика без долговечной записи; сбой сервера и доставка ответа не гарантированы.

## Следующие этапы

После отдельного решения владельца проекта: исследовать известные проблемы, утвердить редкости и спланировать следующий этап. Stage 0.9 автоматически не запускался.
