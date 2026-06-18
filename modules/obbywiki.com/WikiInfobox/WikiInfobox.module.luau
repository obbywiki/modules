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

local function ordinal(n)
    local x = tonumber(mw.ustring.match(n, "(%d*)%W*$"))
    local suffix = "th"
    
    if x then
        local mod10 = math.abs(x) % 10
        local mod100 = math.abs(x) % 100
        
        if mod10 == 1 and mod100 ~= 11 then
            suffix = "st"
        elseif mod10 == 2 and mod100 ~= 12 then
            suffix = "nd"
        elseif mod10 == 3 and mod100 ~= 13 then
            suffix = "rd"
        end
    end
    
    return n .. suffix
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
    local wiki_founded_month : number = tonumber(args.month or 0) or 0
    local wiki_founded_day : number = args.day or 0

    local wiki_pages : number = args.pages or args.page_count or 0
    local wiki_members : number = args.members or 0
    local wiki_active_members : number = args.active_members or 0
    local wiki_edits : number = args.edits or 0

    local wiki_platform : 'fandom'|'miraheze'|'independent' = (args.platform and string.lower(args.platform)) or 'fandom'

    local thumb = args.image or args.thumbnail or args.thumb

    local edits_per_page = 0

    if wiki_edits and wiki_pages and tonumber(wiki_edits) and tonumber(wiki_pages) then
        edits_per_page = tonumber(wiki_edits)/tonumber(wiki_pages)
    end

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
			infobox:renderItem( 'Founded', `{wiki_founded_day and `{ordinal(tonumber(wiki_founded_day))} `}{month_by_index(wiki_founded_month)} {wiki_founded_year}`),
            infobox:renderItem( 'Pages', get_comma_val(wiki_pages)),
            infobox:renderItem( 'Members', wiki_platform=='fandom' and 'N/A (Fandom)' or get_comma_val(wiki_members)),
            infobox:renderItem( 'Active Members', get_comma_val(wiki_active_members)),
            infobox:renderItem( 'Edits', get_comma_val(wiki_edits)),
            infobox:renderItem( 'Edits per page', edits_per_page),
		}
	} )

    local rendered = infobox:renderInfobox( nil, wiki_name )

    return rendered
end


return WikiInfobox