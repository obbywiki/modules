local p = {}
local vc = require('Module:VerifiedConfig')

local function page_exists(page_title)
    local title = mw.title.new(page_title)
    return title and title.exists
end

local function is_verified_group(page_title)
    for _, groupName in ipairs(vc.verified_group_names) do
        if groupName == page_title then
            return true
        end
    end
    return false
end

function p.main(frame)
    local args = frame:getParent().args
    local page_name = args[1] or args['name'] or ''
    local group_id = args[2] or args['id'] or nil

    if page_name == '' then
        return ''
    end

    local output = ''
    local checkmark = '[[File:Roblox_Verification_Badge.svg|12px|link=|alt=Verified]]'

    if page_exists(page_name) then
        output = '[[' .. page_name .. '|' .. page_name .. ']]'
        if is_verified_group(page_name) then
            output = output .. ' ' .. checkmark
        end
    else
        output = '[https://www.roblox.com/communities/' .. (group_id or '0') .. '/' .. string.gsub(page_name, ' ', '_') .. '#!/about ' .. page_name .. ' ' .. checkmark .. ']'
    end

    return output
end

return p
