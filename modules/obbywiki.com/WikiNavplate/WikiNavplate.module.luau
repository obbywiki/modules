const p = {}

const navplate = require( 'Module:Navplate' )

const cargo = mw.ext.cargo

local function render()
    const results = cargo.query(
        'Wikis',
        '_pageName, name, domain_no_protocol, platform, pages',
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
        local label2 = row.pages <= 50 and 'sub50' or 'post50'

        -- if not table.find( platforms, label ) then
        --     table.insert( platforms, label )
        -- end

        if not grouping[label] then
            grouping[label] = {}
            table.insert( platforms, label )
        end

        if not grouping[label][label2] then
            grouping[label][label2] = {}
        end

        local link = '[[' .. row._pageName .. '|' .. row.name .. ']]'
        table.insert( grouping[label][label2], link )
    end

    local items = {}
    for _, label in ipairs( platforms ) do
        table.insert( items, { header = (label == 'fandom' and '[[File:WIKI_PLATFORMS_FANDOM.svg|12px|link=]][[:Category:Wiki/Fandom|&nbsp;Fandom]] <div class="template-navplate__subtitle>Wiki farm</div>' or label == 'miraheze' and '[[File:WIKI_PLATFORMS_MIRAHEZE.svg|14px|link=]][[:Category:Wiki/Miraheze|&nbsp;Miraheze]] <div class="template-navplate__subtitle>Non-profit Wiki farm</div>' or 'Independent/Other') } )

        for _, label2 in pairs(grouping[label]) do
            table.insert( items, {
                label = label2 == 'sub50' and '<50 pages' or '>50 pages',
                pages = table.concat( grouping[label2], '' )
            } )
        end
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