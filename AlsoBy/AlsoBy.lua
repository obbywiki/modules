local p = {}

local navplate = require( 'Module:Navplate' )

local cargo = mw.ext.cargo

local function render( creator )
    if not creator or creator == '' then
        return ''
    end

    local results = cargo.query(
        'Obbies',
        '_pageName, name, subgenre',
        {
            where = "creator = '" .. creator:gsub( "'", "''" ) .. "'",
            orderBy = "subgenre ASC, name ASC",
            limit = 500
        }
    )

    if not results or #results == 0 then
        return ''
    end

    local grouping = {}
    local subgenres = {}

    for _, row in ipairs( results ) do
        local label = row.subgenre or 'Other'
        if not grouping[label] then
            grouping[label] = {}
            table.insert( subgenres, label )
        end
        local link = '[[' .. row._pageName .. '|' .. row.name .. ']]'
        table.insert( grouping[label], link )
    end

    local items = {}
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

function p.main( frame )
    local args = require( 'Module:Arguments' ).getArgs( frame )

    return render( args[1] )
end

return p