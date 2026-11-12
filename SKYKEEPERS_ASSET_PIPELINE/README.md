# SKYKEEPERS_ASSET_PIPELINE

Reusable Python library executed inside Blender, not ordinary Python. Actual tested runtime: Blender 5.3.0 at the Steam executable path; Stage 0.2 used 5.2.3 LTS before the Steam update.

```powershell
& 'C:\Program Files (x86)\Steam\steamapps\common\Blender\blender.exe' --background --factory-startup --python-exit-code 1 --python 'C:\SKYKEEPERS\SKYKEEPERS_ASSET_PIPELINE\build_assets.py' -- --out 'C:\SKYKEEPERS\SKYKEEPERS_ASSET_PIPELINE\runs\NEW_UNIQUE_RUN'
```

Every run directory must be new. Existing directories are rejected before scene work. Never delete old outputs to rerun a build. Increment the run identifier; increment AssetKey version for revised production assets.

## Extension API

Implement a builder function that only creates mesh objects. Reuse material(), stem(), ico(), gem(), finish(). Then call build_asset(root, unique_key, title, target_studs_xyz, triangle_budget, builder).
The shared pipeline resets a private background scene, bakes transforms, recalculates normals, triangulates, rejects nonmanifold and degenerate geometry, normalizes world vertex dimensions, sets a shared bottom-center origin, validates budgets, saves BLEND, exports mesh-only FBX, imports into a clean scene, compares geometry and materials, and creates manifest.json with SHA256 and Roblox preparation data.

Geometry uses metres; 1 stud = 0.28 m. Blender Z-up maps to Roblox Y-up. The manifest stores each mesh's source-space centre, dimensions and linear base color. Convert colors to sRGB in Roblox. Do not assume Roblox preserves FBX units, pivot or colors.

## Current authoritative build

runs/stage03_002. stage03_001 is retained for diagnostics: the first implementation did not update the view layer before baking object scale. The bug is fixed in finish(). Both runs passed roundtrip, but only 002 is the intended geometry.

## Import boundary

Roblox upload requires asset:read/asset:write and explicit approval of this directory. Upload failures must never be bypassed by moving assets into another approved directory. Track each returned operation and asset ID to avoid duplicate uploads.
Use Workspace.SK_AssetPipeline_Test only. Never edit SkyHeart_Pipeline_02. For each imported mesh compare names, set size/placement from manifest, validate orientation, convert color, set Anchored and collision policy, then test Client and reopen the saved RBXL.
Mesh IDs and Model IDs are distinct. SourceTriangleCount is metadata, not a Roblox geometry measurement.

## Validated Stage 0.3 result

All three models passed Blender export/reimport, Roblox Edit/Play and local RBXL close/reopen. See ASSET_CATALOG.md and roblox_validation_final.json for actual asset IDs. validate_stage03.luau is a read-only check for the three placed models. The local copy is SKYKEEPERS_STAGE_03.rbxl. User assistance was required to grant the upload directory and complete the Save dialog; fully unattended GUI saving is not yet proven. Package scale, orientation and colors must be prepared again after fresh insertion.
