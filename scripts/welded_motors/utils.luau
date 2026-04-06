--!strict

local utils = {}

utils.get_base_parts = function(instances: { Instance }): { Instance }
	local result = {}

	for _, instance in instances do
		if not instance:IsA("BasePart") then continue end
		table.insert(result, instance)
	end

	return result
end

return utils
