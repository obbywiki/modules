local p = {}

function p.main(frame)
    local args = frame:getParent().args
    local template_name = args[1]
    
    if not template_name or template_name == '' then
        return '<code>{{}}</code>'
    end

    local result = '&#123;&#123;[[Template:' .. template_name .. '|' .. template_name .. ']]'
    
    local keys = {}
    for k in pairs(args) do
        if k ~= 1 then
            table.insert(keys, k)
        end
    end
    
    table.sort(keys, function(a, b)
        if type(a) == type(b) then
            return a < b
        end
        return type(a) == 'number'
    end)

    for _, k in ipairs(keys) do
        local v = args[k]
        if type(k) == 'number' then
            result = result .. '&#124;' .. v
        else
            result = result .. '&#124;' .. k .. '=' .. v
        end
    end

    result = result .. '&#125;&#125;'

    return '<code>' .. result .. '</code>'
end

return p