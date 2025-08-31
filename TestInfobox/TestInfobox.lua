local TestInfobox = {}

function TestInfobox.main( frame )
    local InfoboxNeue = require( 'Module:InfoboxNeue' )

    local test = InfoboxNeue:new( {
		placeholderImage = 'ObbyWiki.png'
	} )

    local args = require( 'Module:Arguments' ).getArgs( frame )

    local characterName = args.name or 'Unnamed'
	local characterSpecies = args.species
	local characterImage = args.image
	local characterQuote = args.quote
	local homeworld = args.homeworld
	-- local homeworldPage = args.homeworld_page
	local affiliation = args.affiliation
	local height = args.height
	local mass = args.mass

    test:renderImage( characterImage )

    test:renderHeader( {
		title = characterName,
		subtitle = characterQuote
	} )

    test:renderSection( {
		title = 'Biographical Information',
		col = 2,
		content = {
			test:renderItem( 'Species', characterSpecies ),
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

    return test:renderInfobox( nil, characterName .. ' quick facts' )
end

return TestInfobox