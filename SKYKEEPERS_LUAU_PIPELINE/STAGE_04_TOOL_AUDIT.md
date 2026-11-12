# STAGE_04_TOOL_AUDIT

Проверено 2026-11-11–12, рабочая папка C:\SKYKEEPERS. Итог: инструменты для обязательного цикла доступны; отдельные удобства редактора отсутствуют.

| Инструмент | Факт и версия | Реальная проверка / ограничение |
|---|---|---|
| VS Code | 1.145.3, commit dcd3ad6e368fbe19d03f37054a40dbaf40d676f4, x64 | C:\Users\razaw\AppData\Local\Programs\Microsoft VS Code\Code.exe. ResourceMath открыт, исправлен и сохранён через GUI. CLI --version выдал версию вместе с EPERM на chdir; GUI работает. |
| Rojo CLI | 7.7.1 | C:\Users\razaw\AppData\Local\Microsoft\WinGet\Packages\Rojo.Rojo_Microsoft.Winget.Source_8wekyb3d8bbwe\rojo.exe. Build и реальная синхронизация выполнены. |
| Rojo Plugin | 7.7.1 | В окне Stage04: подключение к localhost:34874, просмотр diff, Accept. Четыре Source совпали с файлами. |
| VS Code Rojo extension | evaera.vscode-rojo 2.1.2 | Найден в extensions. Синхронизация выполнялась CLI и Studio Plugin; работоспособность команды расширения отдельно не заявляется. |
| Luau Language Server | Не найден в PATH и установленных расширениях VS Code | Не установлен. Замена: пакетный luau-analyze; интерактивная диагностика LSP не проверена. VS Code открыл .luau как Plain Text в Restricted Mode. |
| StyLua | Не найден в PATH и проверенных локальных bin | Не установлен. Использовано единообразное ручное форматирование, проверка синтаксиса компилятором; автоматическое форматирование не заявляется. |
| Selene | Не найден | Альтернатива: официальный luau-analyze 0.746, анализ типов и встроенный lint. |
| Luau CLI | Portable 0.746 | tools\luau-0.746\luau.exe: три реальных прогона по 51 тесту, Exit 0. |
| Luau static analysis | Portable 0.746 | tools\luau-0.746\luau-analyze.exe. Чистые модули и CLI runner: итоговый Exit 0. Roblox server adapter отдельно скомпилирован; полного анализа Roblox API типов без LSP/definitions не заявляем. |
| Roblox Output | Доступен | MCP get_console_output: сохранены output_01.txt и output_02_reopened.txt, включая постороннюю ошибку asset 203785492. |
| Автоматический Play | Доступен | MCP запустил/остановил два Play. Атрибуты серверного Script и полный JSON подтвердили 51 PASS / 0 FAIL каждый раз. |

## Происхождение локального Luau

Проверен официальный выпуск [luau-lang/luau 0.746](https://github.com/luau-lang/luau/releases/tag/0.746), затем GitHub API выпуска вернул SHA256 Windows-архива. Загружен https://github.com/luau-lang/luau/releases/download/0.746/luau-windows.zip.

SHA256: e149fdb4fe78a52ce457fbd40741484eaab1dbf9907e7f878c6d8a9a3dac2ddd — совпал перед распаковкой.
Файлы находятся только в C:\SKYKEEPERS\SKYKEEPERS_LUAU_PIPELINE\tools. Глобальная установка, изменение PATH и установка расширений не выполнялись. Сетевое чтение и скачивание прошли проверку разрешений.

## Сетевой доступ и GUI

Первый Rojo serve в ограниченной среде слушал порт, но Studio получила HTTP request timed out. Он остановлен; разрешённый повторный запуск с доступом к локальной сети обеспечил настоящую синхронизацию. Отдельная проверка HTTP localhost не выполнилась: automatic approval review исчерпала лимит использования. Это сбой проверки, не вывод о небезопасности действия; запрос не обходился. Результат соединения установлен штатным плагином при уже разрешённом сервере.

VS Code показал запрос доверия; агент его не подтверждал. Пользователю предложен Restricted Mode, затем наблюдался новый редактор именно в этом режиме. Приостановка GUI по Esc соблюдена; возобновление выполнено после прямого указания пользователя. Между сообщениями окна исходного проекта и Stage04 были закрыты; копия открыта повторно.

Безопасность mapping сверена с [официальным форматом Rojo](https://rojo.space/docs/v7/project-format/): явно задан $ignoreUnknownInstances=true для корня и сервисов, Workspace не отображается на файловую систему.
