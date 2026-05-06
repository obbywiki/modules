local PlayerObbiesList = {}

local months_full = {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'}

local function month_by_index(month)
	return months_full[month] or 'N/A'
end

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
        where = "creator = '@" .. username .. "' AND NOT (developers HOLDS '@" .. username .. "')",
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

    table.sort(developed_data, function(a, b)
        return tonumber(a.visits) > tonumber(b.visits)
    end)

    local rendered = ''

    for _, v in ipairs(developed_data) do
        rendered ..= `\n* [[{v.name}]] ({month_by_index(tonumber(v.month))} {v.year})`
    end

    return rendered .. '\n\n' .. tostring(mw.text.jsonEncode(developed_data))
end

return PlayerObbiesList