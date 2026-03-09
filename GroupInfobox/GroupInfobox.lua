-- inspired by scw

local GroupInfobox = {}

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

local studio_schema = {
	["_table"] = "Studios",

	name = "String",
	owner = "String",
	total_obbies = "Integer",

	year = "Integer",
	month = "Integer",
	
	group_id = "String",

}

function GroupInfobox.declare(frame)
	return cargo.declare( studio_schema )
end

function GroupInfobox.store(frame, data)
	local store_args = { '_table=' .. studio_schema._table }

	for k, v in pairs(data) do
        if v ~= nil and v ~= '' then
            table.insert(store_args, k .. '=' .. tostring(v))
        end
    end

	return frame:callParserFunction{ name = '#cargo_store', args = store_args }
end


function GroupInfobox.main( frame )
    local InfoboxNeue = require( 'Module:InfoboxNeue' )

    local test = InfoboxNeue:new( {
		placeholderImage = 'Standard11placeholder.webp'
	} )

    local args = require( 'Module:Arguments' ).getArgs( frame )

    local group_name = args.name or mw.title.getCurrentTitle().text
    local group_id = args.group_id or args.id or 7
	-- local obby_join_sharelink_id = args.play or args.sharelink or args.play_sharelink or ''
	-- local obby_subgenre = args.subgenre or args.sub_genre or args.type or 'N/A'
	-- local obby_maturity = args.maturity or args.rating or 'na'
	-- local obby_update_freq = args.update_freq or args.update_frequency or 'Unknown'

	-- local obby_subgenre_lower = string.lower(obby_subgenre)

	-- if obby_subgenre_lower == 'dco' then
	-- 	obby_subgenre = 'Difficulty Chart Obby'
	-- elseif obby_subgenre_lower == 'difficulty_chart_obby' then
	-- 	obby_subgenre = 'Difficulty Chart Obby'
	-- elseif obby_subgenre_lower == 'st' then
	-- 	obby_subgenre = 'Stage Tower Obby'
	-- elseif obby_subgenre_lower == 'stage_tower_obby' then
	-- 	obby_subgenre = 'Stage Tower Obby'
	-- elseif obby_subgenre_lower == 't' then
	-- 	obby_subgenre = 'Tower Obby'
	-- elseif obby_subgenre_lower == 'tower_obby' then
	-- 	obby_subgenre = 'Tower Obby'
	-- elseif obby_subgenre_lower == 'so' then
	-- 	obby_subgenre = 'Story Obby'
	-- elseif obby_subgenre_lower == 'story_obby' then
	-- 	obby_subgenre = 'Story Obby'
	-- end


	-- obby_maturity = string.lower(obby_maturity)

	-- if obby_maturity == 'minimal' then
	-- 	obby_maturity = 'Minimal - Ages 5+'
	-- elseif obby_maturity == 'mild' then
	-- 	obby_maturity = 'Mild - Ages 9+'
	-- elseif obby_maturity == 'mature' then
	-- 	obby_maturity = 'Mature - Ages 13+'
	-- elseif obby_maturity == 'restricted' then
	-- 	obby_maturity = 'Restricted - Ages 18+'
	-- elseif obby_maturity == 'unrated' or obby_maturity == 'none' then
	-- 	obby_maturity = 'Unrated - Ages 18+'
	-- else
	-- 	obby_maturity = 'N/A - Unknown'
	-- end


	local group_creator, group_creator_was_corrected = args.developer or args.creator or args.owner or 'Unknown', false
    local group_relations = args.relations or 'Independent'
	local group_obbies = args.obbies or args.games or 0

	local group_creator_raw = group_creator

    local group_creation_year = args.year or ''
	local group_creation_month = month_by_index(tonumber(args.month or '0') or 0)

	local group_stats_members = args.members or 'N/A'
	-- local obby_stats_peak_ccu = args.peak_ccu or 'N/A'
	-- local obby_stats_likes = args.likes or 'N/A'

	if tonumber(group_stats_members) ~= nil then
		group_stats_members = get_comma_val(group_stats_members)
	end

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

	local group_name_raw

	if group_id then
		local group_res = mw.ext.externalData.getExternalData{
			url = 'https://groups.roblox.com/v1/groups/'.. tostring(group_id),
			format = 'json'
		}
		
		local group_json = group_res and group_res.__json
		local row = group_json
		mw.log(group_res, row)

		if row and row.owner then
			local c = row.owner
			local base = not c.type and 'users' or (c.type == 'Group') and 'communities' or 'users'

			group_creator = c.username and '@' .. c.username or c.name or 'Unknown'

			group_creator_raw = group_creator

			-- predicting potential api changes that allow groups to own groups, currently `username` is a user-only field
			
			if page_exists(base == 'communities' and (c.name or c.groupName) or '@' .. (c.username or c.name or 'Unknown')) then
				group_creator = group_creator .. (c.hasVerifiedBadge and ' [[File:Roblox_Verification_Badge.svg|12px|alt=Verified|link=]]' or '')
			else
				group_creator = string.format(
					'[https://roblox.com/%s/%s/%s %s%s]',
					base, base == 'users' and c.userId or c.id or c.groupId, base == 'communities' and (string.gsub(c.name or c.groupName or c.username or 'Error', ' ', '_') .. '#!/about') or 'profile', (c.username and '@' or '') .. (c.username or c.name),
					(c.hasVerifiedBadge and '  [[File:Roblox_Verification_Badge.svg|12px|alt=Verified|link=]]') or ''
				)
	
				group_creator_was_corrected = true
			end
		end

		if row and row.name then
			group_name = row.name
			group_name_raw = row.name

			group_name = string.format(
				'[https://roblox.com/groups/%s/%s#!/about %s%s]',
				group_id,
				string.gsub(group_name, ' ', '_'),
				group_name,
				(row.hasVerifiedBadge and '  [[File:Roblox_Verification_Badge.svg|12px|alt=Verified|link=]]') or ''
			)
		end

		if row then
			group_stats_members = row.memberCount or group_stats_members
			if row.memberCount and tonumber(group_stats_members) ~= nil then group_stats_members = get_comma_val(group_stats_members) end
		end
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
		title = group_name,
		subtitle = (group_creator_was_corrected and ('by \'\'\''..group_creator..'\'\'\'') or ('by \'\'\'[[' .. group_creator .. ']]\'\'\'')) .. (group_creation_year ~= '' and (' — ' .. group_creation_year) or '')
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
			test:renderItem( 'Members', group_stats_members .. '+'),
			test:renderItem( 'Obbies', '~' .. group_obbies),
			-- test:renderItem( 'Peak CCU', obby_stats_peak_ccu .. '+' ),
			-- test:renderItem( 'Likes', obby_stats_likes .. '+' ),
		}
	} )

    test:renderSection( {
		title = 'Publishing & Other',
		col = 2,
		content = {
			test:renderItem( 'Created', group_creation_month .. ' ' .. group_creation_year ),
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
			test:renderItem( 'Group ID', '<code>' .. (group_id == 7 and 'Unlisted' or tostring(group_id) or 'Unknown') .. '</code>' ),
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

	local rendered = test:renderInfobox( nil, group_name )
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

	table.insert(append_categories, '[[Category:' .. 'Group' .. ']]')
	table.insert(append_categories, '[[Category:' .. 'Studio' .. ']]')

	GroupInfobox.store(frame, {
		name = group_name_raw,
		owner = group_creator_raw,
		total_obbies = tonumber(group_obbies),
		year = tonumber(args.year),
		month = tonumber(args.month),
		group_id = tostring(group_id),
	})

    return rendered .. '\n' .. table.concat(append_categories, '\n')
end

return GroupInfobox
