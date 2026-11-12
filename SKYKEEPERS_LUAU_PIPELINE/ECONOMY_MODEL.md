# Stage 0.4 — mathematical contract

Final user-confirmed reference values. Probabilities, prices and gather counts are unchanged. This is a pure calculation test, not an economy implementation.

| Route | Probabilities | Contributions to expected value | Sum of probabilities | Expected value | Gathers | Route SC |
|---|---|---|---:|---:|---:|---:|
| Whispering Meadows | 0.70, 0.25, 0.05 | 0.70×5=3.5; 0.25×12=3; 0.05×30=1.5 | 1 | 8 | 9 | **72** |
| Crystal Ruins | 0.55, 0.40, 0.05 | 0.55×12=6.6; 0.40×30=12; 0.05×80=4 | 1 | 22.6 | 7 | **158.2** |
| Storm Temple | 0.60, 0.38, 0.02 | 0.60×30=18; 0.38×80=30.4; 0.02×220=4.4 | 1 | 52.8 | 4 | **211.2** |

ExpectedValue = sum(probability × price). RouteValue = ExpectedValue × count.
ValidateDropTable returns boolean and optional error text. Calculations raise errors on invalid inputs. Drop arrays must be nonempty and dense; probability/price fields must be finite nonnegative numbers. Probability sum tolerance is 0.000001. No probability renormalization occurs. Count must be a finite nonnegative integer. Overflow is rejected.

Independent checks cover each contribution, sum of probabilities, an expectation computed by enumerating 100 equally likely outcomes, and route value by repeated addition. Decimal comparisons use absolute tolerance 0.000001. No currency issuance, inventory, DataStore or game balance changes.
