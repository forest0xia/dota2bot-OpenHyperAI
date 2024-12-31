--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
function ____exports.sub(a, b)
    return a - b
end
function ____exports.add(a, b)
    return a + b
end
function ____exports.multiply(a, b)
    return a * b
end
function ____exports.dot(a, b)
    return a.x * b.x + a.y * b.y + a.z * b.z
end
function ____exports.length2D(a)
    return math.sqrt(a.x * a.x + a.y * a.y)
end
function ____exports.length3D(vec)
    return math.sqrt(vec.x * vec.x + vec.y * vec.y + vec.z * vec.z)
end
return ____exports
