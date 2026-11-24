--!strict
-- Pure arithmetic only. No currency, inventory, persistence or network writes.
local ResourceMath = {}
local EPSILON = 0.000001

local function finite(value: any): boolean
	return type(value) == "number" and value == value and math.abs(value) < math.huge
end

-- Contract: a nonempty dense array of {probability: number, price: number}.
-- Invalid input returns false and a diagnostic; calculations raise on invalid input.
function ResourceMath.ValidateDropTable(drops: any): (boolean, string?)
	if type(drops) ~= "table" then
		return false, "drops must be an array"
	end
	local count, maximum, total = 0, 0, 0
	for key, row in pairs(drops) do
		if type(key) ~= "number" or not finite(key) or key < 1 or key % 1 ~= 0 then
			return false, "drops must have positive integer array keys"
		end
		count += 1
		maximum = math.max(maximum, key)
		if type(row) ~= "table" then
			return false, "each drop must be a record"
		end
		local record = row :: {[string]: any}
		local probability, price = record.probability, record.price
		if type(probability) ~= "number" or not finite(probability) or probability < 0 then
			return false, "probability must be finite and nonnegative"
		end
		if type(price) ~= "number" or not finite(price) or price < 0 then
			return false, "price must be finite and nonnegative"
		end
		total += probability
	end
	if count == 0 then
		return false, "drops must not be empty"
	end
	if maximum ~= count then
		return false, "drops must not contain holes"
	end
	if not finite(total) or math.abs(total - 1) > EPSILON then
		return false, "probabilities must sum to 1 within 0.000001"
	end
	return true, nil
end

function ResourceMath.CalculateExpectedValue(drops: any): number
	local valid, reason = ResourceMath.ValidateDropTable(drops)
	assert(valid, reason)
	local total = 0
	for _, row in ipairs(drops) do
		total += row.probability * row.price
	end
	assert(finite(total), "expected value overflow")
	return total
end

function ResourceMath.CalculateRouteValue(expectedValue: any, count: any): number
	assert(finite(expectedValue) and expectedValue >= 0, "expectedValue must be finite and nonnegative")
	assert(finite(count) and count >= 0 and count % 1 == 0, "count must be a finite nonnegative integer")
	local result = expectedValue * count
	assert(finite(result), "route value overflow")
	return result
end

return ResourceMath
