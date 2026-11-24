--!strict
-- Enabled only in the controlled Stage 0.4 test copy.
local folder = game:GetService("ServerStorage"):WaitForChild("SK_LuauPipeline_Test")
local result = require(folder.RunUnitTest)(require(folder.ResourceMath), require(folder.ResourceMath_Test))
script:SetAttribute("RunCount", result.run)
script:SetAttribute("Passed", result.passed)
script:SetAttribute("Failed", result.failed)
script:SetAttribute("Completed", true)
script:SetAttribute("ResultsJSON", game:GetService("HttpService"):JSONEncode(result))
assert(result.failed == 0, "Stage 0.4 test failure; see named results above")
