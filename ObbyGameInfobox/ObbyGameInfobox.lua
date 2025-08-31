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



local smm = {
	twitter = {
		icon = 'External Twitter White Small.png',
		url = 'https://twitter.com/',
		display = 'Twitter',
	},
	bsky = {
		icon = 'External BlueSky White Small.png',
		url = 'https://bsky.app/profile/',
		display = 'BlueSky',
	},
	youtube = {
		icon = 'External YouTube White Small.png',
		url = 'https://youtube.com/c/',
		display = 'YouTube',
	},
	discord = {
		icon = 'External Discord White Small.png',
		url = 'https://discord.com/invite/',
		display = 'Discord',
	},
	guilded = {
		icon = 'External Guilded White Small.png',
		url = 'https://guilded.gg/',
		display = 'Guilded',
	},
	roblox = {
		icon = 'External Roblox White Small.png',
		url = 'https://roblox.com/users/profile?username=',
		display = 'Roblox',
	},
	wiki = {
		icon = 'External MediaWiki White Small.png',
		url = 'https://',
		display = 'MediaWiki',
	},
}




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
	local obby_update_freq = args.update_freq or args.update_frequency or 'Unknown'

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

	local obby_system = args.system or args.obby_system or 'Unknown'

    local obby_creation_year = args.year or ''
	local obby_creation_month = month_by_index(tonumber(args.month or '0') or 0)

	local obby_stats_visits = args.visits or 'N/A'
	local obby_stats_peak_ccu = args.peak_ccu or 'N/A'
	local obby_stats_likes = args.likes or 'N/A'

    local obby_levels = args.levels or args.stages or 'N/A'
	local obby_difficulties = args.difficulties or ''
	local obby_towers = args.towers or ''

	local obby_avatar_type = args.avatar_type or args.rig_type or 'N/A'

	obby_avatar_type = string.lower(obby_avatar_type)

	if obby_avatar_type == 'r6' then
		obby_avatar_type = 'R6'
	elseif obby_avatar_type == 'r15' then
		obby_avatar_type = 'R15'
	elseif obby_avatar_type == 'rthro' then
		obby_avatar_type = 'Rthro'
	elseif obby_maturity == 'choice' then
		obby_maturity = 'Player Choice'
	else
		obby_maturity = 'N/A - Unknown'
	end

	local obby_tier = args.tier or '0'
	
	local characterImage = args.image
	local homeworld = args.homeworld
	-- local homeworldPage = args.homeworld_page
	local affiliation = args.affiliation
	local height = args.height
	local mass = args.mass

    test:renderImage( characterImage )

    test:renderHeader( {
		title = '[https://roblox.com/games/' .. obby_starter_place_id .. '/ '  .. obby_name .. ']',
		subtitle = 'by \'\'\'[[' .. obby_developer .. ']]\'\'\'' .. (obby_creation_year ~= '' and (' - ' .. obby_creation_year) or '')
	} )

    test:renderSection( {
		title = 'Gameplay',
		col = 2,
		content = {
			test:renderItem( 'Levels', obby_levels ),
			test:renderItem( 'Difficulties', obby_difficulties ),
			test:renderItem( 'Towers', obby_towers ),
			test:renderItem( {
				label = 'Tier',
				data = obby_tier == '0' and '0 - Unrated/Unknown' or obby_tier,
                link = 'https://obbywiki.com/wiki/tiers#tier-'.. obby_tier
			} ),
			test:renderItem( 'Avatar Type', obby_avatar_type )
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
		title = 'Publishing & Other',
		col = 2,
		content = {
			test:renderItem( 'Released', obby_creation_month .. ' ' .. obby_creation_year ),
			test:renderItem( 'Update Frequency', obby_update_freq ),
			test:renderItem( 'Publisher', obby_publisher ),
			test:renderItem( 'Genre', 'Obby & Platformer' ),
			test:renderItem( 'Sub-genre', obby_subgenre ),
			test:renderItem( 'Maturity', obby_maturity ),
			test:renderItem( 'Obby System', obby_system ),
		}
	} )

	local social_icons_wikitext = {}
	local platform_icons_wikitext = {'[[File:Platform Computer White Small.png|24px|alt=PC|class=platform-icon]]'}

	for i, v in pairs(smm) do
		if args[i] then
			local handle = args[i]
			local full_url = v.url .. handle

			local wikitext = string.format(
				'[%s [[File:%s|24px|link=|alt=%s|class=social-icon %s-social-icon]]]',
				full_url,
				v.icon,
				v.display .. ' icon',
				string.lower(v.display)
			)

			table.insert(social_icons_wikitext, wikitext)
		end
	end

	for _, i in pairs({'pc','tablet','phone','console','vr'}) do
		if args[i] then
			local wikitext = string.format(
				'[[File:%s|24px|alt=%s|class=platform-icon]]',
				(
					i == 'pc' and
						'Platform Computer White Small.png'
					or i == 'tablet' and
						'Platform Tablet White Small.png'
					or i == 'phone' and
						'Platform Phone White Small.png'
					or i == 'console' and
						'Platform Console White Small.png'
					or i == 'vr' and
						'Platform VR White Small.png'
					or ''
				),
				i
			)

			table.insert(platform_icons_wikitext, wikitext)
		end
	end

	if #social_icons_wikitext > 0 or #platform_icons_wikitext > 0 then
		test:renderSection(
			{
				title = 'Presence',
				content = {
					test:renderItem(
						{
							label = 'Platforms',

							data = table.concat(platform_icons_wikitext, ' ')
						}
					),
					
					test:renderItem(
						{
							label = 'Socials',
							plainlinks_enabled = true,

							data = table.concat(social_icons_wikitext, ' ')
						}
					)
				}
			}
		)
	end

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