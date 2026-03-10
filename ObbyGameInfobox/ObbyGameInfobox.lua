-- inspired by scw

local ObbyGameInfobox = {}

local i18n = require('Module:i18n2').new('ObbyGameInfobox')

local months_full = {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'}

local function month_by_index(month)
	-- local months = i18n:get('months', {})
	local monthnum = tonumber(month)

	if not monthnum then return i18n:get('label_na', 'N/A') end

	return months_full[monthnum] or i18n:get('label_na', 'N/A')

	-- return months[tostring(monthnum)] or i18n:get('label_na', 'N/A')
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

local obby_schema = {
	_table = 'Obbies',
	_drilldownTabs = 'Tab1(format=list;delimiter=\;;fields=creator)',

	root_place_id = 'String', -- store as string now to prevent integer overflows
	universe_id = 'String',

	name = 'String',
	thumbnail = 'String',
	creator = 'String', -- aka. "Developer"
	developers = 'List (,) of String', -- for individual developers/contributors
	publisher = 'String', -- publisher, rarely used, refers to the company that published the game, not the developer or studio
	
	stages = 'Integer',
	tier = 'Integer',

	playability = 'String',

	is_public = 'Boolean',
	avatar_type = 'String',

	subgenre = 'String',
	
	year = 'Integer',
	month = 'Integer',
	day = 'Integer',
	
}

-- declares the INITIAL schema for the related cargo table(s), runs once or per template page refresh
-- do not confuse declaring with storing
function ObbyGameInfobox.declare(frame)
	local declare_args = {}

    table.insert(declare_args, '_table=' .. obby_schema._table)

    for k, v in pairs(obby_schema) do
        if k ~= '_table' and k ~= '_drilldownTabs' then
            table.insert(declare_args, k .. '=' .. v)
        end
    end

    return frame:callParserFunction{ name = '#cargo_declare', args = declare_args }
end

function ObbyGameInfobox.store(frame, data, debug_mode)
	local store_args = {}

    table.insert(store_args, '_table=' .. obby_schema._table)

	for k, v in pairs(data) do
        if v ~= nil and v ~= '' then
            table.insert(store_args, k .. '=' .. tostring(v))
        end
    end

	mw.logObject(store_args, 'ObbyGameInfobox Store Args')

	local cargo_store_res = frame:callParserFunction{ name = '#cargo_store', args = store_args }
	local debug_output = ''

	if debug_mode then
		debug_output = '<div class="obby-debug-storage" style="border: 1px solid #ccc; padding: 10px; margin: 10px 0; background-color: #f9f9f9;">'
		debug_output = debug_output .. '<strong>[ObbyGameInfobox Debug] Cargo Store Args:</strong><pre>' .. mw.text.nowiki(mw.text.jsonEncode(store_args)) .. '</pre>'
		if cargo_store_res and cargo_store_res ~= '' then
			debug_output = debug_output .. '<div style="color: red;"><strong>Cargo Store Result/Error:</strong> ' .. cargo_store_res .. '</div>'
		else
			debug_output = debug_output .. '<div style="color: green;"><strong>Cargo Store Status:</strong> Success (Empty Result)</div>'
		end
		debug_output = debug_output .. '</div>'
		return cargo_store_res, debug_output
	end

	return cargo_store_res, ''
end


function ObbyGameInfobox.main( frame )
    local InfoboxNeue = require( 'Module:InfoboxNeue' )

    local test = InfoboxNeue:new( {
		placeholderImage = 'Standard169placeholder.webp'
	} )

    local args = require( 'Module:Arguments' ).getArgs( frame )

	local absolute_title = mw.title.getCurrentTitle()

    local obby_name = args.name or '{{PAGENAME}}'
    local obby_starter_place_id = args.root_place_id or args.start_place_id or 1818
	local obby_join_sharelink_id = args.play or args.sharelink or args.play_sharelink or ''
	local obby_subgenre = args.subgenre or args.sub_genre or args.type or 'N/A'
	local obby_maturity = args.maturity or args.rating or 'na'
	-- local obby_update_freq = args.update_freq or args.update_frequency or 'Unknown'
	local obby_genai = args.ai_generated_content_disclosure or args.genai or args.ai
	local obby_ai_generated_content_disclosure = (obby_genai == 'branding' or obby_genai == 'thumbnails' or obby_genai == 'icon' or obby_genai == 'identity') and 'branding' or obby_genai == 'stated_none' and 'stated_none' or obby_genai == 'description' and 'description' or 'unknown'
	local obby_is_public = (args.is_public == 'true' or args.is_public == 'yes') and true or (args.is_public == 'false' or args.is_public == 'no') and false

	if args.is_public == nil then
		obby_is_public = true
	end

	local obby_subgenre_lower = string.lower(obby_subgenre)
	obby_subgenre_lower = string.gsub(obby_subgenre_lower, ' ', '')
	obby_subgenre_lower = string.gsub(obby_subgenre_lower, '-', '')
	obby_subgenre_lower = string.gsub(obby_subgenre_lower, '_', '')

	local obby_verified_status = (args.verified == 'true' or args.verified == 'full') and 'verified' or args.verified == 'false' and 'unstable' or args.verified == 'broken' and 'broken' or (args.verified == 'broken2' or args.verified == 'does_not_load') and 'does_not_load' or 'unknown'

	local subgenre_map = {
		['dco'] = 'subgenre_dco',
		['jpdco'] = 'subgenre_jpdco',
		['njpdco'] = 'subgenre_njpdco',
		['wpdco'] = 'subgenre_wpdco',
		['wdco'] = 'subgenre_wdco',
		['njdco'] = 'subgenre_njdco',
		['spdco'] = 'subgenre_spdco',
		['st'] = 'subgenre_stage_tower',
		['stagetowerobby'] = 'subgenre_stage_tower',
		['towerstageobby'] = 'subgenre_stage_tower',
		['stage_tower_obby'] = 'subgenre_stage_tower',
		['t'] = 'subgenre_tower',
		['towerobby'] = 'subgenre_tower',
		['tower_obby'] = 'subgenre_tower',
		['so'] = 'subgenre_story',
		['storyobby'] = 'subgenre_story',
		['difficultychartobby'] = 'subgenre_dco',
		['trollobby'] = 'subgenre_troll',
		['gimmickobby'] = 'subgenre_gimmick',
		['nojumpperdifficultychartobby'] = 'subgenre_njpdco',
		['wraparounddifficultychartobby'] = 'subgenre_wdco',
		['wraparoundperdifficultychartobby'] = 'subgenre_wpdco',
		['coopobby'] = 'subgenre_coop',
		['2playerobby'] = 'subgenre_coop',
		['tierobby'] = 'subgenre_tier',
		['multiplayer'] = 'subgenre_multiplayer',
		['4playerobby'] = 'subgenre_multiplayer',
		['obby'] = 'subgenre_classic',
		['classic'] = 'subgenre_classic',
		['classicobby'] = 'subgenre_classic',
		['timetrial'] = 'subgenre_time_trial',
		['tt'] = 'subgenre_time_trial',
	}

	local subgenre_key = subgenre_map[obby_subgenre_lower]
	if subgenre_key then
		obby_subgenre = i18n:get(subgenre_key)
	else
		obby_subgenre = i18n:get('subgenre_unsupported')
	end


	local maturity_map = {
		['minimal'] = 'maturity_minimal',
		['mild'] = 'maturity_mild',
		['mature'] = 'maturity_mature',
		['restricted'] = 'maturity_restricted',
		['unrated'] = 'maturity_unrated',
		['none'] = 'maturity_unrated'
	}

	local maturity_lower = string.lower(obby_maturity)
	local maturity_key = maturity_map[maturity_lower]
	if maturity_key then
		obby_maturity = i18n:get(maturity_key)
	else
		obby_maturity = i18n:get('maturity_unknown')
	end


	local obby_developer, obby_developer_was_corrected = args.developer or args.creator or 'Unknown', false
	local obby_developer_raw = obby_developer
	local obby_developer_canonical
    local obby_publisher = args.publisher or 'Self-Published'

	local obby_system = args.system or args.obby_system or 'Unknown'

    local obby_creation_year = args.year or ''
	local obby_creation_month = month_by_index(args.month and tonumber(args.month) or 0)
	local obby_creation_day = args.day or ''

	local obby_stats_visits = args.visits or 'N/A'
	local obby_stats_visits_raw
	local obby_stats_peak_ccu = args.peak_ccu or 'N/A'
	local obby_stats_likes = args.likes or 0
	local obby_stats_dislikes = args.dislikes or 0
	local obby_stats_favorites

	if tonumber(obby_stats_visits) ~= nil then
		obby_stats_visits = get_comma_val(args.visits)
	end

	if tonumber(obby_stats_peak_ccu) ~= nil then
		if obby_stats_peak_ccu == '0' then
			obby_stats_peak_ccu = 'N/A'
		else
			obby_stats_peak_ccu = get_comma_val(args.peak_ccu)
		end
	end

	if tonumber(obby_stats_likes) ~= nil then
		obby_stats_likes = tonumber(args.likes)
	else
		obby_stats_likes = 0
	end

	if tonumber(obby_stats_dislikes) ~= nil then
		obby_stats_dislikes = tonumber(args.dislikes)
	else
		obby_stats_dislikes = 0
	end



    local obby_levels = args.levels or args.stages or 'N/A'
	local obby_levels_total = args.levels_total or args.stages_total or nil
	local obby_difficulties = args.difficulties or ''
	local obby_difficulties_total = args.difficulties_total or nil
	local obby_towers = args.towers or ''
	local obby_towers_total = args.towers_total or nil

	local obby_avatar_type = args.avatar_type or args.rig_type or 'N/A'
	obby_avatar_type = string.lower(obby_avatar_type)

	local avatar_map = {
		['r6'] = 'avatar_r6',
		['r15'] = 'avatar_r15',
		['rthro'] = 'avatar_rthro',
		['choice'] = 'avatar_choice'
	}

	local avatar_key = avatar_map[obby_avatar_type]
	if avatar_key then
		obby_avatar_type = i18n:get(avatar_key)
	else
		obby_avatar_type = i18n:get('avatar_unknown')
	end

	local obby_tier = args.tier or '0'
	
	local thumb = args.image or args.thumbnail or args.thumb

	--

	local universe_id

	local _, res = pcall(function() 
		return mw.ext.externalData.getExternalData{
			url = 'https://apis.roblox.com/universes/v1/places/' .. obby_starter_place_id .. '/universe',
			format = 'json'
		};
	 end)

	universe_id = res and res.__json and res.__json.universeId


	---

	local last_updated = ''
	if universe_id then
		local game_res = mw.ext.externalData.getExternalData{
			url = 'https://games.roblox.com/v1/games?universeIds=' .. tostring(universe_id),
			format = 'json'
		}
		
		local game_json = game_res and game_res.__json
		local row = game_json and game_json.data and game_json.data[1]
		mw.log(game_res, row)

		if row and row.creator then
			local c = row.creator
			local base = (c.type == 'Group') and 'communities' or 'users'
			
			obby_developer_raw = obby_developer -- TODO remove

			if page_exists(c.type == 'Group' and c.name or '@' .. c.name) then
				obby_developer = '[[' .. c.name .. ']]' .. (c.hasVerifiedBadge and ' [[File:Roblox_Verification_Badge.svg|12px|alt=Verified|link=' .. obby_developer_raw .. ']]' or '')
			else
				obby_developer = string.format(
					'[https://roblox.com/%s/%s/%s %s%s]',
					base, c.id, base == 'communities' and (string.gsub(c.name, ' ', '_') .. '#!/about') or 'profile', (c.type == 'User' and '@' or '') .. c.name,
					(c.hasVerifiedBadge and '  [[File:Roblox_Verification_Badge.svg|12px|alt=Verified|link=]]') or ''
				)

				obby_developer_was_corrected = true
			end

			obby_developer_canonical = c.type == 'User' and '@'.. c.name or c.name
		end

		if row then
			obby_stats_visits = row.visits or obby_stats_visits
			obby_stats_favorites = row.favoritedCount or 'N/A'
			if row.visits and tonumber(obby_stats_visits) ~= nil then obby_stats_visits_raw = tonumber(obby_stats_visits); obby_stats_visits = get_comma_val(obby_stats_visits) end
			if row.favoritedCount and tonumber(obby_stats_favorites) ~= nil then obby_stats_favorites = get_comma_val(obby_stats_favorites) end

			if row.updated then
				last_updated = row.updated -- iso, e.g., 2026-03-07T09:29:16.4508416Z
			end
		end

		---

		local votes_res = mw.ext.externalData.getExternalData{
			url = 'https://games.roblox.com/v1/games/votes?universeIds=' .. tostring(universe_id),
			format = 'json'
		}

		local votes_json = votes_res and votes_res.__json
		local vrow = votes_json and votes_json.data and votes_json.data[1]

		if vrow then
			if vrow.upVotes and tonumber(vrow.upVotes) ~= nil then obby_stats_likes = tonumber(vrow.upVotes) end
			if vrow.downVotes and tonumber(vrow.downVotes) ~= nil then obby_stats_dislikes = tonumber(vrow.downVotes) end
		end
	end

	local thumbs
	local use_external_thumbs = false
	if universe_id then
		local thumb_overall_s, thumb_overall_err = pcall(function()

			-- request needs to route through oxalyl due to integer overflow issues on roblox's end
			--- imageIds are in some cases too large for int32 and arent returned as strings, use oxalyl to get them returned as strings
			local media_res = mw.ext.externalData.getExternalData{
				-- url = 'https://games.roblox.com/v2/games/' .. tostring(universe_id) .. '/media',
				-- 'https://oxalyl.apis.wolf1te.com/roblox.com/thumbnails/v1/badges/icons?badgeIds=%s&size=150x150&format=Png&isCircular=false&returnPolicy=PlaceHolder&wlft_auth=public-key-obbywiki-14-11-25-Vx9q7VCbM2Srn38LVDDhMk58GKf5bxD14KpPkS5XFzNEcM2FRHEaXNMbran621QySY0ueSUXZL5y4pTwjZ55nyyHhBTBuJ9BFnCAHzFLyPB3CfB9k9FGxBhAFST9qygnqtjd3PfUYtEEd4BRvhPpdQ25bLDjmjNhfucKqfE1DWJ2qkGuDubMSCGCqJGyLSFY5t2dpmTg4ij8viyCbu5dunfJfuZ71pCiz1ia4MUNBHdaPDSkg6wvWd9AJZGcHUT9&oxalyl_convert_int=true'
				url = 'https://oxalyl.apis.wolf1te.com/roblox.com/games/v2/games/' .. tostring(universe_id) .. '/media?fetchAllExperienceRelatedMedia=false&oxalyl_convert_int=true&wlft_auth=public-key-obbywiki-14-11-25-Vx9q7VCbM2Srn38LVDDhMk58GKf5bxD14KpPkS5XFzNEcM2FRHEaXNMbran621QySY0ueSUXZL5y4pTwjZ55nyyHhBTBuJ9BFnCAHzFLyPB3CfB9k9FGxBhAFST9qygnqtjd3PfUYtEEd4BRvhPpdQ25bLDjmjNhfucKqfE1DWJ2qkGuDubMSCGCqJGyLSFY5t2dpmTg4ij8viyCbu5dunfJfuZ71pCiz1ia4MUNBHdaPDSkg6wvWd9AJZGcHUT9',
				format = 'json'
			}

			local media_json = media_res and media_res.__json
			local mdata = media_json and media_json.data

			local image_ids = {}
			local thumb_urls = {}
			local thumb_found = false

			if mdata then
				for _, v in ipairs(mdata) do
					if v.assetType == 'Image' and v.imageId and (v.assetTypeId == 1 or v.assetTypeId == '1') then
						-- 
						if v.approved == true then
							table.insert(image_ids, v.imageId)
							thumb_found = true
						end
					end
				end

				if thumb_found and #image_ids > 0 then
					local thumb_res = mw.ext.externalData.getExternalData{
						url = 'https://thumbnails.roblox.com/v1/games/' .. tostring(universe_id) .. '/thumbnails?thumbnailIds=' .. table.concat(image_ids, ',') .. '&size=768x432&format=Webp&isCircular=false',
						format = 'json'
					}

					local thumb_json = thumb_res and thumb_res.__json
					local tdata = thumb_json and thumb_json.data

					if tdata then
						for _, v in ipairs(tdata) do
							if v.state == 'Completed' and v.imageUrl then
								table.insert(thumb_urls, v.imageUrl)
								use_external_thumbs = true
							end
						end
						
						thumbs = thumb_urls
					end
				end
			end
		end)

		if not thumb_overall_s then
			mw.log('Error fetching thumbnail: ' .. tostring(thumb_overall_err))
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

	if use_external_thumbs and thumbs and #thumbs > 0 and args.disable_auto_thumb ~= 'false' then
		
		if #thumbs == 1 then
			-- thumb = thumbs[1]
			-- test:renderImage( thumbs[1] ) -- todo cant support external images yet
			if thumb then
				test:renderImage( thumb )
			end
		else
			if thumb then
				-- render invisible internal file so mediawiki can generate an article thumbnail
				test:renderInvisibleImage( thumb )
			end
			test:renderCarousel( thumbs )
		end

	else
		if thumb and thumb ~= '' then
			test:renderImage( thumb )
		else
			test:renderImage( 'Standard169placeholder.webp' )
		end
	end

	local obby_status_key = args.unreleased == 'true' and 'status_unreleased' or obby_is_public and 'status_public' or 'status_private'
	local obby_status = i18n:get(obby_status_key)
	local obby_status_raw = args.unreleased == 'true' and 'Unreleased' or obby_is_public and 'Public' or 'Private'

	test:renderIndicator( {
		data = obby_status,
		color = obby_status_raw == 'Unreleased' and 'gray' or obby_status_raw == 'Public' and 'green' or 'red',
		tooltip = (obby_is_public and i18n:get('tooltip_public') or i18n:get('tooltip_private'))
	} )

    test:renderHeader( {
		title = '[https://roblox.com/games/' .. obby_starter_place_id .. '/ '  .. obby_name .. ']',
		subtitle = (obby_developer_was_corrected and (i18n:get('label_by') .. ' \'\'\''..obby_developer..'\'\'\'') or (i18n:get('label_by') .. ' \'\'\''  .. obby_developer .. '\'\'\'')) .. (obby_creation_year ~= '' and (' — ' .. obby_creation_year) or '')
	} )

	-- Helper for "of total" display
	local function format_with_total(value, total)
		if total and value then
			return value .. ' <small>(' .. i18n:format('of_total', total) .. ')</small>'
		end
		return value or ''
	end

    test:renderSection( {
		title = i18n:get('section_gameplay'),
		col = 2,
		content = {
			test:renderItem( i18n:get('field_checkpoints'), format_with_total(obby_levels, obby_levels_total)),
			test:renderItem( i18n:get('field_difficulties'), format_with_total(obby_difficulties, obby_difficulties_total)),
			test:renderItem( i18n:get('field_towers'), format_with_total(obby_towers, obby_towers_total)),
			test:renderItem( i18n:get('field_tier'), '[[Special:MyLanguage/Tiers|'.. (obby_tier == '0' and '0 - Unrated/Unknown' or obby_tier).. ']]' ),
			test:renderItem( i18n:get('field_avatar_type'), obby_avatar_type )
		}
	} )

	test:renderSection( {
		title = i18n:get('section_statistics'),
		col = 2,
		content = {
			test:renderItem( i18n:get('field_visits'), obby_stats_visits .. '+' .. ' <ref name="statistics_data">The Obby Wiki automatically sources live statistics directly from Roblox\'s database. See [https://roblox.com/games/' .. obby_starter_place_id .. '/ {{PAGENAME}} on Roblox] for more information. Statistics last retrieved at: ' .. os.date("%Y-%m-%d %H:%M:%S") .. ' UTC.</ref>'),
			test:renderItem( i18n:get('field_peak_ccu'), '{{#simple-tooltip: ' .. (obby_stats_peak_ccu .. '+') .. ' | ' .. i18n:get('tooltip_peak_ccu') .. ' }}' ),
			test:renderItem( i18n:get('field_rating'), (obby_stats_likes + obby_stats_dislikes) > 0 and (math.floor((obby_stats_likes / (obby_stats_likes + obby_stats_dislikes)) * 1000) / 10) .. '% ( [[File:Likes.svg|12px|alt=Verified|link=]] ' .. get_comma_val(tostring(obby_stats_likes)) .. ' &nbsp; [[File:Dislikes.svg|12px|alt=Verified|link=]] ' .. get_comma_val(tostring(obby_stats_dislikes)) .. ')' or i18n:get('label_na')),
			test:renderItem( i18n:get('field_favorites'), (obby_stats_favorites or 'N/A') .. '+ <ref name="statistics_data" />' ),
		}
	} )

	-- AI content disclosure mapping
	local ai_disclosure_map = {
		['branding'] = 'ai_branding',
		['stated_none'] = 'ai_stated_none',
		['description'] = 'ai_description'
	}
	local ai_disclosure_key = ai_disclosure_map[obby_ai_generated_content_disclosure]
	local ai_disclosure_text = ai_disclosure_key and i18n:get(ai_disclosure_key) or i18n:get('ai_unknown')


	local last_updated_year = last_updated:sub(1, 4)
	local last_updated_month = month_by_index(tonumber(last_updated:sub(6, 7) or 1))
	

	local full_my = obby_creation_month .. ' ' .. obby_creation_year
    test:renderSection( {
		title = i18n:get('section_publishing'),
		col = 2,
		content = {
			test:renderItem( i18n:get('field_released'), '[[:Category:' .. full_my .. '|' .. full_my .. ']]' ),
			test:renderItem( i18n:get('field_latest_update'), last_updated_month .. ' ' .. last_updated_year ),
			test:renderItem( i18n:get('field_publisher'), obby_publisher ),
			test:renderItem( i18n:get('field_maturity'), obby_maturity ),
			test:renderItem( i18n:get('field_genre'), i18n:get('genre_obby') ),
			test:renderItem( i18n:get('field_sub_genre'), page_exists(obby_subgenre) and '[[' .. obby_subgenre .. ']]' or obby_subgenre ),
			test:renderItem( i18n:get('field_obby_system'), obby_system ),
			test:renderItem( i18n:get('field_ai_content'), ai_disclosure_text ),
		}
	} )

	local social_icons_wikitext = {}
	local platform_icons_wikitext = {}

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
				'[[File:%s|24px|alt=%s|class=platform-icon|link=]]',
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
				title = i18n:get('section_presence'),
				content = {
					test:renderItem(
						{
							label = i18n:get('field_socials'),
							plainlinks_enabled = true,

							data = table.concat(social_icons_wikitext, ' ')	
						}
					),

					test:renderItem(
						{
							label = i18n:get('field_platforms'),
							plainlinks_enabled = true,

							data = table.concat(platform_icons_wikitext, ' ')
						}
					)
				}
			}
		)
	end

	-- Verified status mapping
	local verified_info_map = {
		['verified'] = 'verified_verified',
		['unstable'] = 'verified_unstable',
		['broken'] = 'verified_broken',
		['does_not_load'] = 'verified_does_not_load'
	}
	local verified_info_key = verified_info_map[obby_verified_status] or 'verified_unknown'
	local verified_info_text = i18n:get(verified_info_key)

	test:renderSection({
		title = i18n:get('section_playability'),
		col = 2,
		content = {
			test:renderItem(
				{
					label = i18n:get('field_status'),
					plainlinks_enabled = true,
					data = obby_verified_status == 'verified' and '[[File:Verified-check-green-96.webp|36px|alt=Verified|link=]]' or (obby_verified_status == 'unstable' or obby_verified_status == 'broken' or obby_verified_status == 'does_not_load') and '[[File:Verified-dash-red-72.webp|36px|alt=Unstable|link=]]' or obby_verified_status == 'unknown' and '[[File:Verified-dash-orange-72.webp|36px|alt=Unknown|link=]]'
				}
			),
			test:renderItem(
				{
					label = i18n:get('field_info'),
					data = verified_info_text
				}
			)
		}
	})

	test:renderSection( {
		title = i18n:get('section_technical'),
		col = 2,
		content = {
			test:renderItem( i18n:get('field_start_place_id'), '<code>' .. (obby_starter_place_id == 1818 and i18n:get('label_unlisted') or tostring(obby_starter_place_id) or i18n:get('label_na')) .. '</code>' ),
			test:renderItem( i18n:get('field_universe_id'), '<code>' .. (tostring(universe_id) or i18n:get('label_na')) .. '</code>' ),
		}
	} )

    test:renderFooter( {
		button = {
			icon = 'GoogleMaterialIcons-Globe.svg',
			label = i18n:get('section_external_links'),
			type = 'popup',
			content = test:renderSection( {
				content = {
					test:renderItem( {
						label = i18n:get('link_roblox'),
						data = {test:renderLinkButton( {
							label = i18n:get('link_view_roblox'),
							link = 'https://roblox.com/games/' .. obby_starter_place_id .. '/'
						}),

						test:renderLinkButton({
							label = i18n:get('link_play_roblox'),
							link = (obby_join_sharelink_id ~= '' and 'https://roblox.com/join/' .. obby_join_sharelink_id) or 'https://roblox.com/start?placeId=' .. obby_starter_place_id .. '&launchData=obbywiki'
						})
					}					
					} ),

					test:renderItem( {
						label = i18n:get('link_analytics'),
						data = {test:renderLinkButton( {
							label = i18n:get('link_romonitorstats'),
							link = 'https://romonitorstats.com/experience/' .. obby_starter_place_id .. '/'
						}),
						test:renderLinkButton( {
							label = i18n:get('link_rolimons'),
							link = 'https://rolimons.com/game/' .. obby_starter_place_id .. '/'
						})
					}					
					} )
				}
			}, true )
		}
	} )

	local rendered = test:renderInfobox( nil, '[https://roblox.com/games/' .. obby_starter_place_id .. '/ '  .. obby_name .. ']' )
	local parsed_month = obby_creation_month

	local append_categories = {}

	if tonumber(obby_creation_year) >= 2008 and tonumber(obby_creation_year) <= os.date('*t').year+2 then
		table.insert(append_categories, '[[Category:' .. tostring(obby_creation_year) .. ']]')
		
		if parsed_month ~= 'N/A' then
			table.insert(append_categories, '[[Category:' .. parsed_month .. ' ' .. tostring(obby_creation_year) .. ']]')
		end
	end

	if parsed_month ~= 'N/A' then
		table.insert(append_categories, '[[Category:' .. parsed_month .. ']]')
	end

	if obby_subgenre then
		table.insert(append_categories, '[[Category:' .. obby_subgenre .. ']]')
	end

	if not obby_stats_visits_raw then
		obby_stats_visits_raw = 0
	end

	if obby_stats_visits_raw < 5000 then
		table.insert(append_categories, '[[Category:' .. '0-5%2C000_visits' .. ']]')
	elseif obby_stats_visits_raw < 25000 then
		table.insert(append_categories, '[[Category:' .. '5%2C000-25%2C000_visits' .. ']]')
	elseif obby_stats_visits_raw < 50000 then
		table.insert(append_categories, '[[Category:' .. '25%2C000-50%2C000_visits' .. ']]')
	elseif obby_stats_visits_raw < 100000 then
		table.insert(append_categories, '[[Category:' .. '50%2C000-100%2C000_visits' .. ']]')
	elseif obby_stats_visits_raw < 500000 then
		table.insert(append_categories, '[[Category:' .. '100%2C000-500%2C000_visits' .. ']]')
	elseif obby_stats_visits_raw < 1000000 then
		table.insert(append_categories, '[[Category:' .. '500%2C000-1%2C000%2C000_visits' .. ']]')
	else
		table.insert(append_categories, '[[Category:' .. 'Above_1%2C000%2C000_visits' .. ']]')
	end

	table.insert(append_categories, '[[Category:' .. 'Obby' .. ']]')

	local shortdesc = '{{SHORTDESC:' .. (obby_subgenre .. ' by ' .. (obby_developer_canonical or obby_developer_raw or 'Unknown') .. ' - ' .. obby_creation_year) .. '}}'

	local cargo_store_res, cargo_debug_res = '', ''

	if absolute_title and absolute_title.namespace == 10 then
		-- do not append categories to template pages
		append_categories = {}
	else
		-- only store in cargo if not a template page

		-- if args.root_place_id_unknown ~= 'true' and args.root_place_id_unknown ~= true then
			cargo_store_res, cargo_debug_res = ObbyGameInfobox.store(frame, {
				root_place_id = tostring(args.root_place_id),
				universe_id = tostring(universe_id),
				name = args.name or mw.title.getCurrentTitle().text,
				thumbnail = thumb,
				publisher = obby_publisher ~= 'Self-Published' and obby_publisher or nil,
				creator = obby_developer_canonical or obby_developer_raw,
				stages = tonumber(args.stages) or nil,
				tier = tonumber(args.tier) or 0,
				subgenre = obby_subgenre,
				year = tonumber(obby_creation_year) or nil,
				month = tonumber(args.month) or nil,
				day = tonumber(obby_creation_day) or nil,
				is_public = obby_is_public,
				avatar_type = obby_avatar_type == 'R6' and 'R6' or obby_avatar_type == 'R15' and 'R15' or obby_avatar_type == 'Rthro' and 'Rthro' or obby_avatar_type == 'Choice' and 'Choice' or nil,
				developers = args.developers,
				playability = verified_info_key,
			}, args.debug == 'true' or args.debug == true)
		-- end
	end
	

	-- JSON-LD structured data (Schema.org VideoGame)
	-- local game_url = 'https://roblox.com/games/' .. obby_starter_place_id .. '/'
	-- local page_url = mw.title.getCurrentTitle():fullUrl('', 'https')

	-- local json_ld = {
	-- 	['@context'] = 'https://schema.org',
	-- 	['@type'] = 'VideoGame',
	-- 	name = args.name or mw.title.getCurrentTitle().text,
	-- 	url = page_url,
	-- 	description = obby_subgenre .. ' by ' .. (obby_developer_canonical or obby_developer_raw or 'Unknown') .. ' — ' .. obby_creation_year,
	-- 	gamePlatform = 'Roblox',
	-- 	genre = { 'Obby', obby_subgenre },
	-- 	applicationCategory = 'Game',
	-- 	operatingSystem = 'Cross-platform',
	-- }

	-- -- image
	-- if thumb and thumb ~= '' then
	-- 	json_ld.image = 'https://obbywiki.com/wiki/Special:FilePath/' .. mw.uri.encode(thumb, 'PATH')
	-- elseif use_external_thumbs and thumbs and #thumbs > 0 then
	-- 	json_ld.image = thumbs[1]
	-- end

	-- -- author / developer
	-- if obby_developer_canonical or obby_developer_raw then
	-- 	json_ld.author = {
	-- 		['@type'] = (string.sub(obby_developer_canonical or obby_developer_raw, 1, 1) == '@' and 'Person' or 'Organization'),
	-- 		name = obby_developer_canonical or obby_developer_raw,
	-- 	}
	-- end

	-- -- publisher
	-- if obby_publisher and obby_publisher ~= 'Self-Published' then
	-- 	json_ld.publisher = {
	-- 		['@type'] = 'Organization',
	-- 		name = obby_publisher,
	-- 	}
	-- end

	-- -- date published  (ISO 8601)
	-- if tonumber(obby_creation_year) then
	-- 	local date_str = tostring(obby_creation_year)
	-- 	if tonumber(args.month) then
	-- 		date_str = date_str .. '-' .. string.format('%02d', tonumber(args.month))
	-- 		if tonumber(obby_creation_day) then
	-- 			date_str = date_str .. '-' .. string.format('%02d', tonumber(obby_creation_day))
	-- 		end
	-- 	end
	-- 	json_ld.datePublished = date_str
	-- end

	-- -- aggregate rating (likes / dislikes → 1-5 scale)
	-- local total_votes = obby_stats_likes + obby_stats_dislikes
	-- if total_votes > 0 then
	-- 	local pct = obby_stats_likes / total_votes
	-- 	json_ld.aggregateRating = {
	-- 		['@type'] = 'AggregateRating',
	-- 		ratingValue = tostring(math.floor(pct * 50 + 0.5) / 10), -- 0‑5 scale
	-- 		bestRating = '5',
	-- 		worstRating = '0',
	-- 		ratingCount = tostring(total_votes),
	-- 	}
	-- end

	-- -- numberOfLevels (custom / GamePlayMode etc.)
	-- if obby_levels and obby_levels ~= 'N/A' and tonumber(obby_levels) then
	-- 	json_ld.numberOfLevels = tonumber(obby_levels)
	-- end

	-- -- sameAs (external links)
	-- local same_as = { game_url }
	-- for key, v in pairs(smm) do
	-- 	if args[key] then
	-- 		table.insert(same_as, v.url .. args[key])
	-- 	end
	-- end
	-- if #same_as > 0 then
	-- 	json_ld.sameAs = same_as
	-- end

	-- -- available platforms
	-- local game_platforms = {}
	-- if args.pc then table.insert(game_platforms, 'PC') end
	-- if args.tablet then table.insert(game_platforms, 'Tablet') end
	-- if args.phone then table.insert(game_platforms, 'Mobile') end
	-- if args.console then table.insert(game_platforms, 'Console') end
	-- if args.vr then table.insert(game_platforms, 'VR') end
	-- if #game_platforms > 0 then
	-- 	json_ld.gamePlatform = game_platforms
	-- end

	-- local json_ld_string = '<script type="application/ld+json">' .. mw.text.jsonEncode(json_ld) .. '</script>'

	-- temporary workaround to json-ld injection issues
	-- WikiSEO: injects JSON-LD into <head> via OutputPage::addHeadItem(), bypassing the HTML sanitizer
	local seo_image = thumb
	if not seo_image or seo_image == '' then
		seo_image = (use_external_thumbs and thumbs and #thumbs > 0) and thumbs[1] or nil
	end

	local seo_date_published
	if tonumber(obby_creation_year) then
		seo_date_published = tostring(obby_creation_year)
		if tonumber(args.month) then
			seo_date_published = seo_date_published .. '-' .. string.format('%02d', tonumber(args.month))
			if tonumber(obby_creation_day) then
				seo_date_published = seo_date_published .. '-' .. string.format('%02d', tonumber(obby_creation_day))
			end
		end
	end

	local seo_description = obby_name .. ' is a ' .. obby_subgenre .. ' by ' .. (obby_developer_canonical or obby_developer_raw or 'an unknown developer') .. ' released in ' .. obby_creation_month .. ' of ' .. obby_creation_year
	local seo_keywords_parts = { 'obby', obby_subgenre, (obby_developer_canonical or obby_developer_raw or ''), 'roblox' }
	local seo_keywords = table.concat(seo_keywords_parts, ', ')

	mw.ext.seo.set{
		type = 'VideoGame',
		-- title = (args.name or mw.title.getCurrentTitle().text or 'Untitled') .. ' - Obby Wiki',
		description = seo_description,
		keywords = seo_keywords,
		image = seo_image,
		published_time = seo_date_published,
		author = obby_developer_canonical or obby_developer_raw or 'Unknown',
		locale = 'en_US',
		site_name = 'Obby Wiki',
	}

    return frame:preprocess(shortdesc) .. rendered .. (cargo_debug_res or '') .. (cargo_store_res or '') .. '\n' .. table.concat(append_categories, '\n')
end

return ObbyGameInfobox