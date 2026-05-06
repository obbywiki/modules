local PlayerObbiesList = {}

function PlayerObbiesList.main( frame )
    if not mw.ext.cargo or not mw.ext.cargo.query then return '' end

    local args = require( 'Module:Arguments' ).getArgs( frame )

    local username = args.username

    if not username then return 'No username provided' end

    if string.sub(username, 1, 1) == '@' then
        username = string.sub(username, 2)
    end

    local developers_held_data = mw.ext.cargo.query('Obbies', 'COUNT(*)=count, _pageName=name, visits, month, year, thumbnail', {
        where = "developers HOLDS '@" .. username .. "'",
        orderBy = "visits DESC",
        limit = 30
    })

    return tostring(mw.text.jsonEncode(developers_held_data))
end

return PlayerObbiesList