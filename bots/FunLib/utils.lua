-- Simple utils that should be able to be imported to any other lua files without causing any circular dependency.
-- This lua file should NOT have any dependency libs or files is possible.

local X = { }


function X.PrintTable(tbl)
	for i, v in ipairs(tbl) do
		print('idx='..i..', value='..v)
	end
end


-- Function to perform a deep copy of a table
function X.Deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[X.Deepcopy(orig_key)] = X.Deepcopy(orig_value)
        end
        setmetatable(copy, X.Deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

return X