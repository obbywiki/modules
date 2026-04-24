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

local function gather_passes(universe_id)
	local all = {}
	-- local cursor = nil
	-- local tries = 0
	-- repeat
		-- tries = tries + 1
		local url = string.format(
			-- "https://badges.roblox.com/v1/universes/%s/badges?limit=100&sortOrder=Asc%s",
			-- 'https://oxalyl.apis.wolf1te.com/roblox.com/badges/v1/universes/%s/badges?limit=100&sortOrder=Asc%s&wlft_auth=public-key-obbywiki-14-11-25-Vx9q7VCbM2Srn38LVDDhMk58GKf5bxD14KpPkS5XFzNEcM2FRHEaXNMbran621QySY0ueSUXZL5y4pTwjZ55nyyHhBTBuJ9BFnCAHzFLyPB3CfB9k9FGxBhAFST9qygnqtjd3PfUYtEEd4BRvhPpdQ25bLDjmjNhfucKqfE1DWJ2qkGuDubMSCGCqJGyLSFY5t2dpmTg4ij8viyCbu5dunfJfuZ71pCiz1ia4MUNBHdaPDSkg6wvWd9AJZGcHUT9&oxalyl_convert_int=true',
			'https://apis.roblox.com/game-passes/v1/universes/%s/game-passes?pageSize=50&passView=Full',
			tostring(universe_id)
			-- cursor and ("&cursor=" .. mw.uri.encode(cursor)) or ""
		)
		local json, err = fetch_json(url)
		if not json then return nil, err end
		if json.gamePasses then
			for _, g in ipairs(json.gamePasses) do
				all[#all+1] = {
					id = g.id,
					string_id = tostring(g.id),
					product_id = g.productId,
					name = g.name or '',
					description = g.displayDescription or g.description or '',
					is_for_sale = g.isForSale or false,
					price = g.price or 0,
					created = g.created or '',
					updated = g.updated or ''
				}
			end
		end
	-- 	cursor = json.nextPageCursor
	-- 	if tries > 20 then break end
	-- until not cursor
	return all, nil
end

local function fetch_thumbnails(passes)
	if #passes == 0 then return {} end

	local map = {}
	local csv, n = {}, 0

	local function pull(ids_csv)
		local url = (
			-- 'https://thumbnails.roblox.com/v1/badges/icons?badgeIds=%s&size=150x150&format=Png&isCircular=false&returnPolicy=PlaceHolder'
			-- 'https://oxalyl.apis.wolf1te.com/roblox.com/thumbnails/v1/badges/icons?badgeIds=%s&size=150x150&format=Png&isCircular=false&returnPolicy=PlaceHolder&wlft_auth=public-key-obbywiki-14-11-25-Vx9q7VCbM2Srn38LVDDhMk58GKf5bxD14KpPkS5XFzNEcM2FRHEaXNMbran621QySY0ueSUXZL5y4pTwjZ55nyyHhBTBuJ9BFnCAHzFLyPB3CfB9k9FGxBhAFST9qygnqtjd3PfUYtEEd4BRvhPpdQ25bLDjmjNhfucKqfE1DWJ2qkGuDubMSCGCqJGyLSFY5t2dpmTg4ij8viyCbu5dunfJfuZ71pCiz1ia4MUNBHdaPDSkg6wvWd9AJZGcHUT9&oxalyl_convert_int=true'
			'https://thumbnails.roblox.com/v1/game-passes?gamePassIds=%s&size=150x150&format=Webp&isCircular=false'
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

	for i, g in ipairs(passes) do
		n = n + 1
		csv[n] = tostring(g.id)
		if n == 100 or i == #passes then
			pull(table.concat(csv, ","))
			csv, n = {}, 0
		end
	end
	return map
end




local function build_table(passes, thumb_map, icon_px, frame)
	if #passes == 0 then
		local none = html.create("div")
		none:wikitext('This obby has no active/valid game-passes available.[[Category:Pages_with_no_passes]]')

		return tostring(none)
	end

	local tbl = html.create("table")
		:addClass("wikitable sortable plainlinks")
		:addClass("mw-collapsible mw-made-collapsible wikitable--fluid")
		:css("width", "100%")

	local thead = tbl:tag("tr")
	thead:tag("th"):wikitext("Icon")
	thead:tag("th"):wikitext("Name")
	thead:tag("th"):wikitext("Description")
	thead:tag("th"):wikitext("Price")
	thead:tag("th"):wikitext("Details")
	thead:tag("th"):wikitext("For Sale")

	-- local lang = mw.getContentLanguage()

	for _, g in ipairs(passes) do
		local row = tbl:tag("tr")
		local img_url = thumb_map[g.id]
		local icon_cell = row:tag("td")
		if img_url then
			local s, image_output = pcall(function() 
				return frame:callParserFunction{
					name = '#eimage',
					args = { 
						img_url, 
						icon_px .. 'x' .. icon_px .. 'px',
						'link=https://www.roblox.com/game-pass/' .. (g.string_id or tostring(g.id or 0)) .. '/pass', -- side effect, citizen skin default image hover effects looks pretty bad with the link
						'caption=GamePass'
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

		else
			icon_cell:wikitext("N/A")
		end
		row:tag("td"):wikitext('[https://www.roblox.com/game-pass/' .. (g.string_id or tostring(g.id or 0)) .. '/pass ' .. g.name .. ']')
		row:tag("td"):wikitext(g.description ~= "" and g.description or "—")
		row:tag("td"):wikitext(tostring(g.price) .. ' Robux')
		row:tag("td"):wikitext("'''Created:''' " .. format_date_timestamp(g.created) .. '<br/><br/> <code>' .. g.id .. '</code> - <code>' .. g.product_id .. '</code>' )
		row:tag("td"):wikitext(g.is_for_sale and "✅ For Sale" or "❌ Not For Sale")
	end

	return tostring(tbl)
end

function p.render(frame)
	local args = frame:getParent() and frame:getParent().args or frame.args
	local universe_id = args.universe_id or args.universe or args.uid or args.id
	if not universe_id or universe_id == '' then
		return "Error: universe_id is required.[[Category:Pages_with_missing_RobloxGamePasses_IDs]]"
	end
	if universe_id == '0' or universe_id == 0 then
		return "Placeholder. Please fill in the universe's ID in the RobloxGamePasses template.[[Category:Pages_with_missing_RobloxGamePasses_IDs]]"
	end
	if args.none == 'true' or args.none == true then
		return 'This obby has no active/valid game-passes available.'
	end

	local show_disabled = tostring(args.show_disabled or "no"):lower() ~= "no"
	local icon_px = tonumber(args.icon_size) or 72

	local passes, err = gather_passes(universe_id)
	if not passes then
		return "Error fetching badges: " .. (err or "unknown")
	end

	if not show_disabled then
		local filtered = {}
		for _, g in ipairs(passes) do
			if g.is_for_sale then filtered[#filtered+1] = g end
		end
		passes = filtered
	end

	-- table.sort(badges, function(a, b) return a.name:lower() < g.name:lower() end)

	local thumbs = fetch_thumbnails(passes) or {}

	return build_table(passes, thumbs, icon_px, frame)
end

return p
