local p = {}

local navplate = require( 'Module:Navplate' )

local cargo = mw.ext.cargo

local function render()
    local results = cargo.query(
        'Wikis',
        '_pageName, name, domain_no_protocol, platform',
        {
            limit = 500
        }
    )

    if not results or #results == 0 then
        return '[[List_of_all_known_obby-related_wikis]]'
    end

    local grouping = {}
    local platforms = {}

    for _, row in ipairs( results ) do
        local label = row.platform or 'Other'
        if not grouping[label] then
            grouping[label] = {}
            table.insert( platforms, label )
        end
        local link = '[[' .. row._pageName .. '|' .. row.name .. ']]'
        table.insert( grouping[label], link )
    end

    local items = {}
    for _, label in ipairs( platforms ) do
        table.insert( items, {
            label = label,
            pages = table.concat( grouping[label], '' )
        } )
    end

    return navplate.fromData( { 
        title = '[[List of all known obby-related wikis|Other Wikis]]',
        subtitle = "Obby-related wikis by platform/host",
        id = 1,
        items = items
     } )

    -- return navplate.fromData( { 
    --     title = '[[List of all known obby-related wikis|Other Wikis]]',
    --     subtitle = "Obby-related wikis by year",
    --     id = 1,
    --     items = {
    --         {
    --             label = '2019',
    --             pages = '[[Eternal Towers of Hell Wiki]]'
    --         },
    --         {
    --             label = '2022',
    --             pages = "[[Roblox Difficulty Chart Obby Wiki]][[Aek's Hellscape Steeples Wiki]]"
    --         },
    --         {
    --             label = '2025',
    --             pages = "[[Obby Wiki]]"
    --         }
    --     }
    --  } )
end

function p.main()
    return render()
end

return p