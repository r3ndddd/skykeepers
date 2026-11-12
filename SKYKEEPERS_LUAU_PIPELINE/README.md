# SKYKEEPERS Luau pipeline

Run `./check.ps1` from PowerShell to validate the narrow mapping, statically analyze the pure modules, compile the server adapter, run 51 tests and build a scripts-only diagnostic file in a unique checks directory. The diagnostic RBXLX is not the game copy and must not replace it.

Edit the authoritative files under `src` in VS Code. Never edit the corresponding Source directly in Studio. Start `rojo serve default.project.json --address 127.0.0.1 --port 34874` and connect the Rojo plugin ONLY in `C:\SKYKEEPERS\SKYKEEPERS_LUAU_PIPELINE\SKYKEEPERS_STAGE_04.rbxl`. Inspect the proposed diff before accepting.

Only ServerStorage.SK_LuauPipeline_Test and ServerScriptService.SK_LuauPipeline_Test are mapped. Root and services explicitly preserve unknown instances. Workspace is not mapped. Rojo's project name changes the test DataModel name; no game objects or existing scripts are owned by this mapping.

Press Play. The enabled server Runner runs once automatically; do not invoke the suite a second time for the same run. Every case prints [STAGE04][PASS/FAIL]. The runner stores Completed, RunCount, Passed, Failed and ResultsJSON attributes in the Play server DataModel for automated collection. These runtime attributes are not expected in the saved Edit file. Stop Play, save the local copy, stop Rojo, close/reopen the file and repeat Play to verify persistence.

ResourceMath is pure Luau with no game services, currencies or persistence. Tests follow the existing project's injected-module convention. Fixtures and independently derived references are documented in ECONOMY_MODEL.md. The test runner remains enabled only in this test copy.

Optional editor integrations Luau Language Server and StyLua were unavailable; they were not installed. Official portable Luau 0.746 provides CLI type analysis, linting, compilation and tests. See STAGE_04_TOOL_AUDIT.md for provenance and limitations.
