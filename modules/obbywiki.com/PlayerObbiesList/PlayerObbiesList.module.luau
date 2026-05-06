local PlayerObbiesList = {}

local months_full = {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'}

local function month_by_index(month)
	return months_full[month] or 'N/A'
end

local function get_comma_val(num)
	local formatted = num
	while true do  
		local k;

		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end

function PlayerObbiesList.main( frame )
    if not mw.ext.cargo or not mw.ext.cargo.query then return "An unexpected error occurred and this user's obbies and contributions could not be loaded at this time. Please check back later." end

    local args = require( 'Module:Arguments' ).getArgs( frame )

    local username = args.username

    if not username then return 'No username provided' end

    if string.sub(username, 1, 1) == '@' then
        username = string.sub(username, 2)
    end

    local developers_held_data = mw.ext.cargo.query('Obbies', '_pageName=name, visits, month, year, thumbnail, likes, dislikes', {
        where = "developers HOLDS '@" .. username .. "'",
        orderBy = "visits DESC",
        limit = 30
    })

    local contributors_held_data = mw.ext.cargo.query('Obbies', '_pageName=name, visits, month, year, thumbnail, likes, dislikes', {
        where = "contributors HOLDS '@" .. username .. "'",
        orderBy = "visits DESC",
        limit = 30
    })

    local creator_is_data = mw.ext.cargo.query('Obbies', '_pageName=name, visits, month, year, thumbnail, likes, dislikes', {
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

    local rendered = `@{username} has '''{#developed_data}+''' obbies they have developed themselves or been on the development team for:`

    local tbl = mw.html.create("table")
		:addClass("wikitable sortable plainlinks")
		:addClass("mw-collapsible mw-made-collapsible wikitable--fluid")
		:css("width", "100%")

    local thead = tbl:tag("tr")
	thead:tag("th"):wikitext("Thumbnail")
	thead:tag("th"):wikitext("Name")
	thead:tag("th"):wikitext("Visits")
    thead:tag("th"):wikitext("Rating")
	thead:tag("th"):wikitext("Date")

    for _, v in ipairs(developed_data) do
        -- rendered ..= `\n* [[{v.name}]] ({month_by_index(tonumber(v.month))} {v.year})`
        local row = tbl:tag("tr")
		local thumb_cell = row:tag("td")

        thumb_cell:wikitext(`[[File:{v.thumbnail}|120px]]`)

        local total_likes = tonumber(v.likes) or 0
        local total_dislikes = tonumber(v.dislikes) or 0

        row:tag("td"):wikitext(`[[{v.name}]]`)
        row:tag("td"):wikitext(`{get_comma_val(v.visits)}`)
        row:tag("td"):wikitext((total_likes + total_dislikes) > 0 and (math.floor((total_likes / (total_likes + total_dislikes)) * 1000) / 10) .. '% ( [[File:Likes.svg|12px|alt=Likes|link=]] ' .. get_comma_val(tostring(total_likes)) .. ' &nbsp; [[File:Dislikes.svg|12px|alt=Dislikes|link=]] ' .. get_comma_val(tostring(total_dislikes)) .. ')' or 'N/A')
        row:tag("td"):wikitext(`{month_by_index(tonumber(v.month))} {v.year}`)
    end

    local cont_tbl

    if #contributors_held_data > 0 then
        cont_tbl = mw.html.create("table")
            :addClass("wikitable sortable plainlinks")
            :addClass("mw-collapsible mw-made-collapsible wikitable--fluid")
            :css("width", "100%")

        local cthead = cont_tbl:tag("tr")
        cthead:tag("th"):wikitext("Thumbnail")
        cthead:tag("th"):wikitext("Name")
        cthead:tag("th"):wikitext("Visits")
        cthead:tag("th"):wikitext("Rating")
        cthead:tag("th"):wikitext("Date")

        for _, v in ipairs(contributors_held_data) do
            local row = cont_tbl:tag("tr")
            local thumb_cell = row:tag("td")

            thumb_cell:wikitext(`[[File:{v.thumbnail}|120px]]`)

            local total_likes = tonumber(v.likes) or 0
            local total_dislikes = tonumber(v.dislikes) or 0

            row:tag("td"):wikitext(`[[{v.name}]]`)
            row:tag("td"):wikitext(`{get_comma_val(v.visits)}`)
            row:tag("td"):wikitext((total_likes + total_dislikes) > 0 and (math.floor((total_likes / (total_likes + total_dislikes)) * 1000) / 10) .. '% ( [[File:Likes.svg|12px|alt=Likes|link=]] ' .. get_comma_val(tostring(total_likes)) .. ' &nbsp; [[File:Dislikes.svg|12px|alt=Dislikes|link=]] ' .. get_comma_val(tostring(total_dislikes)) .. ')' or 'N/A')
            row:tag("td"):wikitext(`{month_by_index(tonumber(v.month))} {v.year}`)
        end
    end

    rendered ..= tostring(tbl)
    
    if cont_tbl then
        rendered ..= '\n\n' .. tostring(mw.html.create('h2'):wikitext('Contributions')) .. `Below are all of @{username}'s contributed obbies. Contributions are typically considered to be one-off contract work for games they are not core developers of. Work varies by developer and game, but typically contributors are one-time level designers, map creators, or other short-term work. @{username} has contributed to '''{#contributors_held_data}+''' obbies that are documented on the Obby Wiki.` .. tostring(cont_tbl)
    end

    return rendered .. '\n\n' -- .. tostring(mw.text.jsonEncode(developed_data))
end

return PlayerObbiesList