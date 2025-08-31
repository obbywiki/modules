-- inspired by scw

local ObbyGameInfobox = {}

local function month_by_index(month)
	if month == 1 then
		return 'January'
	elseif month == 2 then
		return 'Feburary'
	elseif month == 3 then
		return 'March'
	elseif month == 4 then
		return 'April'
	elseif month == 5 then
		return 'May'
	elseif month == 6 then
		return 'June'
	elseif month == 7 then
		return 'July'
	elseif month == 8 then
		return 'August'
	elseif month == 9 then
		return 'September'
	elseif month == 10 then
		return 'October'
	elseif month == 11 then
		return 'November'
	elseif month == 12 then
		return 'December'
	else
		return 'N/A'
	end
end

function ObbyGameInfobox.main( frame )
    local InfoboxNeue = require( 'Module:InfoboxNeue' )

    local test = InfoboxNeue:new( {
		placeholderImage = 'Standard169placeholder.webp'
	} )

    local args = require( 'Module:Arguments' ).getArgs( frame )

    local obby_name = args.name or '{{PAGENAME}}'
    local obby_starter_place_id = args.root_place_id or args.start_place_id or 1818
	local obby_subgenre = args.subgenre or args.sub_genre or 'N/A'
	local obby_maturity = args.maturity or args.rating or 'na'

	obby_maturity = string.lower(obby_maturity)

	if obby_maturity == 'minimal' then
		obby_maturity = 'Minimal - Ages 5+'
	elseif obby_maturity == 'mild' then
		obby_maturity = 'Mild - Ages 9+'
	elseif obby_maturity == 'mature' then
		obby_maturity = 'Mature - Ages 13+'
	elseif obby_maturity == 'restricted' then
		obby_maturity = 'Restricted - Ages 18+'
	elseif obby_maturity == 'unrated' or obby_maturity == 'na' then
		obby_maturity = 'Unrated - Ages 18+'
	else
		obby_maturity = 'N/A - Unknown'
	end


	local obby_developer = args.developer or args.creator or 'Unknown'
    local obby_publisher = args.publisher or 'Self-Published'
    local obby_creation_year = args.year or ''
	local obby_creation_month = month_by_index(tonumber(args.month or '0') or 0)

	local obby_stats_visits = args.visits or 'N/A'
	local obby_stats_peak_ccu = args.peak_ccu or 'N/A'
	local obby_stats_likes = args.likes or 'N/A'

    local obby_levels = args.levels or args.stages or 'N/A'



	local characterSpecies = args.species
	local characterImage = args.image
	local homeworld = args.homeworld
	-- local homeworldPage = args.homeworld_page
	local affiliation = args.affiliation
	local height = args.height
	local mass = args.mass

    test:renderImage( characterImage )

    test:renderHeader( {
		title = obby_name,
		subtitle = 'by \'\'\'[[' .. obby_developer .. ']]\'\'\'' .. (obby_creation_year ~= '' and (' - ' .. obby_creation_year) or '')
	} )

    test:renderItem( 'Publisher', affiliation )

    test:renderSection( {
		title = 'Gameplay',
		col = 2,
		content = {
			test:renderItem( 'Levels', obby_levels ),
			test:renderItem( {
				label = 'Homeworld',
				data = homeworld,
                link = 'https://ext.wou.gg/'
			} ),
			test:renderItem( 'Affiliation', affiliation )
		}
	} )

	test:renderSection( {
		title = 'Statistics',
		col = 2,
		content = {
			test:renderItem( 'Visits', obby_stats_visits),
			test:renderItem( 'Peak CCU', obby_stats_peak_ccu ),
			test:renderItem( 'Likes', obby_stats_likes ),
		}
	} )

    test:renderSection( {
		title = 'Publishing',
		col = 2,
		content = {
			test:renderItem( 'Released', obby_creation_month .. ' ' .. obby_creation_year ),
			test:renderItem( 'Publisher', obby_publisher ),
			test:renderItem( 'Genre', 'Obby & Platformer' ),
			test:renderItem( 'Sub-genre', obby_subgenre ),
			test:renderItem( 'Maturity', '' ),
		}
	} )

    test:renderFooter( {
		button = {
			icon = 'GoogleMaterialIcons-Globe.svg',
			label = 'External Links',
			type = 'popup',
			content = test:renderSection( {
				content = {
					test:renderItem( {
						label = 'Fandom Wiki',
						data = test:renderLinkButton( {
							label = 'View on Fandom',
							link = {'https://ext.wou.gg/'}
						} )
					} )
				}
			}, true )
		}
	} )

    return test:renderInfobox( nil, '[https://roblox.com/games/' .. obby_starter_place_id .. '/ '  .. obby_name .. ']' )
end

return ObbyGameInfobox