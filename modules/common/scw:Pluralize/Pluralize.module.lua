local p = {}

-- Pluralize a word based on local dictionary or rules.
-- To use this directly in Lua, use common.pluralize instead
function p.pluralize( frame )
    local base = frame.args[ 1 ]
    local return_val
    local base_len = string.len( base )
    local base_end = string.sub( base, -1 )
    local base_last2 = string.sub( base, -2 )
    -- dictionary first - irregular plurals
    if (string.lower( base ) == 'nebula') then
        return_val = string.sub( base, 1, 1 ) .. 'ebulae'
    elseif (string.lower( base ) == 'torpedo') then
        return_val = string.sub( base, 1, 1 ) .. 'orpedoes'
        -- uncountable - so no plurals
    elseif (string.sub( base, -5 ) == 'armor') then
        return_val = base
        -- rules
    elseif (base_end == 'y') then
        if (base_last2 == 'ey') then
            -- ex - money
            return_val = string.sub( base, 1, base_len - 2 ) .. 'ies'
        else
            -- ex - Secretary
            return_val = string.sub( base, 1, base_len - 1 ) .. 'ies'
        end
    elseif (base_end == 'h') then
        if (base_last2 == 'ch' or base_last2 == 'sh') then
            -- ex church or fish
            return_val = base .. 'es'
        else
            -- ex - blah
            return_val = base .. 's'
        end
    elseif (base_end == 's') then -- ex - Idris - Or should we deal with things like crisis/crises as a rule?
        return_val = base
    elseif (base_end == 'e') then
        if (base_last2 == 'fe') then
            -- ex knife or wife
            return_val = string.sub( base, 1, base_len - 2 ) .. 'ves'
        else
            -- ex - blah
            return_val = base .. 's'
        end
    else -- default rule
        return_val = base .. 's'
    end
    return return_val
end

return p
