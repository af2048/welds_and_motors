--!strict

local utils = {}

utils.get_instances_of_type = function(instances: { Instance }, class_name: string): { Instance }
	local result = {}

	for _, instance in instances do
		if not instance:IsA(class_name) then continue end
		table.insert(result, instance)
	end

	return result
end

return utils
