# STAGE_04_TEST_RESULTS

2026-11-12. 51 unique tests. Final local CLI: 51 PASS / 0 FAIL. Studio server Play: 51 PASS / 0 FAIL. Studio server Play after close/reopen with Rojo stopped: 51 PASS / 0 FAIL.

Three local runs (initial, type fix, reusable check.ps1 verification) and two server Play runs: 255 case executions, 255 PASS, 0 FAIL. Initial static analysis failed with 11 distinct type diagnostics, duplicated through require traversal; fixed in VS Code. Final analysis exit 0. Static diagnostics are separate from test counts.

| # | Test | CLI final | Server Play | Reopened server Play |
|---|---|---|---|---|
| 1 | Whispering Meadows contribution 1 | PASS | PASS | PASS |
| 2 | Whispering Meadows contribution 2 | PASS | PASS | PASS |
| 3 | Whispering Meadows contribution 3 | PASS | PASS | PASS |
| 4 | Whispering Meadows probability sum | PASS | PASS | PASS |
| 5 | Whispering Meadows independent expectation | PASS | PASS | PASS |
| 6 | Whispering Meadows route | PASS | PASS | PASS |
| 7 | Crystal Ruins contribution 1 | PASS | PASS | PASS |
| 8 | Crystal Ruins contribution 2 | PASS | PASS | PASS |
| 9 | Crystal Ruins contribution 3 | PASS | PASS | PASS |
| 10 | Crystal Ruins probability sum | PASS | PASS | PASS |
| 11 | Crystal Ruins independent expectation | PASS | PASS | PASS |
| 12 | Crystal Ruins route | PASS | PASS | PASS |
| 13 | Storm Temple contribution 1 | PASS | PASS | PASS |
| 14 | Storm Temple contribution 2 | PASS | PASS | PASS |
| 15 | Storm Temple contribution 3 | PASS | PASS | PASS |
| 16 | Storm Temple probability sum | PASS | PASS | PASS |
| 17 | Storm Temple independent expectation | PASS | PASS | PASS |
| 18 | Storm Temple route | PASS | PASS | PASS |
| 19 | empty drops | PASS | PASS | PASS |
| 20 | sum above one | PASS | PASS | PASS |
| 21 | sum below one | PASS | PASS | PASS |
| 22 | negative price | PASS | PASS | PASS |
| 23 | negative probability | PASS | PASS | PASS |
| 24 | wrong container type | PASS | PASS | PASS |
| 25 | wrong row type | PASS | PASS | PASS |
| 26 | wrong probability type | PASS | PASS | PASS |
| 27 | wrong price type | PASS | PASS | PASS |
| 28 | missing probability | PASS | PASS | PASS |
| 29 | missing price | PASS | PASS | PASS |
| 30 | NaN probability | PASS | PASS | PASS |
| 31 | NaN price | PASS | PASS | PASS |
| 32 | infinite probability | PASS | PASS | PASS |
| 33 | infinite price | PASS | PASS | PASS |
| 34 | negative infinity | PASS | PASS | PASS |
| 35 | sparse array | PASS | PASS | PASS |
| 36 | dictionary keys | PASS | PASS | PASS |
| 37 | outside tolerance | PASS | PASS | PASS |
| 38 | nil drops | PASS | PASS | PASS |
| 39 | inside tolerance | PASS | PASS | PASS |
| 40 | zero price and probability | PASS | PASS | PASS |
| 41 | zero gathers | PASS | PASS | PASS |
| 42 | invalid count -1 | PASS | PASS | PASS |
| 43 | invalid count 0.5 | PASS | PASS | PASS |
| 44 | invalid count inf | PASS | PASS | PASS |
| 45 | invalid count nan | PASS | PASS | PASS |
| 46 | invalid count 9 | PASS | PASS | PASS |
| 47 | invalid expectation -1 | PASS | PASS | PASS |
| 48 | invalid expectation inf | PASS | PASS | PASS |
| 49 | invalid expectation nan | PASS | PASS | PASS |
| 50 | invalid expectation 8 | PASS | PASS | PASS |
| 51 | route overflow | PASS | PASS | PASS |

Final routes: Whispering Meadows 72 SC; Crystal Ruins 158.2 SC; Storm Temple 211.2 SC. Each contribution and probability sum checked independently. Expectation oracle enumerates 100 equally likely outcomes; route oracle uses repeated addition.

Evidence: unit_initial.log, unit_fixed.log, analysis_initial.log, analysis_fixed.log, play_01.json, output_01.txt, output_02_reopened.txt, verification_final.json, checks/.

Output reviewed: no Stage04 runtime failures. Existing asset 203785492 emits Asset type does not match requested type three times in each Play session. The existing game asset was not changed to hide this warning.
