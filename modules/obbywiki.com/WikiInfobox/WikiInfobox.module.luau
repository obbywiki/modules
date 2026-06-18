local WikiInfobox = {}

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

function WikiInfobox.main( frame )
    local InfoboxNeue = require( 'Module:InfoboxNeue' )

    local infobox = InfoboxNeue:new( {
		placeholderImage = 'Standard11placeholder.webp'
	} )

    local args = require( 'Module:Arguments' ).getArgs( frame )

    local wiki_name : string = args.name or mw.title.getCurrentTitle().text
    local wiki_url : string = args.wiki_url or args.url or 'obby.wiki'

    local wiki_founded_year : number = args.year or 0
    local wiki_founded_month : number = args.month or 0
    local wiki_founded_day : number = args.day or 0 -- TODO

    local wiki_pages : number = args.pages or args.page_count or 0
    local wiki_members : number = args.members or 0
    local wiki_active_members : number = args.active_members or 0
    local wiki_edits : number = args.edits or 0

    local wiki_platform : 'fandom'|'miraheze'|'independent' = (args.platform and string.lower(args.platform)) or 'fandom'

    local thumb = args.image or args.thumbnail or args.thumb

    ---

    infobox:renderImage( thumb )

    infobox:renderHeader( {
		title = wiki_name,
		subtitle = 'https://' .. wiki_url
	} )

    infobox:renderSection( {
		title = 'Statistics',
		col = 2,
		content = {
			infobox:renderItem( 'Founded', month_by_index(wiki_founded_month) .. wiki_founded_year),
            infobox:renderItem( 'Pages', get_comma_val(wiki_pages)),
            infobox:renderItem( 'Members', get_comma_val(wiki_members)),
            infobox:renderItem( 'Active Members', get_comma_val(wiki_active_members)),
            infobox:renderItem( 'Pages', get_comma_val(wiki_edits)),
		}
	} )

    local rendered = infobox:renderInfobox( nil, wiki_name )

    return rendered
end


return WikiInfobox