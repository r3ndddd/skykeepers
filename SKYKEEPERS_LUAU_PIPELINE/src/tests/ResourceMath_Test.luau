--!strict
-- Contract tests; same injected-module convention as existing Economy.spec.
return function(ResourceMath: any, t: any)
	local function near(actual: number, expected: number)
		assert(actual == actual and math.abs(actual - expected) <= 1e-6,
			string.format("expected %.12g, got %.12g", expected, actual))
	end
	local function rejects(value: any)
		local valid, reason = ResourceMath.ValidateDropTable(value)
		assert(valid == false and type(reason) == "string")
		assert(not pcall(ResourceMath.CalculateExpectedValue, value), "invalid drops must raise")
	end
	local zones = {
		{ name = "Whispering Meadows", weights = {70, 25, 5}, prices = {5, 12, 30}, terms = {3.5, 3, 1.5}, ev = 8, count = 9, route = 72 },
		{ name = "Crystal Ruins", weights = {55, 40, 5}, prices = {12, 30, 80}, terms = {6.6, 12, 4}, ev = 22.6, count = 7, route = 158.2 },
		{ name = "Storm Temple", weights = {60, 38, 2}, prices = {30, 80, 220}, terms = {18, 30.4, 4.4}, ev = 52.8, count = 4, route = 211.2 },
	}
	for _, zone in ipairs(zones) do
		local drops = {}
		for i, weight in ipairs(zone.weights) do
			drops[i] = { probability = weight / 100, price = zone.prices[i] }
			-- Independent hand-derived contribution of each drop.
			t.test(zone.name .. " contribution " .. i, function()
				near(drops[i].probability * drops[i].price, zone.terms[i])
			end)
		end
		-- Check probabilities without invoking production validation.
		t.test(zone.name .. " probability sum", function()
			local sum = 0
			for _, row in ipairs(drops) do sum += row.probability end
			near(sum, 1)
			assert(ResourceMath.ValidateDropTable(drops))
		end)
		-- Expected value oracle uses 100 equally likely outcomes, not weighted multiplication.
		t.test(zone.name .. " independent expectation", function()
			local outcomeSum, outcomeCount = 0, 0
			for i, weight in ipairs(zone.weights) do
				for _ = 1, weight do
					outcomeSum += zone.prices[i]
					outcomeCount += 1
				end
			end
			assert(outcomeCount == 100)
			near(outcomeSum / outcomeCount, zone.ev)
			near(ResourceMath.CalculateExpectedValue(drops), outcomeSum / outcomeCount)
		end)
		-- Route oracle uses repeated addition and the user-confirmed route total.
		t.test(zone.name .. " route", function()
			local reference = 0
			for _ = 1, zone.count do reference += zone.ev end
			near(reference, zone.route)
			near(ResourceMath.CalculateRouteValue(ResourceMath.CalculateExpectedValue(drops), zone.count), zone.route)
		end)
	end

	-- Each malformed fixture is independently rejected by validation and calculation.
	local invalid: { { name: string, value: any } } = {
		{ name = "empty drops", value = {} },
		{ name = "sum above one", value = {{probability = 1.1, price = 5}} },
		{ name = "sum below one", value = {{probability = 0.9, price = 5}} },
		{ name = "negative price", value = {{probability = 1, price = -1}} },
		{ name = "negative probability", value = {{probability = -0.1, price = 1}, {probability = 1.1, price = 1}} },
		{ name = "wrong container type", value = "drops" },
		{ name = "wrong row type", value = {5} },
		{ name = "wrong probability type", value = {{probability = "1", price = 5}} },
		{ name = "wrong price type", value = {{probability = 1, price = "5"}} },
		{ name = "missing probability", value = {{price = 5}} },
		{ name = "missing price", value = {{probability = 1}} },
		{ name = "NaN probability", value = {{probability = 0/0, price = 5}} },
		{ name = "NaN price", value = {{probability = 1, price = 0/0}} },
		{ name = "infinite probability", value = {{probability = math.huge, price = 5}} },
		{ name = "infinite price", value = {{probability = 1, price = math.huge}} },
		{ name = "negative infinity", value = {{probability = 1, price = -math.huge}} },
		{ name = "sparse array", value = {[1] = {probability = 0.5, price = 5}, [3] = {probability = 0.5, price = 5}} },
		{ name = "dictionary keys", value = {drop = {probability = 1, price = 5}} },
		{ name = "outside tolerance", value = {{probability = 1 + 2e-6, price = 5}} },
	}
	for _, fixture in ipairs(invalid) do
		t.test(fixture.name, function() rejects(fixture.value) end)
	end
	-- Nil must not be lost from an array of fixtures.
	t.test("nil drops", function() rejects(nil) end)
	-- Small input rounding errors are accepted without renormalizing probabilities.
	t.test("inside tolerance", function()
		assert(ResourceMath.ValidateDropTable({{probability = 1 + 0.5e-6, price = 5}}))
	end)
	-- Zero probability and zero prices are valid.
	t.test("zero price and probability", function()
		near(ResourceMath.CalculateExpectedValue({{probability=0,price=100},{probability=1,price=0}}), 0)
	end)
	-- Zero gathers costs zero.
	t.test("zero gathers", function() near(ResourceMath.CalculateRouteValue(8, 0), 0) end)
	-- Invalid route inputs cannot produce plausible numeric answers.
	for _, value in ipairs({-1, 0.5, math.huge, 0/0, "9"}) do
		t.test("invalid count " .. tostring(value), function()
			assert(not pcall(ResourceMath.CalculateRouteValue, 8, value))
		end)
	end
	-- Invalid expected values must fail even with a valid count.
	for _, value in ipairs({-1, math.huge, 0/0, "8"}) do
		t.test("invalid expectation " .. tostring(value), function()
			assert(not pcall(ResourceMath.CalculateRouteValue, value, 9))
		end)
	end
	-- Finite operands can still overflow.
	t.test("route overflow", function() assert(not pcall(ResourceMath.CalculateRouteValue, 1e308, 10)) end)
end
