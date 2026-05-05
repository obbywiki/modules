-- inspired by scw

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
	is_verified = "Boolean",
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

	local player_user_name_unformatted = player_user_name

	player_user_name_unformatted = string.gsub(player_user_name_unformatted, '@', '')
	player_user_name_unformatted = string.gsub(player_user_name_unformatted, '~', '')

	local player_roles = args.roles or args.known_for or 'player'
	-- player,developer,content-creator

	player_roles = string.lower(player_roles)

	local roles = {}

	for _, v in pairs(string.split(player_roles, ',')) do
		if table.find({'player','developer','content-creator'}, v) then
			table.insert(roles, v)
		else
			if v == 'influencer' then
				table.insert(roles, 'content-creator')
			end
		end
	end
	
    local player_creation_year, player_creation_month, player_creation_day
	local player_is_verified = false
	
	local player_current_ccu = 0 -- track users total ccu across all obbies on obby wiki TODO
	local player_total_visits = args.visits or args.total_visits or 0
	local player_total_likes = 0
	local player_total_dislikes = 0
	local player_total_favorites = 0
	
	local thumb = args.image or args.thumbnail or args.thumb

	local player_user_name_raw
	local player_is_terminated = false

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
				'[https://www.roblox.com/users/%s/profile %s%s]',
				player_user_id,
				player_user_name_raw,
				(row.hasVerifiedBadge and '  [[File:Roblox_Verification_Badge.svg|12px|alt=Verified|link=]]') or ''
			)

			player_display_name = string.format(
				'[https://www.roblox.com/users/%s/profile %s%s]',
				player_user_id,
				player_display_name,
				(row.hasVerifiedBadge and '  [[File:Roblox_Verification_Badge.svg|12px|alt=Verified|link=]]') or ''
			)
		end

		if row and row.isBanned and row.isBanned == true then
			player_is_terminated = true
		end

		if row and row.created then
			-- e.g., 2018-06-25T07:34:11.183Z

			local year, month, day = row.created:match('^([%d]+)-([%d]+)-([%d]+)T')
			player_creation_year = year
			player_creation_month = month_by_index(tonumber(month))
			player_creation_day = day
		end
	end

	--

	local most_popular_obby = { name = ''; visits = 0; year = ''; month = ''; image = '' }
	local most_recent_obby = { name = ''; visits = 0; year = ''; month = ''; image = '' }

	local player_contributed_obbies = 0
	local player_contributed_visits = 0
	local player_contributed_likes = 0
	local player_contributed_dislikes = 0
	local player_contributed_favorites = 0

	if mw.ext.cargo and mw.ext.cargo.query then
		local target_user = player_user_name_raw or ("@" .. player_user_name_unformatted)

		local data = mw.ext.cargo.query('Obbies', 'COUNT(*)=count, SUM(visits)=total_visits, SUM(likes)=total_likes, SUM(dislikes)=total_dislikes, SUM(favorites)=total_favorites', {
			where = "developers HOLDS '" .. target_user .. "'"
		})

		if data and data[1] then
			player_total_obbies = tonumber(data[1].count) or 0
			player_total_visits = tonumber(data[1].total_visits) or 0
			player_total_likes = tonumber(data[1].total_likes) or 0
			player_total_dislikes = tonumber(data[1].total_dislikes) or 0
			player_total_favorites = tonumber(data[1].total_favorites) or 0
		end

		local contributors_data = mw.ext.cargo.query('Obbies', 'COUNT(*)=count, SUM(visits)=total_visits, SUM(likes)=total_likes, SUM(dislikes)=total_dislikes, SUM(favorites)=total_favorites', {
			where = "contributors HOLDS '" .. target_user .. "'"
		})

		if contributors_data and contributors_data[1] then
			player_contributed_obbies = tonumber(contributors_data[1].count) or 0
			player_contributed_visits = tonumber(contributors_data[1].total_visits) or 0
			player_contributed_likes = tonumber(contributors_data[1].total_likes) or 0
			player_contributed_dislikes = tonumber(contributors_data[1].total_dislikes) or 0
			player_contributed_favorites = tonumber(contributors_data[1].total_favorites) or 0
		end

		--

		local popular_data = mw.ext.cargo.query('Obbies', '_pageName=name, visits, month, year, thumbnail', {
			where = "developers HOLDS '" .. target_user .. "'",
			orderBy = "visits DESC",
			limit = 1
		})

		if popular_data and popular_data[1] then
			most_popular_obby.name = popular_data[1].name
			most_popular_obby.image = popular_data[1].thumbnail
			most_popular_obby.visits = tonumber(popular_data[1].visits) or 0
			most_popular_obby.month = tostring(popular_data[1].month)
			most_popular_obby.year = tostring(popular_data[1].year)
		end

		local recent_data = mw.ext.cargo.query('Obbies', '_pageName=name, visits, day, month, year, thumbnail', {
			where = "developers HOLDS '" .. target_user .. "'",
			orderBy = "year DESC, month DESC, day DESC",
			limit = 1
		})

		if recent_data and recent_data[1] then
			most_recent_obby.name = recent_data[1].name
			most_recent_obby.image = recent_data[1].thumbnail
			most_recent_obby.visits = tonumber(recent_data[1].visits) or 0
			most_recent_obby.month = tostring(recent_data[1].month)
			most_recent_obby.year = tostring(recent_data[1].year)
		end
	end

	--

    test:renderImage( thumb )

	test:renderIndicator( {
		data = player_is_terminated and 'Terminated' or 'Active',
		color = player_is_terminated and 'red' or 'green',
		tooltip = player_is_terminated and 'This user is currently banned/terminated on Roblox.' or 'This user is considered active on Roblox.'
	} )

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
			test:renderItem( 'Total Visits', get_comma_val(player_total_visits) .. '+ <ref name="statistics_data">Statistics are collected from every obby developed or contributed to by '.. player_user_name_raw.. ' which is stored in the Obby Wiki\'s database. Data may not be conclusive.</ref>'),
			test:renderItem( 'Obbies', '~' .. player_total_obbies .. ' <ref name="statistics_data" />'),
			test:renderItem( 'Total Rating', (player_total_likes + player_total_dislikes) > 0 and (math.floor((player_total_likes / (player_total_likes + player_total_dislikes)) * 1000) / 10) .. '% ( [[File:Likes.svg|12px|alt=Likes|link=]] ' .. get_comma_val(tostring(player_total_likes)) .. ' &nbsp; [[File:Dislikes.svg|12px|alt=Dislikes|link=]] ' .. get_comma_val(tostring(player_total_dislikes)) .. ')' or 'N/A'),
			test:renderItem( 'Total Favorites', get_comma_val(player_total_favorites) .. '+ <ref name="statistics_data" />'),
			test:renderItem( 'Contributions', '~' .. player_contributed_obbies),
			-- test:renderItem( 'Peak CCU', obby_stats_peak_ccu .. '+' ),
			-- test:renderItem( 'Likes', obby_stats_likes .. '+' ),
		}
	} )

	test:renderSection( {
		title = 'Featured',
		col = 2,
		content = {
			test:renderItem( {
				label = 'Most Popular Obby',
				colspan = 2,
				data = test:renderGameCard(
					most_popular_obby.image,
					most_popular_obby.name,
					get_comma_val( tostring( most_popular_obby.visits or 0 ) ),
					month_by_index( tonumber( most_popular_obby.month ) ),
					most_popular_obby.year
				)
			} ),
			test:renderItem( {
				label = 'Most Recent Obby',
				colspan = 2,
				data = test:renderGameCard(
					most_recent_obby.image,
					most_recent_obby.name,
					get_comma_val( tostring( most_recent_obby.visits or 0 ) ),
					month_by_index( tonumber( most_recent_obby.month ) ),
					most_recent_obby.year
				)
			} ),
			-- test:renderItem( 'Peak CCU', obby_stats_peak_ccu .. '+' ),
			-- test:renderItem( 'Likes', obby_stats_likes .. '+' ),
		}
	} )

	test:renderSection( {
		title = 'Statistics (contributed)',
		col = 2,
		content = {
			test:renderItem( 'Total Visits', get_comma_val(player_contributed_visits)),
			test:renderItem( 'Total Rating', (player_contributed_likes + player_contributed_dislikes) > 0 and (math.floor((player_contributed_likes / (player_contributed_likes + player_contributed_dislikes)) * 1000) / 10) .. '% ( [[File:Likes.svg|12px|alt=Likes|link=]] ' .. get_comma_val(tostring(player_contributed_likes)) .. ' &nbsp; [[File:Dislikes.svg|12px|alt=Dislikes|link=]] ' .. get_comma_val(tostring(player_contributed_dislikes)) .. ')' or 'N/A'),
			test:renderItem( 'Total Favorites', get_comma_val(player_contributed_favorites) .. '+ <ref name="statistics_data" />'),
		}
	} )

    test:renderSection( {
		title = 'Other',
		col = 2,
		content = {
			test:renderItem( 'Joined Roblox', player_creation_month .. ' ' .. player_creation_year ),
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
	-- TODO dynamically add categories for each role (e.g, Developer, Content Creator, etc.)

	local default_sort = '{{DEFAULTSORT:' .. string.sub(player_user_name_raw, 2) .. '}}'

	PlayerInfobox.store(frame, {
		username = player_user_name_raw,
		display_name = player_display_name,
		is_verified = player_is_verified,
		total_obbies = tonumber(player_total_obbies),
		year = tonumber(player_creation_year),
		month = tonumber(player_creation_month),
		day = tonumber(player_creation_day),
		user_id = tostring(player_user_id),
	})

    return frame:preprocess(default_sort) ..  rendered .. '\n' .. table.concat(append_categories, '\n')
end

return PlayerInfobox
