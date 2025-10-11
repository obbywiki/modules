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

local function gather_badges(universe_id)
	local all = {}
	local cursor = nil
	local tries = 0
	repeat
		tries = tries + 1
		local url = string.format(
			"https://badges.roblox.com/v1/universes/%s/badges?limit=100&sortOrder=Asc%s",
			tostring(universe_id),
			cursor and ("&cursor=" .. mw.uri.encode(cursor)) or ""
		)
		local json, err = fetch_json(url)
		if not json then return nil, err end
		if json.data then
			for _, b in ipairs(json.data) do
				all[#all+1] = {
					id = b.id,
					name = b.name or "",
					description = b.description or "",
					enabled = b.enabled == true
				}
			end
		end
		cursor = json.nextPageCursor
		if tries > 20 then break end
	until not cursor
	return all, nil
end

local function fetch_thumbnails(badges, icon_px)
	if #badges == 0 then return {} end
	
	local map = {}
	local batch, n = {}, 0
	for i, b in ipairs(badges) do
		n = n + 1
		batch[n] = tostring(b.id)
		if n == 100 or i == #badges then
			local url = ('https://thumbnails.roblox.com/v1/badges/icons?badgeIds=%s&size=150x150&format=Png&isCircular=false&returnPolicy=PlaceHolder')
				:format(table.concat(batch, ','))
			local json = ED.getExternalData{ url = url, cache = 3600 } -- is cache even a field?
			if json and json.__json and json.__json.data then
				for _, item in ipairs(json.__json.data) do
					if item.state == 'Completed' or item.imageUrl then
						map[tonumber(item.targetId)] = item.imageUrl
					end
				end
			end
			batch, n = {}, 0
		end
	end
	return map
end


local function build_table(badges, thumb_map, icon_px)
	local tbl = html.create("table")
		:addClass("wikitable sortable plainlinks")
		:addClass("mw-collapsible mw-made-collapsible")
		:css("width", "100%")

	local thead = tbl:tag("tr")
	thead:tag("th"):wikitext("Icon")
	thead:tag("th"):wikitext("Name")
	thead:tag("th"):wikitext("Description")
	thead:tag("th"):wikitext("Enabled")

	for _, b in ipairs(badges) do
		local row = tbl:tag("tr")
		local img_url = thumb_map[b.id]
		local icon_cell = row:tag("td")
		if img_url then
			icon_cell:tag("img")
				:attr("src", img_url)
				:attr("alt", b.name)
				:attr("loading", "lazy")
				:cssText(string.format("width:%dpx;height:%dpx;object-fit:contain", icon_px, icon_px))
		else
			icon_cell:wikitext("—")
		end
		row:tag("td"):wikitext(b.name)
		row:tag("td"):wikitext(b.description ~= "" and b.description or "—")
		row:tag("td"):wikitext(b.enabled and "Yes" or "No")
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
	local icon_px = tonumber(args.icon_size) or 150

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

	table.sort(badges, function(a, b) return a.name:lower() < b.name:lower() end)

	local thumbs = fetch_thumbnails(badges, icon_px) or {}

	return build_table(badges, thumbs, icon_px)
end

return p
