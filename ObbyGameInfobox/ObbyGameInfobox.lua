-- inspired by scw

local ObbyGameInfobox = {}

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




function ObbyGameInfobox.main( frame )
    local InfoboxNeue = require( 'Module:InfoboxNeue' )

    local test = InfoboxNeue:new( {
		placeholderImage = 'Standard169placeholder.webp'
	} )

    local args = require( 'Module:Arguments' ).getArgs( frame )

    local obby_name = args.name or '{{PAGENAME}}'
    local obby_starter_place_id = args.root_place_id or args.start_place_id or 1818
	local obby_join_sharelink_id = args.play or args.sharelink or args.play_sharelink or ''
	local obby_subgenre = args.subgenre or args.sub_genre or args.type or 'N/A'
	local obby_maturity = args.maturity or args.rating or 'na'
	local obby_update_freq = args.update_freq or args.update_frequency or 'Unknown'
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

	if obby_subgenre_lower == 'dco' then
		obby_subgenre = 'Difficulty Chart Obby'
	elseif obby_subgenre_lower == 'jpdco' then
		obby_subgenre = 'Jump Per Difficulty Chart Obby'
	elseif obby_subgenre_lower == 'njpdco' then
		obby_subgenre = 'No Jump Per Difficulty Chart Obby'
	elseif obby_subgenre_lower == 'wpdco' then
		obby_subgenre = 'Wrap-Around Per Difficulty Chart Obby'
	elseif obby_subgenre_lower == 'wdco' then
		obby_subgenre = 'Wrap-Around Difficulty Chart Obby'
	elseif obby_subgenre_lower == 'njdco' then
		obby_subgenre = 'No Jumping Difficulty Chart Obby'
	elseif obby_subgenre_lower == 'spdco' then
		obby_subgenre = 'Stick-Out Per Difficulty Chart Obby'
	elseif obby_subgenre_lower == 'st' then
		obby_subgenre = 'Stage Tower Obby'
	elseif obby_subgenre_lower == 'stage_tower_obby' then
		obby_subgenre = 'Stage Tower Obby'
	elseif obby_subgenre_lower == 't' then
		obby_subgenre = 'Tower Obby'
	elseif obby_subgenre_lower == 'tower_obby' then
		obby_subgenre = 'Tower Obby'
	elseif obby_subgenre_lower == 'so' then
		obby_subgenre = 'Story Obby'
	else
		if obby_subgenre_lower == 'difficultychartobby' then
			obby_subgenre = 'Difficulty Chart Obby'
		elseif obby_subgenre_lower == 'stagetowerobby' or obby_subgenre_lower == 'towerstageobby' then
			obby_subgenre = 'Stage Tower Obby'
		elseif obby_subgenre_lower == 'towerobby' then
			obby_subgenre = 'Tower Obby'
		elseif obby_subgenre_lower == 'storyobby' then
			obby_subgenre = 'Story Obby'
		elseif obby_subgenre_lower == 'trollobby' then
			obby_subgenre = 'Troll Obby'
		elseif obby_subgenre_lower == 'gimmickobby' then
			obby_subgenre = 'Gimmick Obby'
		elseif obby_subgenre_lower == 'nojumpperdifficultychartobby' then
			obby_subgenre = 'No Jump Per Difficulty Chart Obby'
		elseif obby_subgenre_lower == 'wraparounddifficultychartobby' then
			obby_subgenre = 'Wrap-Around Difficulty Chart Obby'
		elseif obby_subgenre_lower == 'wraparoundperdifficultychartobby' then
			obby_subgenre = 'Wrap-Around Per Difficulty Chart Obby'
		elseif obby_subgenre_lower == 'coopobby' or obby_subgenre_lower == '2playerobby' then
			obby_subgenre = 'Co-Op Obby'
		elseif obby_subgenre_lower == 'tierobby' then
			obby_subgenre = 'Tier Obby'
		elseif obby_subgenre_lower == 'multiplayer' or obby_subgenre_lower == '4playerobby' then
			obby_subgenre = 'Multiplayer Obby'
			elseif obby_subgenre_lower == 'obby' or obby_subgenre_lower == 'classic' or obby_subgenre_lower == 'classicobby' then
			obby_subgenre = 'Classic Obby'
		else
			obby_subgenre = 'Unsupported sub-genre'
		end
	end


	obby_maturity = string.lower(obby_maturity)

	if obby_maturity == 'minimal' then
		obby_maturity = 'Minimal - Ages 5+'
	elseif obby_maturity == 'mild' then
		obby_maturity = 'Mild - Ages 9+'
	elseif obby_maturity == 'mature' then
		obby_maturity = 'Mature - Ages 13+'
	elseif obby_maturity == 'restricted' then
		obby_maturity = 'Restricted - Ages 18+'
	elseif obby_maturity == 'unrated' or obby_maturity == 'none' then
		obby_maturity = 'Unrated - Ages 18+'
	else
		obby_maturity = 'N/A - Unknown'
	end


	local obby_developer, obby_developer_was_corrected = args.developer or args.creator or 'Unknown', false
	local obby_developer_raw = obby_developer
	local obby_developer_canonical
    local obby_publisher = args.publisher or 'Self-Published'

	local obby_system = args.system or args.obby_system or 'Unknown'

    local obby_creation_year = args.year or ''
	local obby_creation_month = month_by_index(args.month and tonumber(args.month) or 0)

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

	if obby_avatar_type == 'r6' then
		obby_avatar_type = 'R6'
	elseif obby_avatar_type == 'r15' then
		obby_avatar_type = 'R15'
	elseif obby_avatar_type == 'rthro' then
		obby_avatar_type = 'Rthro'
	elseif obby_maturity == 'choice' then
		obby_avatar_type = 'Player Choice'
	else
		obby_avatar_type = 'N/A - Unknown'
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

	local obby_status = args.unreleased == 'true' and 'Unreleased' or obby_is_public and 'Public' or 'Private'

	test:renderIndicator( {
		data = obby_status,
		color = obby_status == 'Unreleased' and 'gray' or obby_status == 'Public' and 'green' or 'red',
		tooltip = (obby_is_public and 'This obby is publicly accessible on Roblox.' or
					'This obby is private and is not accessible to all users.'
		)
	} )

    test:renderHeader( {
		title = '[https://roblox.com/games/' .. obby_starter_place_id .. '/ '  .. obby_name .. ']',
		subtitle = (obby_developer_was_corrected and ('by \'\'\''..obby_developer..'\'\'\'') or ('by \'\'\''  .. obby_developer .. '\'\'\'')) .. (obby_creation_year ~= '' and (' — ' .. obby_creation_year) or '')
	} )

    test:renderSection( {
		title = 'Gameplay',
		col = 2,
		content = {
			test:renderItem( 'Checkpoints (Stages)', obby_levels_total and obby_levels and (obby_levels .. (obby_levels_total and ' <small>(of ' .. obby_levels_total .. ')</small>')) or obby_levels or ''),
			test:renderItem( 'Difficulties', obby_difficulties_total and obby_difficulties and (obby_difficulties .. (obby_difficulties_total and ' <small>(of ' .. obby_difficulties_total .. ')</small>')) or obby_difficulties or ''),
			test:renderItem( 'Towers', obby_towers_total and obby_towers and (obby_towers .. (obby_towers_total and ' <small>(of ' .. obby_towers_total .. ')</small>')) or obby_towers and obby_towers or ''),
			test:renderItem( 'Tier', '[[Special:MyLanguage/Tiers|'.. (obby_tier == '0' and '0 - Unrated/Unknown' or obby_tier).. ']]' ),
			test:renderItem( 'Avatar Type', obby_avatar_type )
		}
	} )

	test:renderSection( {
		title = 'Statistics',
		col = 2,
		content = {
			test:renderItem( 'Visits', obby_stats_visits .. '+'),
			test:renderItem( 'Peak CCU', '{{#simple-tooltip: ' .. (obby_stats_peak_ccu .. '+') .. ' | All-time highest amount of players }}' ),
			test:renderItem( 'Rating', (obby_stats_likes + obby_stats_dislikes) > 0 and (math.floor((obby_stats_likes / (obby_stats_likes + obby_stats_dislikes)) * 1000) / 10) .. '% ( [[File:Likes.svg|12px|alt=Verified|link=]] ' .. get_comma_val(tostring(obby_stats_likes)) .. ' &nbsp; [[File:Dislikes.svg|12px|alt=Verified|link=]] ' .. get_comma_val(tostring(obby_stats_dislikes)) .. ')' or 'N/A'),
			test:renderItem( 'Favorites', obby_stats_favorites .. '+' ),
		}
	} )

    test:renderSection( {
		title = 'Publishing & Other',
		col = 2,
		content = {
			test:renderItem( 'Released', obby_creation_month .. ' ' .. obby_creation_year ),
			test:renderItem( 'Update Frequency', obby_update_freq ),
			test:renderItem( 'Publisher', obby_publisher ),
			test:renderItem( 'Maturity', obby_maturity ),
			test:renderItem( 'Genre', 'Obby & Platformer' ),
			test:renderItem( 'Sub-genre', obby_subgenre ),
			test:renderItem( 'Obby System', obby_system ),
			test:renderItem( 'AI Content', obby_ai_generated_content_disclosure == 'branding' and 'Use in branding, promotional images, or other' or obby_ai_generated_content_disclosure == 'stated_none' and 'The developer has stated that no GenAI was used.' or obby_ai_generated_content_disclosure == 'description' and 'Use in the game\'s description' or 'None/Unknown' ),
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
				title = 'Presence',
				content = {
					test:renderItem(
						{
							label = 'Socials',
							plainlinks_enabled = true,

							data = table.concat(social_icons_wikitext, ' ')	
						}
					),

					test:renderItem(
						{
							label = 'Platforms',
							plainlinks_enabled = true,

							data = table.concat(platform_icons_wikitext, ' ')
						}
					)
				}
			}
		)
	end

	test:renderSection({
		title = 'Playability',
		col = 2,
		content = {
			test:renderItem(
				{
					label = 'Status',
					plainlinks_enabled = true,
					data = obby_verified_status == 'verified' and '[[File:Verified-check-green-96.webp|36px|alt=Verified|link=]]' or (obby_verified_status == 'unstable' or obby_verified_status == 'broken' or obby_verified_status == 'does_not_load') and '[[File:Verified-dash-red-72.webp|36px|alt=Unstable|link=]]' or obby_verified_status == 'unknown' and '[[File:Verified-dash-orange-72.webp|36px|alt=Unknown|link=]]'
				}
			),
			test:renderItem(
				{
					label = 'Info',

					data = obby_verified_status == 'verified' and 'Verified - Fully Possible - All Devices' or obby_verified_status == 'unstable' and 'Unstable - Partially Possible - Some Devices' or obby_verified_status == 'broken' and 'Broken - Not Possible' or obby_verified_status == 'does_not_load' and 'Unplayable - Does not load' or 'Unknown'
				}
			)
		}
	})

	test:renderSection( {
		title = 'Technical',
		col = 2,
		content = {
			test:renderItem( 'Start Place ID', '<code>' .. (obby_starter_place_id == 1818 and 'Unlisted' or tostring(obby_starter_place_id) or 'N/A') .. '</code>' ),
			test:renderItem( 'Universe ID', '<code>' .. (tostring(universe_id) or 'N/A') .. '</code>' ),
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
						label = 'Roblox',
						data = {test:renderLinkButton( {
							label = 'View on Roblox',
							link = 'https://roblox.com/games/' .. obby_starter_place_id .. '/'
						}),

						test:renderLinkButton({
							label = 'Play on Roblox',
							link = (obby_join_sharelink_id ~= '' and 'https://roblox.com/join/' .. obby_join_sharelink_id) or 'https://roblox.com/start?placeId=' .. obby_starter_place_id .. '&launchData=obbywiki'
						})
					}					
					} ),

					test:renderItem( {
						label = 'Analytics (not affiliated)',
						data = {test:renderLinkButton( {
							label = 'View on RoMonitorStats',
							link = 'https://romonitorstats.com/experience/' .. obby_starter_place_id .. '/'
						}),
						test:renderLinkButton( {
							label = 'View on Rolimons',
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
		table.insert(append_categories, '[[Category:' .. 'above_1%2C000%2C000_visits' .. ']]')
	end

	local shortdesc = '{{SHORTDESC:' .. (obby_subgenre .. ' by ' .. obby_developer_canonical .. ' - ' .. obby_creation_year) .. '}}'

    return frame:preprocess(shortdesc) .. rendered .. '\n' .. table.concat(append_categories, '\n')
end

return ObbyGameInfobox