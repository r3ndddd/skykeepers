--!strict
local result = require("./src/tests/RunUnitTest")(
	require("./src/tests/ResourceMath"), require("./src/tests/ResourceMath_Test")
)
assert(result.failed == 0, "Unit tests failed")
