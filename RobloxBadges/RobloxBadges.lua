local p = {}

local ED = mw.ext.externalData
local html = mw.html

local function fetch_json(url)
	local data, errs = ED.getExternalData{ url = url }
	if errs and #errs > 0 then
		return nil, table.concat(errs, "; ")
	end
	if not data or not data.__json then
		return nil, "no JSON"
	end
	return data.__json, nil
end

local function format_date_timestamp(iso_date)
	local timestamp = iso_date or '2025-11-08T21:49:17.671+00:00'

	local cleaned = timestamp:gsub('%.%d+', '')
	local lang = mw.getContentLanguage()

	local s, res = pcall(lang.formatDate, lang, "j F Y, H:i (T)", cleaned, true)
    
    if s then
        return res
    else
        return "'''Unknown Date'''"
    end
end

local function gather_badges(universe_id)
	local all = {}
	local cursor = nil
	local tries = 0
	repeat
		tries = tries + 1
		local url = string.format(
			-- "https://badges.roblox.com/v1/universes/%s/badges?limit=100&sortOrder=Asc%s",
			'https://oxalyl.apis.wolf1te.com/roblox.com/badges/v1/universes/%s/badges?limit=100&sortOrder=Asc%s&wlft_auth=public-key-obbywiki-14-11-25-Vx9q7VCbM2Srn38LVDDhMk58GKf5bxD14KpPkS5XFzNEcM2FRHEaXNMbran621QySY0ueSUXZL5y4pTwjZ55nyyHhBTBuJ9BFnCAHzFLyPB3CfB9k9FGxBhAFST9qygnqtjd3PfUYtEEd4BRvhPpdQ25bLDjmjNhfucKqfE1DWJ2qkGuDubMSCGCqJGyLSFY5t2dpmTg4ij8viyCbu5dunfJfuZ71pCiz1ia4MUNBHdaPDSkg6wvWd9AJZGcHUT9&oxalyl_convert_int=true',
			tostring(universe_id),
			cursor and ("&cursor=" .. mw.uri.encode(cursor)) or ""
		)
		local json, err = fetch_json(url)
		if not json then return nil, err end
		if json.data then
			for _, b in ipairs(json.data) do
				all[#all+1] = {
					id = b.id,
					string_id = tostring(b.id),
					name = b.name or '',
					description = b.description or '',
					enabled = b.enabled == true,
					statistics = b.statistics or {
						awardedCount = 0,
						pastDayAwardedCount = 0,
						winRatePercentage = 0
					},
					created = b.created or '',
					updated = b.updated or ''
				}
			end
		end
		cursor = json.nextPageCursor
		if tries > 20 then break end
	until not cursor
	return all, nil
end

local function fetch_thumbnails(badges)
	if #badges == 0 then return {} end

	local map = {}
	local csv, n = {}, 0

	local function pull(ids_csv)
		local url = (
			-- 'https://thumbnails.roblox.com/v1/badges/icons?badgeIds=%s&size=150x150&format=Png&isCircular=false&returnPolicy=PlaceHolder'
			'https://oxalyl.apis.wolf1te.com/roblox.com/thumbnails/v1/badges/icons?badgeIds=%s&size=150x150&format=Png&isCircular=false&returnPolicy=PlaceHolder&wlft_auth=public-key-obbywiki-14-11-25-Vx9q7VCbM2Srn38LVDDhMk58GKf5bxD14KpPkS5XFzNEcM2FRHEaXNMbran621QySY0ueSUXZL5y4pTwjZ55nyyHhBTBuJ9BFnCAHzFLyPB3CfB9k9FGxBhAFST9qygnqtjd3PfUYtEEd4BRvhPpdQ25bLDjmjNhfucKqfE1DWJ2qkGuDubMSCGCqJGyLSFY5t2dpmTg4ij8viyCbu5dunfJfuZ71pCiz1ia4MUNBHdaPDSkg6wvWd9AJZGcHUT9&oxalyl_convert_int=true'
		)
			:format(ids_csv)
		local data, errs = ED.getExternalData{ url = url, cache = 3600 }
		if errs and #errs > 0 then return end

		local json = data and data.__json
		if not json or not json.data then return end

		for _, item in ipairs(json.data) do
			if item and item.targetId and item.imageUrl and item.state == "Completed" then
				map[item.targetId] = item.imageUrl
			end
		end
	end

	for i, b in ipairs(badges) do
		n = n + 1
		csv[n] = tostring(b.id)
		if n == 100 or i == #badges then
			pull(table.concat(csv, ","))
			csv, n = {}, 0
		end
	end
	return map
end




local function build_table(badges, thumb_map, icon_px, frame)
	local tbl = html.create("table")
		:addClass("wikitable sortable plainlinks")
		:addClass("mw-collapsible mw-made-collapsible wikitable--fluid")
		:css("width", "100%")

	local thead = tbl:tag("tr")
	thead:tag("th"):wikitext("Icon")
	thead:tag("th"):wikitext("Name")
	thead:tag("th"):wikitext("Description")
	thead:tag("th"):wikitext("Statistics")
	thead:tag("th"):wikitext("Created")
	thead:tag("th"):wikitext("Active")

	local lang = mw.getContentLanguage()

	for _, b in ipairs(badges) do
		local row = tbl:tag("tr")
		local img_url = thumb_map[b.id]
		local icon_cell = row:tag("td")
		if img_url then
			-- ??

			local s, image_output = pcall(function() 
				return frame:callParserFunction{
					name = '#eimage',
					args = { 
						img_url, 
						icon_px .. 'x' .. icon_px .. 'px',
						'link=https://www.roblox.com/badges/' .. (b.string_id or tostring(b.id or 0)) .. '/badge', -- side effect, citizen skin default image hover effects looks pretty bad with the link
						'caption=Badge'
					}
				}
			end)
			
			if s then
				icon_cell:tag("div")
					:css("text-align", "center")
					:wikitext(image_output)
			else
				icon_cell:wikitext('[' .. img_url .. ' image error]')
			end

			-- icon_cell:wikitext('{{#eimage:' .. mw.text.nowiki(img_url) .. '|' .. icon_px .. 'x' .. icon_px .. 'px|caption=Badge}}')

		else
			icon_cell:wikitext("N/A")
		end
		row:tag("td"):wikitext('[https://www.roblox.com/badges/' .. (b.string_id or tostring(b.id or 0)) .. '/badge ' .. b.name .. ']')
		row:tag("td"):wikitext(b.description ~= "" and b.description or "—")
		-- row:tag("td"):wikitext(b.statistics.awardedCount .. ' awarded, ' .. b.statistics.pastDayAwardedCount .. ' in past day, ' .. (b.statistics.winRatePercentage or 0) .. '% win rate')
		row:tag("td"):wikitext(string.format(
			-- '%d awarded<br/>%d in past day<br/>%.2f%% win rate',
			'%s (%d%% of) players have this badge<br/>%s awarded in the last 24 hours',

			lang:formatNum(tonumber(b.statistics.awardedCount or 0)),
			tonumber(b.statistics.winRatePercentage or 0)*100,
			lang:formatNum(tonumber(b.statistics.pastDayAwardedCount or 0))
		))
		row:tag("td"):wikitext(format_date_timestamp(b.created))
		row:tag("td"):wikitext(b.enabled and "✅ Yes" or "❌ No")
	end

	return tostring(tbl)
end

function p.render(frame)
	local args = frame:getParent() and frame:getParent().args or frame.args
	local universe_id = args.universe_id or args.universe or args.uid
	if not universe_id or universe_id == "" then
		return "Error: universe_id is required."
	end
	local show_disabled = tostring(args.show_disabled or "no"):lower() ~= "no"
	local icon_px = tonumber(args.icon_size) or 72

	local badges, err = gather_badges(universe_id)
	if not badges then
		return "Error fetching badges: " .. (err or "unknown")
	end

	if not show_disabled then
		local filtered = {}
		for _, b in ipairs(badges) do
			if b.enabled then filtered[#filtered+1] = b end
		end
		badges = filtered
	end

	-- table.sort(badges, function(a, b) return a.name:lower() < b.name:lower() end)

	local thumbs = fetch_thumbnails(badges) or {}

	return build_table(badges, thumbs, icon_px, frame)
end

return p
