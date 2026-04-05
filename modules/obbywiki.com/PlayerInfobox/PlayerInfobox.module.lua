-- inspired by scw
-- uses InfoboxNeue
-- 3

-- infobox should cover all use cases like developers, community, content creators, etc.

local PlayerInfobox = {}

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

local function page_exists(page_title)
    local title = mw.title.new(page_title)
    return title and title.exists
end


local smm = {
	twitter = {
		icon = 'External Twitter Coloured Small.webp',
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
		url = 'https://youtube.com/@',
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
	website = {
		icon = 'GoogleMaterialIcons-Globe.svg',
		url = 'https://',
		display = 'Website',
	},
	wiki = {
		icon = 'External MediaWiki White Small.png',
		url = 'https://',
		display = 'MediaWiki',
	},
}

local cargo = mw.ext.cargo

local player_schema = {
	["_table"] = "Players",

	display_name = "String",
	username = "String",
	user_id = "String",

	total_obbies = "Integer",
	total_visits = "String",

	activity = "String",

	year = "Integer",
	month = "Integer",
	day = "Integer",
}

function PlayerInfobox.declare(frame)
	return cargo.declare( player_schema )
end

function PlayerInfobox.store(frame, data)
	local store_args = { '_table=' .. player_schema._table }

	for k, v in pairs(data) do
        if v ~= nil and v ~= '' then
            table.insert(store_args, k .. '=' .. tostring(v))
        end
    end

	return frame:callParserFunction{ name = '#cargo_store', args = store_args }
end


function PlayerInfobox.main( frame )
    local InfoboxNeue = require( 'Module:InfoboxNeue' )

    local test = InfoboxNeue:new( {
		placeholderImage = 'Standard11placeholder.webp'
	} )

    local args = require( 'Module:Arguments' ).getArgs( frame )

    local player_user_name = mw.title.getCurrentTitle().text
	local player_display_name
    local player_user_id = args.user_id or args.id or 1

	local player_total_obbies = args.obbies or args.games or 0
	
    local player_creation_year, player_creation_month, player_creation_day
	local player_is_verified = false
	
	local player_current_ccu = 0 -- track users total ccu across all obbies on obby wiki TODO
	local player_total_visits = args.visits or args.total_visits or 0
	-- local obby_stats_peak_ccu = args.peak_ccu or 'N/A'
	-- local obby_stats_likes = args.likes or 'N/A'

	-- if tonumber(obby_stats_peak_ccu) ~= nil then
	-- 	obby_stats_peak_ccu = get_comma_val(args.peak_ccu)
	-- end

	-- if tonumber(obby_stats_likes) ~= nil then
	-- 	obby_stats_likes = get_comma_val(args.likes)
	-- end

    -- local obby_levels = args.levels or args.stages or 'N/A'
	-- local obby_levels_total = args.levels_total or args.stages_total or 'N/A'
	-- local obby_difficulties = args.difficulties or ''
	-- local obby_difficulties_total = args.difficulties_total or nil
	-- local obby_towers = args.towers or ''
	-- local obby_towers_total = args.towers_total or nil

	-- local obby_avatar_type = args.avatar_type or args.rig_type or 'N/A'

	-- obby_avatar_type = string.lower(obby_avatar_type)

	-- if obby_avatar_type == 'r6' then
	-- 	obby_avatar_type = 'R6'
	-- elseif obby_avatar_type == 'r15' then
	-- 	obby_avatar_type = 'R15'
	-- elseif obby_avatar_type == 'rthro' then
	-- 	obby_avatar_type = 'Rthro'
	-- elseif obby_maturity == 'choice' then
	-- 	obby_avatar_type = 'Player Choice'
	-- else
	-- 	obby_avatar_type = 'N/A - Unknown'
	-- end

	-- local obby_tier = args.tier or '0'
	
	local thumb = args.image or args.thumbnail or args.thumb

	--

	-- local universe_id

	-- local _, res = pcall(function() 
	-- 	return mw.ext.externalData.getExternalData{
	-- 		url = 'https://apis.roblox.com/universes/v1/places/' .. obby_starter_place_id .. '/universe',
	-- 		format = 'json'
	-- 	};
	--  end)

	-- universe_id = res and res.__json and res.__json.universeId


	---

	local player_user_name_raw

	if player_user_id then
		local user_res = mw.ext.externalData.getExternalData{
			url = 'https://users.roblox.com/v1/users/'.. tostring(player_user_id),
			format = 'json'
		}
		
		local user_json = user_res and user_res.__json
		local row = user_json
		mw.log(user_json, row)

		if row and row.name then
			player_user_name_raw = '@' .. row.name
			player_display_name = row.displayName or row.name
			player_is_verified = row.hasVerifiedBadge or false

			player_user_name = string.format(
				'[https://roblox.com/users/%s/profile %s%s]',
				player_user_id,
				player_user_name_raw,
				(row.hasVerifiedBadge and '  [[File:Roblox_Verification_Badge.svg|12px|alt=Verified|link=]]') or ''
			)

			player_display_name = string.format(
				'[https://roblox.com/users/%s/profile %s%s]',
				player_user_id,
				player_display_name,
				(row.hasVerifiedBadge and '  [[File:Roblox_Verification_Badge.svg|12px|alt=Verified|link=]]') or ''
			)
		end

		if row and row.created then
			-- e.g., 2018-06-25T07:34:11.183Z

			local year, month, day = row.created:match('^([%d]+)-([%d]+)-([%d]+)T')
			player_creation_year = year
			player_creation_month = month_by_index(tonumber(month))
			player_creation_day = day
		end

		-- if row then
		-- 	group_stats_members = row.memberCount or group_stats_members
		-- 	if row.memberCount and tonumber(group_stats_members) ~= nil then group_stats_members = get_comma_val(group_stats_members) end
		-- end
	end

	-- local s2, universe_data = pcall(function()
	-- 	return mw.ext.externalData.getExternalData{
	-- 		data = {
	-- 			creator_name = 'json.data[0].creator.name',
	-- 			creator_id   = 'json.data[0].creator.id',
	-- 			is_verified  = 'json.data[0].creator.hasVerifiedBadge'
	-- 		},
	-- 		url = 'https://games.roblox.com/v1/games?universeIds=' .. universe_id,
	-- 		format = 'json',
	-- 	}
	-- end)

	-- if s2 and universe_data then
	-- 	if universe_data.creator_name then
	-- 		obby_developer = universe_data.creator.name or obby_developer

	-- 		if universe_data.is_verified == 'true' or universe_data.is_verified == true then obby_developer = obby_developer .. ' [[File:Roblox_Verification_Badge.svg|12px|link=|alt=Verified]]' end
	-- 	end
	-- end

	-- local universe

	-- if universe_id then
	-- 	local universe_data = mw.ext.externalData.getExternalData{
	-- 		url = 'https://games.roblox.com/v1/games?universeIds=' .. universe_id
	-- 	}
	
	-- 	universe = universe_data and universe_data[1]
	
	-- 	if universe then
	-- 		obby_developer = universe.creator and universe.creator.name or obby_developer
	-- 	end
	-- end

	---





	--

    test:renderImage( thumb )

    test:renderHeader( {
		title = player_display_name,
		subtitle = player_user_name_raw
	} )

    -- test:renderSection( {
	-- 	title = 'Overview',
	-- 	col = 2,
	-- 	content = {
	-- 		test:renderItem( '', obby_levels_total and obby_levels and (obby_levels .. (obby_levels_total and ' <small>(of ' .. obby_levels_total .. ')</small>')) or obby_levels or ''),
	-- 		-- test:renderItem( 'Difficulties', obby_difficulties_total and obby_difficulties and (obby_difficulties .. (obby_difficulties_total and ' <small>(of ' .. obby_difficulties_total .. ')</small>')) or obby_difficulties or ''),
	-- 		-- test:renderItem( 'Towers', obby_towers_total and obby_towers and (obby_towers .. (obby_towers_total and ' <small>(of ' .. obby_towers_total .. ')</small>')) or obby_towers and obby_towers or ''),
	-- 		-- test:renderItem( 'Tier', '[[Tiers|'.. (obby_tier == '0' and '0 - Unrated/Unknown' or obby_tier).. ']]' ),
	-- 		-- test:renderItem( 'Avatar Type', obby_avatar_type )
	-- 	}
	-- } )

	test:renderSection( {
		title = 'Statistics',
		col = 2,
		content = {
			test:renderItem( 'Total Visits', player_total_visits .. '+'),
			test:renderItem( 'Obbies', '~' .. player_total_obbies),
			-- test:renderItem( 'Peak CCU', obby_stats_peak_ccu .. '+' ),
			-- test:renderItem( 'Likes', obby_stats_likes .. '+' ),
		}
	} )

    test:renderSection( {
		title = 'Other',
		col = 2,
		content = {
			test:renderItem( 'Joined', player_creation_month .. ' ' .. player_creation_year ),
			-- test:renderItem( 'Update Frequency', obby_update_freq ),
			-- test:renderItem( 'Publisher', obby_publisher ),
			-- test:renderItem( 'Genre', 'Obby & Platformer' ),
			-- test:renderItem( 'Sub-genre', obby_subgenre ),
			-- test:renderItem( 'Maturity', obby_maturity ),
			-- test:renderItem( 'Obby System', obby_system ),
		}
	} )

	local social_icons_wikitext = {}
	-- local platform_icons_wikitext = {}

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

	-- for _, i in pairs({'pc','tablet','phone','console','vr'}) do
	-- 	if args[i] then
	-- 		local wikitext = string.format(
	-- 			'[[File:%s|24px|alt=%s|class=platform-icon|link=]]',
	-- 			(
	-- 				i == 'pc' and
	-- 					'Platform Computer White Small.png'
	-- 				or i == 'tablet' and
	-- 					'Platform Tablet White Small.png'
	-- 				or i == 'phone' and
	-- 					'Platform Phone White Small.png'
	-- 				or i == 'console' and
	-- 					'Platform Console White Small.png'
	-- 				or i == 'vr' and
	-- 					'Platform VR White Small.png'
	-- 				or ''
	-- 			),
	-- 			i
	-- 		)

	-- 		table.insert(platform_icons_wikitext, wikitext)
	-- 	end
	-- end

	if #social_icons_wikitext > 0 then
		test:renderSection(
			{
				title = 'Presence',
				content = {
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

	test:renderSection( {
		title = 'Advanced',
		col = 2,
		content = {
			test:renderItem( 'User ID', '<code>' .. (player_user_id == 1 and 'Unlisted' or tostring(player_user_id) or 'Unknown') .. '</code>' ),
			-- test:renderItem( 'Universe ID', tostring(universe_id) or 'Unknown' ),
		}
	} )

    -- test:renderFooter( {
	-- 	button = {
	-- 		icon = 'GoogleMaterialIcons-Globe.svg',
	-- 		label = 'External Links',
	-- 		type = 'popup',
	-- 		content = test:renderSection( {
	-- 			content = {
	-- 				test:renderItem( {
	-- 					label = 'Roblox',
	-- 					data = {test:renderLinkButton( {
	-- 						label = 'View on Roblox',
	-- 						link = 'https://roblox.com/games/' .. obby_starter_place_id .. '/'
	-- 					}),

	-- 					test:renderLinkButton({
	-- 						label = 'Play on Roblox',
	-- 						link = (obby_join_sharelink_id ~= '' and 'https://roblox.com/join/' .. obby_join_sharelink_id) or 'https://roblox.com/start?placeId=' .. obby_starter_place_id .. '&launchData=obbywiki'
	-- 					})
	-- 				}					
	-- 				} ),

	-- 				test:renderItem( {
	-- 					label = 'Analytics (not affiliated)',
	-- 					data = {test:renderLinkButton( {
	-- 						label = 'View on RoMonitorStats',
	-- 						link = 'https://romonitorstats.com/experience/' .. obby_starter_place_id .. '/'
	-- 					}),
	-- 					test:renderLinkButton( {
	-- 						label = 'View on Rolimons',
	-- 						link = 'https://rolimons.com/game/' .. obby_starter_place_id .. '/'
	-- 					})
	-- 				}					
	-- 				} )
	-- 			}
	-- 		}, true )
	-- 	}
	-- } )

	local rendered = test:renderInfobox( nil, player_user_name )
	-- local parsed_month = month_by_index(tonumber(group_creation_year))

	local append_categories = {}

	-- if tonumber(obby_creation_year) >= 2008 and tonumber(obby_creation_year) <= os.date('*t').year+2 then
	-- 	table.insert(append_categories, '[[Category:' .. tostring(obby_creation_year) .. ']]')


	-- 	if parsed_month ~= 'N/A' then
	-- 		table.insert(append_categories, '[[Category:' .. parsed_month .. ' ' .. tostring(obby_creation_year) .. ']]')
	-- 	end
	-- end

	-- if parsed_month ~= 'N/A' then
	-- 	table.insert(append_categories, '[[Category:' .. parsed_month .. ']]')
	-- end

	table.insert(append_categories, '[[Category:' .. 'Player' .. ']]')
	-- table.insert(append_categories, '[[Category:' .. 'Studio' .. ']]')

	PlayerInfobox.store(frame, {
		username = player_user_name_raw,
		display_name = player_display_name,
		total_obbies = tonumber(player_total_obbies),
		year = tonumber(player_creation_year),
		month = tonumber(player_creation_month),
		day = tonumber(player_creation_day),
		user_id = tostring(player_user_id),
	})

    return rendered .. '\n' .. table.concat(append_categories, '\n')
end

return PlayerInfobox
