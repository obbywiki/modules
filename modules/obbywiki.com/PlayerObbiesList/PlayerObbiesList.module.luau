local PlayerObbiesList = {}

function PlayerObbiesList.main( frame )
    if not mw.ext.cargo or not mw.ext.cargo.query then return "An unexpected error occurred and this user's obbies and contributions could not be loaded at this time. Please check back later." end

    local args = require( 'Module:Arguments' ).getArgs( frame )

    local username = args.username

    if not username then return 'No username provided' end

    if string.sub(username, 1, 1) == '@' then
        username = string.sub(username, 2)
    end

    local developers_held_data = mw.ext.cargo.query('Obbies', '_pageName=name, visits, month, year, thumbnail', {
        where = "developers HOLDS '@" .. username .. "'",
        orderBy = "visits DESC",
        limit = 30
    })

    local creator_is_data = mw.ext.cargo.query('Obbies', '_pageName=name, visits, month, year, thumbnail', {
        where = "developers HOLDS '@" .. username .. "' AND NOT (developers HOLDS '@" .. username, 2 .. "')",
        orderBy = "visits DESC",
        limit = 30
    })

    local developed_data = {}

    for _, v in ipairs(developers_held_data) do
        table.insert(developed_data, v)
    end

    for _, v in ipairs(creator_is_data) do
        table.insert(developed_data, v)
    end

    return tostring(mw.text.jsonEncode(developed_data))
end

return PlayerObbiesList