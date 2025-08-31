-- inspired by scw

local ObbyGameInfobox = {}

function ObbyGameInfobox.main( frame )
    local InfoboxNeue = require( 'Module:InfoboxNeue' )

    local test = InfoboxNeue:new( {
		placeholderImage = 'Standard169placeholder.webp'
	} )

    local args = require( 'Module:Arguments' ).getArgs( frame )

    local obby_name = args.name or '{{PAGENAME}}'
    local obby_starter_place_id = args.root_place_id or args.start_place_id or 1818

	local obby_developer = args.developer or args.creator or 'Unknown'
    local obby_publisher = args.publisher or 'Self-published'
    local obby_creation_year = args.year or ''

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
		title = 'Physical Description',
		col = 2,
		content = {
			test:renderItem( 'Height', 'idk' ),
			test:renderItem( 'Mass', 'idk' )
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