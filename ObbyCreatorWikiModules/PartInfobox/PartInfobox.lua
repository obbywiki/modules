-- inspired by scw

local PartInfobox = {}

-- local function get_comma_val(num)
-- 	local formatted = num
-- 	while true do  
-- 		local k;

-- 		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
-- 		if (k==0) then
-- 			break
-- 		end
-- 	end
-- 	return formatted
-- end

local function page_exists(page_title)
    local title = mw.title.new(page_title)
    return title and title.exists
end


function PartInfobox.main( frame )
    local InfoboxNeue = require( 'Module:InfoboxNeue' )

    local test = InfoboxNeue:new( {
		placeholderImage = 'Standard11placeholder.webp'
	} )

    local args = require( 'Module:Arguments' ).getArgs( frame )

    local part_name = args.name or mw.title.getCurrentTitle().text

	local part_type = args.type or 'Unknown'
    local part_cost = args.cost or args.price or 'N/A'

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
		title = part_name,
		subtitle = part_type
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
		title = 'Quick Info',
		col = 2,
		content = {
			test:renderItem( 'Part Type', page_exists(part_type .. 's') and '[[' .. part_type .. ']]' or part_type),
			test:renderItem( 'Initial Cost', '$' .. part_cost),
			-- test:renderItem( 'Peak CCU', obby_stats_peak_ccu .. '+' ),
			-- test:renderItem( 'Likes', obby_stats_likes .. '+' ),
		}
	} )

    -- test:renderSection( {
	-- 	title = 'Publishing & Other',
	-- 	col = 2,
	-- 	content = {
	-- 		test:renderItem( 'Created', group_creation_month .. ' ' .. group_creation_year ),
	-- 		-- test:renderItem( 'Update Frequency', obby_update_freq ),
	-- 		-- test:renderItem( 'Publisher', obby_publisher ),
	-- 		-- test:renderItem( 'Genre', 'Obby & Platformer' ),
	-- 		-- test:renderItem( 'Sub-genre', obby_subgenre ),
	-- 		-- test:renderItem( 'Maturity', obby_maturity ),
	-- 		-- test:renderItem( 'Obby System', obby_system ),
	-- 	}
	-- } )

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

	-- test:renderSection( {
	-- 	title = 'Advanced',
	-- 	col = 2,
	-- 	content = {
	-- 		test:renderItem( 'Group ID', '<code>' .. (group_id == 7 and 'Unlisted' or tostring(group_id) or 'Unknown') .. '</code>' ),
	-- 		-- test:renderItem( 'Universe ID', tostring(universe_id) or 'Unknown' ),
	-- 	}
	-- } )

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

	local rendered = test:renderInfobox( nil, part_name )
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

	table.insert(append_categories, '[[Category:' .. 'Part' .. ']]')

    if part_type ~= 'Unknown' then
        table.insert(append_categories, '[[Category:' .. part_type .. 's]]')
    end

    return rendered .. '\n' .. table.concat(append_categories, '\n')
end

return PartInfobox
