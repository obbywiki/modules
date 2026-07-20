--- @class AlsoBy

local p = {}

local navplate = require( 'Module:Navplate' )

local cargo = mw.ext.cargo

--- Collects the data from Cargo and renders the Navplate as a string.
---
--- @within AlsoBy
--- @private
--- @param creator string -- The name of the creator by @Username or GroupName
---
--- @return string -- Returns the render as a string.

local function render( creator : string ) : string
    if not creator or creator == '' then
        return ''
    end

    local is_likely_user = string.sub(creator, 1, 1) == '@'

    local developed_data = {}

    local creator_is_data = cargo.query(
        'Obbies',
        '_pageName, name, subgenre',
        {
            where = "creator = '" .. creator:gsub( "'", "''" ) .. "'",
            orderBy = "subgenre ASC, name ASC",
            limit = 500
        }
    )

    for _, v in ipairs(creator_is_data) do
        table.insert(developed_data, v)
    end

    if is_likely_user then
        local developers_held_data = mw.ext.cargo.query('Obbies', '_pageName, name, subgenre', {
            where = "developers HOLDS '" .. creator .. "'",
            orderBy = "subgenre ASC, name ASC",
            limit = 500
        })

        for _, v in ipairs(developers_held_data) do
            table.insert(developed_data, v)
        end
    end

    if not developed_data or #developed_data == 0 then
        return ''
    end

    -- deduplicate
    local filtered = {}
    for _, v in pairs( developed_data ) do
        if not table.find(filtered, v._pageName) then
            table.insert(filtered, v._pageName)
        end
    end

    local grouping = {}
    local subgenres = {}

    for _, row in ipairs( filtered ) do
        local label = row.subgenre or 'Other'
        if not grouping[label] then
            grouping[label] = {}
            table.insert( subgenres, label )
        end
        local link = '[[' .. row._pageName .. '|' .. row.name .. ']]'
        table.insert( grouping[label], link )
    end

    local items = {}

    if is_likely_user then table.insert( items, { header = 'Lead roles in' } ) end

    for _, label in ipairs( subgenres ) do
        table.insert( items, {
            label = label,
            pages = table.concat( grouping[label], '' )
        } )
    end

    return navplate.fromData( { 
        title = '[[' .. creator .. ']]',
        subtitle = "Obbies also created by",
        id = 1,
        items = items
     } )
end

--- Wraps the render function
---
--- @within AlsoBy
--- @param frame frame
---
--- @return string
---
--- @tag invoked

function p.main( frame )
    local args = require( 'Module:Arguments' ).getArgs( frame )

    return render( args[1] )
end

return p