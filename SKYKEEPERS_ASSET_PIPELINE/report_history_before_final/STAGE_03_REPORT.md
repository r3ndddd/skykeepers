# SKYKEEPERS Stage 0.3

Дата: 2026-11-11. **Статус: INCOMPLETE / BLOCKED_UPLOAD_DIRECTORY. Не PASSED.**

## Выполнено

Прочитан C:\SKYKEEPERS\blender_roblox_pipeline_test_20261109\BLENDER_ROBLOX_PIPELINE_REPORT.md. Его исторические INCOMPLETE-разделы отличены от последнего результата Stage 0.2.
SkyHeart.blend, SkyHeart.fbx и SKYKEEPERS_STAGE_02.rbxl существуют. Имя sky_heart.blend с подчёркиванием не найдено; реальный исходник называется SkyHeart.blend.
В текущем проекте Place 129579887029782 / Universe 10775590030 обнаружен Workspace.SkyHeart_Pipeline_02. Атрибут PipelineAssetId=72262853317816 и все шесть Mesh ID совпали с отчётом Stage 0.2. Это проверка происхождения по ID и локальному отчёту; облачный asset не скачивался для побайтового сравнения с FBX. Исправленный экземпляр отличается от исходного package цветами и масштабом, как и отмечалось в Stage 0.2.
Через GUI открыта сохранённая копия Stage 0.2, закрыта без сохранения, повторно открыта; после этого MCP подтвердил 6 мешей, тот же Asset ID и pivot (12,43,-4). SHA256 BLEND, FBX и RBXL после аудита совпали с исходными.

Создана C:\SKYKEEPERS\SKYKEEPERS_ASSET_PIPELINE: общая библиотека bpy для геометрии, материалов, размеров, pivot, триангуляции, проверки manifold/площади граней/бюджета, экспорта и повторного импорта. World-space координаты треугольников сравниваются с округлением до 5 знаков; материалы и цвета — с допуском 1e-5. Отчёты содержат размеры, центры частей, SHA256, пути и статусы для Roblox.

## Авторитетная сборка: runs/stage03_002

| AssetKey | Размер XYZ, studs | Треугольники | Meshes | Blender export/reimport | Roblox |
|---|---|---:|---:|---|---|
| cloudwood_tree_v001 | 5 × 8 × 5 | 84 / 1500 | 4 | PASS / PASS | NOT_RUN |
| skyglass_crystal_v001 | 2 × 3 × 2 | 64 / 500 | 3 | PASS / PASS | NOT_RUN |
| starbloom_plant_v001 | 2 × 2 × 2 | 184 / 500 | 9 | PASS / PASS | NOT_RUN |

В каждой папке модели лежат одноимённые BLEND, FBX, PNG и manifest.json. Полные пути и материалы перечислены в ASSET_CATALOG.md. Превью всех трёх моделей просмотрены. Исходники не содержат камер и света: preview_assets.py добавляет их только в отдельном процессе без повторного сохранения BLEND.

## Созданные файлы системы

- pipeline.py — общие функции.
- build_assets.py — три рецепта и CLI со строгим отказом перезаписи.
- roblox_prepare.luau — общие prepare/validate для импортированных моделей; подготовлен, но ещё не проверен исполнением в Studio.
- preview_assets.py — отдельный рендер превью.
- README.md — запуск, правила расширения и ограничение импорта.
- ASSET_CATALOG.md, ACTION_LOG.md, STAGE_03_REPORT.md.
- stage02_hashes_before.json; журналы build_001.log, build_002.log, preview.log, preview_retry.log, overwrite_guard.log.
- runs/stage03_001 — сохранённая первая диагностическая сборка; не использовать для импорта.
- runs/stage03_002 — исправленная сборка и catalog.json.

## Тесты и исправления

1. Сборка stage03_002: Exit 0, все три экспорта и сравнения FBX успешны.
2. Отказ перезаписи: повторный запуск в существующую папку дал ожидаемый Exit 1 / FileExistsError до операций над сценой.
3. Исправлена ошибка первого варианта bake: object scale не попадал в matrix_world без update view layer. После исправления все модели пересобраны в новую папку.
4. Исправлена ошибка preview: read_factory_settings(use_empty=True) оставляет World=None; рендер теперь создаёт World. Повторный рендер Exit 0.
5. Аудит сохранности Sky Heart после закрытия/повторного открытия: PASS для сохранённой копии Stage 0.2.

## Предупреждения и ограничения

- По прежнему Steam-пути установлен уже Blender 5.3.0, hash 02f0899d78e3. На 5.2.3 эту библиотеку не тестировали; версия не выдаётся за прежнюю.
- Blender сообщает WinError 5 при записи кэша extensions вне проекта. Экспорт и рендер завершились успешно.
- API scopes asset:read/asset:write проверены, HTTP 200. Но попытка загрузки FBX отклонена: файл не внутри approved upload directory. Никакого нового asset ID не получено; ноль успешных загрузок.
- Пользователю отправлен запрос разрешить C:\SKYKEEPERS\SKYKEEPERS_ASSET_PIPELINE. Данные не перемещались для обхода запрета.
- Workspace.SK_AssetPipeline_Test пока не создана; модели не вставлены, поэтому размеры/ориентация/pivot/коллизии/Anchored/материалы в Studio, Play и повторное открытие с новыми моделями пока NOT_RUN.
- Тестовая копия Stage 0.3 ещё не сохранена: новых моделей в Studio нет. Исходная Stage 0.2 сохранена и проверена, но не подменяет требуемый тест Stage 0.3.
- Основной Sky Heart, существующие объекты и исходники не изменены. Игровой мир не строился. Подробная последовательность действий, интерфейсы и участие пользователя — ACTION_LOG.md.

## Следующий шаг

После подтверждения папки загрузок повторить upload на существующий SKYKEEPERS, записать operation/asset IDs, создать Workspace.SK_AssetPipeline_Test, вставить три модели и проверить roblox_prepare.luau на них. Провести Play, сохранить новую локальную копию и реально закрыть/повторно открыть её, сверив модели и неизменность Sky Heart. До этих проверок статус остаётся INCOMPLETE.
