local DevelopersList = {}

function DevelopersList.main( frame )
    if not mw.ext.cargo or not mw.ext.cargo.query then return "An unexpected error occurred. Please check back later." end

    local args = require( 'Module:Arguments' ).getArgs( frame )

    local developers = args.developers

    if not developers or type(developers) ~= 'string' then
        return 'No developers provided.'
    end

    local ds = string.split(developers, ',')
    local usernames : {string} = {}

    for _, v in pairs(ds) do
        if string.sub(v, 1, 1) == '@' then
            table.insert(usernames, string.sub(v, 2))
        else
            table.insert(usernames, v)
        end
    end

    -- return tostring(mw.text.jsonEncode(usernames))

    local container = mw.html.create('div')
        :addClass("ow developers-list")

    for _, v in pairs(usernames) do
        local data = mw.ext.cargo.query('Players', '_pageName=name, visits, month, year, thumbnail, likes, dislikes', {
            where = "contributors HOLDS '@" .. username .. "'",
            orderBy = "visits DESC",
            limit = 30
        })
    end
end

return DevelopersList