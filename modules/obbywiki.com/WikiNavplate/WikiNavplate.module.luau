const p = {}

const navplate = require( 'Module:Navplate' )

const cargo = mw.ext.cargo

local function render()
    const results = cargo.query(
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
        const label = row.platform or 'Other'

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
            label = (label == 'fandom' and '[[File:WIKI_PLATFORMS_FANDOM.svg|36px|link=]][[:Category:Wiki/Fandom|Fandom<div class="template-navplate__subtitle>Wiki farm</div>]]' or label == 'miraheze' and '[[File:WIKI_PLATFORMS_MIRAHEZE.svg|36px|link=]][[:Category:Wiki/Miraheze|Miraheze<div class="template-navplate__subtitle>Non-profit Wiki farm</div>]]' or 'Independent/Other'),
            pages = table.concat( grouping[label], '' )
        } )
    end

    return navplate.fromData( { 
        title = '[[List of all known obby-related wikis|Other Wikis]]',
        subtitle = "Obby-related wikis by host",
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