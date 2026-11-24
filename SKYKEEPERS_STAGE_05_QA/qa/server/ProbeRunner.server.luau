local probe = require(game.ServerStorage.SK_Stage05_Test.Probe)
local actual = probe(7, 3)
if actual == 10 then
	print('[STAGE05][PASS] probe 7+3 = 10')
else
	warn(('[STAGE05][FAIL] probe 7+3 expected 10, got %s'):format(actual))
end
script:SetAttribute('Actual', actual)
script:SetAttribute('Passed', actual == 10)
script:SetAttribute('Completed', true)
