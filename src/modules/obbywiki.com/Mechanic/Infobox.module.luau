local MechanicInfobox = {}

function MechanicInfobox.main( frame : frame )
    local InfoboxNeue = require( 'Module:InfoboxNeue' )

    local infobox = InfoboxNeue:new( {
		placeholderImage = 'Standard11placeholder.webp'
	} )

    local args = require( 'Module:Arguments' ).getArgs( frame )

    local absolute_title = mw.title.getCurrentTitle()

    local mech_name = args.name or '{{PAGENAME}}'
    local mech_type : 'regular' | 'glitch' = args.type or 'regular'

    local thumb = args.image or args.thumbnail or args.thumb

    infobox:renderImage( thumb )

    infobox:renderHeader( {
		title = mech_name,
		subtitle = mech_type == 'glitch' and 'Glitch' or 'Regular'
	} )


    infobox:renderSection( {
		title = 'About',
		col = 2,
		content = {
			infobox:renderItem( 'Skill Level', 'Unknown' ),
			infobox:renderItem( 'Type', mech_type == 'glitch' and 'Glitch' or 'Regular' ),
		}
	} )

    if mech_type == 'glitch' then
        infobox:renderSection( {
            title = 'Glitch Info',
            col = 2,
            content = {
                infobox:renderItem( 'Possible', 'Unknown' ),
                infobox:renderItem( 'Discovered', 'Unknown' ),
            }
        } )
    end


    local rendered = infobox:renderInfobox( nil, mech_name )

    return rendered
end

return MechanicInfobox