local calculate = require('./broken_before')
assert(calculate(7, 3) == 10, 'controlled defect: expected 10 for 7 + 3, got ' .. tostring(calculate(7, 3)))
print('[PASS] controlled addition')
