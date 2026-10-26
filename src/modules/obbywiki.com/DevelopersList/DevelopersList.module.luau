local DevelopersList = {}

local function construct_card(container, data)
    local card = container:tag('div')
        :addClass('ow developer-card')

    local inner = card:tag('div')
        inner:addClass('developer-card-root')

    local top = inner:tag('div')
        :addClass('developer-card-top')

    local avatar = top:tag('div')
        :addClass('developer-card-avatar')

    local img = avatar:tag('div')
        :addClass('image-container')

    local user_info = top:tag('div')
        :addClass('user-info-container')

    local username = user_info:tag('div')
    :addClass('user-info-username')

    inner:tag('span')
        :addClass('ow-developer-card__link')
        :wikitext(`[[@{data[1].username}]]`)

    username:tag('div'):addClass('user-info-username-display'):wikitext(data[1].display_name)
    username:tag('div'):addClass('user-info-username-username'):wikitext(`@{data[1].username}`)
    

    img:wikitext(`[[File:{data[1].headshot or data[1].image}|64px|link=]]`)

    local txt_area = inner:tag('div')
        :addClass('developer-card-description')

    txt_area:wikitext(data[1].description)

    return card
end

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
        local username = v

        if string.find(username, '-') then
            username = string.split(username, '-')[1]
        end

        local data = mw.ext.cargo.query('Players', '_pageName=page, username, image, display_name, most_popular_obby, most_recent_obby, headshot', {
            where = "username = '" .. username .. "'",
            limit = 1
        })

        if data and data[1] then
            construct_card(container, data)
        else
            construct_card(container, {{username = username, display_name = username, image = 'Standard11placeholder.webp', description = string.find(v, '-') and string.split(v, '-')[2] or ''}})
        end
    end

    return frame:extensionTag('templatestyles', '', { src = 'Template:DevelopersList/styles.css' }) .. tostring(container)
end

return DevelopersList