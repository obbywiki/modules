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

-- activity_score is 0–1
local activity_tiers = {
	{ min = 0.90, label = 'Very active', color = '#639922' },
	{ min = 0.70, label = 'Active',       color = '#5DCAA5' },
	{ min = 0.45, label = 'Moderate',     color = '#EF9F27' },
	{ min = 0.20, label = 'Low',          color = '#F0997B' },
	{ min = 0,    label = 'Dormant',      color = '#B4B2A9' },
}

local function activity_from_score(score)
	local s = tonumber(score)
	if s == nil then
		return nil
	end

	s = math.max(0, math.min(1, s))
	local pct = math.floor(s * 100 + 0.5)

	for _, tier in ipairs(activity_tiers) do
		if s >= tier.min then
			return {
				label = tier.label,
				color = tier.color,
				pct = pct,
			}
		end
	end

	return nil
end

local wiki_schema = {
	_table = 'Wikis',
	_drilldownTabs = 'Tab1(format=list;delimiter=\;;fields=creator)',

	domain_no_protocol = 'String',

	name = 'String',
	thumbnail = 'String',
	primary_language = 'String',
	
	year = 'Integer',
	month = 'Integer',
	day = 'Integer',

    platform = 'String',

    pages = 'Integer',
}

-- from ObbyGameInfobox
function WikiInfobox.declare(frame)
	local declare_args = {}

    table.insert(declare_args, '_table=' .. wiki_schema._table)

    for k, v in pairs(wiki_schema) do
        if k ~= '_table' and k ~= '_drilldownTabs' then
            table.insert(declare_args, k .. '=' .. v)
        end
    end

    return frame:callParserFunction{ name = '#cargo_declare', args = declare_args }
end

function WikiInfobox.store(frame, data)
	local store_args = { '_table=' .. wiki_schema._table }

	for k, v in pairs(data) do
        if v ~= nil and v ~= '' then
            table.insert(store_args, k .. '=' .. tostring(v))
        end
    end

	return frame:callParserFunction{ name = '#cargo_store', args = store_args }
end

function WikiInfobox.main( frame )
    local InfoboxNeue = require( 'Module:InfoboxNeue' )

    local infobox = InfoboxNeue:new( {
		placeholderImage = 'Standard11placeholder.webp'
	} )

    local args = require( 'Module:Arguments' ).getArgs( frame )

    local wiki_name : string = args.name or mw.title.getCurrentTitle().text
    local wiki_url : string = args.wiki_url or args.url or 'obby.wiki'

    local wiki_dedicated_obby_page_name = args.dedicated

    local wiki_founded_year : number = args.year or 0
    local wiki_founded_month : number = tonumber(args.month or 0) or 0
    local wiki_founded_day : number = args.day or 0

    local wiki_pages : number = args.pages or args.page_count or 0
    local wiki_total_pages : number = args.all_pages or args.total_page_count or 0
    local wiki_members : number = args.members or 0
    local wiki_active_members : number = args.active_members or 0
    local wiki_edits : number = args.edits or 0

    local wiki_files : number = args.files or 0
    local wiki_admins : number = args.admins or args.administrators or 0
    local wiki_bureaucrats : number = args.bureaucrats or 0
    local wiki_bots : number = args.bots or 0
    local wiki_moderators : number = args.moderators or 0

    local wiki_platform : 'fandom'|'miraheze'|'independent' = (args.platform and string.lower(args.platform)) or 'fandom'

    local thumb = args.image or args.thumbnail or args.thumb

    local edits_per_page = 0

    if wiki_edits and wiki_total_pages and tonumber(wiki_edits) and tonumber(wiki_total_pages) then
        edits_per_page = tonumber(wiki_edits)/tonumber(wiki_total_pages)
        edits_per_page = string.sub(edits_per_page, 1, 4)
    else
        edits_per_page = 'N/A'
    end

    local wiki_activity_score = args.activity_score or args.activity
    local activity = activity_from_score(wiki_activity_score)

    ---

    infobox:renderImage( thumb )

    infobox:renderHeader( {
		title = wiki_name,
		subtitle = 'https://' .. wiki_url
	} )

    if wiki_dedicated_obby_page_name then
        local dedicated_data = mw.ext.cargo.query('Obbies', '_pageName=name, visits, month, year, thumbnail', {
			where = `_pageName='{wiki_dedicated_obby_page_name}'`
		})

        if dedicated_data and dedicated_data[1] then
            infobox:renderSection( {
                title = 'Featured',
                col = 2,
                content = {
                    infobox:renderItem( {
                        label = wiki_name .. ' is dedicated to',
                        colspan = 2,
                        data = infobox:renderGameCard(
                            dedicated_data[1].thumbnail,
                            dedicated_data[1].name,
                            get_comma_val( tostring( dedicated_data[1].visits or 0 ) ),
                            month_by_index( tonumber( dedicated_data[1].month ) ),
                            dedicated_data[1].year
                        )
                    } ),
                }
            } )
        end
    end

    local quick_info_content = {
		infobox:renderItem( 'Primary Language', 'English'),
	}

	if activity then
		table.insert(quick_info_content, infobox:renderItem( {
			label = 'Activity',
			data = activity.label,
			colspan = 2,
			range = {
				['start'] = '0%',
				['end'] = activity.pct .. '%',
				color = activity.color,
			},
		} ))
	end

    infobox:renderSection( {
		title = 'Quick Info',
		col = 2,
		content = quick_info_content,
	} )

    infobox:renderSection( {
		title = 'Statistics',
		col = 2,
		content = {
			infobox:renderItem( 'Founded', `{wiki_founded_day and `{ordinal(tonumber(wiki_founded_day))} `}{month_by_index(wiki_founded_month)} {wiki_founded_year}`),
            infobox:renderItem( 'Pages', get_comma_val(wiki_pages)),
            infobox:renderItem( 'Members', wiki_platform=='fandom' and 'N/A (Fandom)' or get_comma_val(wiki_members)),
            infobox:renderItem( 'Active members', get_comma_val(wiki_active_members)),
            infobox:renderItem( 'Edits', get_comma_val(wiki_edits)),
            infobox:renderItem( 'Edits per page', edits_per_page),
		}
	} )

    infobox:renderSection( {
		title = 'More',
		col = 2,
		content = {
			infobox:renderItem( 'Uploaded Files', get_comma_val(wiki_files)),
            infobox:renderItem( 'Platform', wiki_platform == 'fandom' and '[[:Category:Wiki/Fandom|Fandom]]' or wiki_platform == 'miraheze' and '[[:Category:Wiki/Miraheze|Miraheze]]' or '[[:Category:Wiki/Independent|Independent]]'),
            infobox:renderItem( 'Administrators', wiki_admins),
            infobox:renderItem( 'Bureaucrats', wiki_bureaucrats),
            infobox:renderItem( 'Moderators', wiki_moderators),
            infobox:renderItem( 'Bots', wiki_bots),
		}
	} )

    infobox:renderFooter( {
        button = {
			icon = 'GoogleMaterialIcons-Globe.svg',
			icon_alt = 'Web',
			label = 'External Links',
			type = 'popup',
			content = infobox:renderSection( {
				content = {
					infobox:renderItem( {
						label = 'Pages',
						data = table.concat({infobox:renderLinkButton({
							label = 'Project',
							link = '//' .. wiki_url .. '/wiki/Project:About'
						}), infobox:renderLinkButton({
							label = 'Special:Statistics',
							link = '//' .. wiki_url .. '/wiki/Special:Statistics'
						})}, '')
					} ),
                    
					class = 'infobox__section--linkButtons',
				}
			}, true )
		}
    } )

    local rendered = infobox:renderInfobox( nil, wiki_name )

    local append_categories = {'[[Category:Wiki]]'}

    if wiki_platform == 'fandom' then
        table.insert(append_categories, '[[Category:Wiki/Fandom]]')
    elseif wiki_platform == 'miraheze' then
        table.insert(append_categories, '[[Category:Wiki/Miraheze]]')
    elseif wiki_platform == 'independent' then
        table.insert(append_categories, '[[Category:Wiki/Independent]]')
    end

    WikiInfobox.store(frame, {
        name = wiki_name,
        thumbnail = thumb,
		year = tonumber(args.year),
		month = tonumber(args.month),
        day = tonumber(args.day),

        platform = wiki_platform,

		domain_no_protocol = string.gsub(wiki_url, '%a://', ''),
        primary_language = 'English',
        pages = wiki_pages
	})

    return rendered .. '\n' .. table.concat(append_categories, '\n')
end


return WikiInfobox