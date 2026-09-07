local p = {}

-- PROTOTYPE

local ED = mw.ext.externalData
local aggrid = require('mw.ext.aggrid')

local DEFAULT_ICON_PX = 72
local ROW_PAD = 16
local MIN_ROW_HEIGHT = 48
local BADGE_HREF = 'https://www.roblox.com/badges/%s/badge'

local BADGES_URL = 'https://oxalyl.apis.wolf1te.com/roblox.com/badges/v1/universes/%s/badges?limit=100&sortOrder=Asc%s&wlft_auth=public-key-obbywiki-14-11-25-Vx9q7VCbM2Srn38LVDDhMk58GKf5bxD14KpPkS5XFzNEcM2FRHEaXNMbran621QySY0ueSUXZL5y4pTwjZ55nyyHhBTBuJ9BFnCAHzFLyPB3CfB9k9FGxBhAFST9qygnqtjd3PfUYtEEd4BRvhPpdQ25bLDjmjNhfucKqfE1DWJ2qkGuDubMSCGCqJGyLSFY5t2dpmTg4ij8viyCbu5dunfJfuZ71pCiz1ia4MUNBHdaPDSkg6wvWd9AJZGcHUT9&oxalyl_convert_int=true'
local THUMBS_URL = 'https://oxalyl.apis.wolf1te.com/roblox.com/thumbnails/v1/badges/icons?badgeIds=%s&size=150x150&format=Webp&isCircular=false&returnPolicy=PlaceHolder&wlft_auth=public-key-obbywiki-14-11-25-Vx9q7VCbM2Srn38LVDDhMk58GKf5bxD14KpPkS5XFzNEcM2FRHEaXNMbran621QySY0ueSUXZL5y4pTwjZ55nyyHhBTBuJ9BFnCAHzFLyPB3CfB9k9FGxBhAFST9qygnqtjd3PfUYtEEd4BRvhPpdQ25bLDjmjNhfucKqfE1DWJ2qkGuDubMSCGCqJGyLSFY5t2dpmTg4ij8viyCbu5dunfJfuZ71pCiz1ia4MUNBHdaPDSkg6wvWd9AJZGcHUT9&oxalyl_convert_int=true'

local function fetch_json(url)
	local data, errs = ED.getExternalData{ url = url }

	if errs and #errs > 0 then return nil, table.concat(errs, '; ') end
	if not data or not data.__json then return nil, 'no JSON' end

	return data.__json, nil
end

local function gather_badges(universe_id)
	local all = {}
	local cursor = nil
	local tries = 0

	repeat
		tries = tries + 1
		local url = string.format(
			BADGES_URL,
			tostring(universe_id),
			cursor and ('&cursor=' .. mw.uri.encode(cursor)) or ''
		)
		local json, err = fetch_json(url)

		if not json then return nil, err end

		if json.data then
			for _, b in ipairs(json.data) do
				all[#all + 1] = {
					id = b.id,
					string_id = tostring(b.id),
					name = b.name or '',
					description = b.description or '',
					enabled = b.enabled == true,
					statistics = b.statistics or {
						awardedCount = 0,
						pastDayAwardedCount = 0,
						winRatePercentage = 0,
					},
					created = b.created or '',
					updated = b.updated or '',
				}
			end
		end
		cursor = json.nextPageCursor

		if tries > 20 then break end

	until not cursor

	return all, nil
end

local function fetch_thumbnails(badges)
	if #badges == 0 then
		return {}
	end

	local map = {}
	local csv, n = {}, 0

	local function pull(ids_csv)
		local data, errs = ED.getExternalData{ url = THUMBS_URL:format(ids_csv), cache = 3600 }
		if errs and #errs > 0 then return end

		local json = data and data.__json
		if not json or not json.data then return end

		for _, item in ipairs(json.data) do
			if item and item.targetId and item.imageUrl and item.state == 'Completed' then
				map[item.targetId] = item.imageUrl
				map[tostring(item.targetId)] = item.imageUrl
			end
		end
	end

	for i, b in ipairs(badges) do
		n = n + 1
		csv[n] = tostring(b.id)

		if n == 100 or i == #badges then
			pull(table.concat(csv, ','))
			csv, n = {}, 0
		end
	end

	return map
end

local function iso_date(value)
	if type(value) ~= 'string' then return nil end

	local year, month, day = value:match('^(%d%d%d%d)%-(%d%d?)%-(%d%d?)')
	if not year then return nil end

	return string.format('%s-%02d-%02d', year, tonumber(month) or 1, tonumber(day) or 1)
end

local function thumb_src(thumb_map, badge)
	return thumb_map[badge.id] or thumb_map[badge.string_id] or thumb_map[tostring(badge.id)]
end

local function build_grid(badges, thumb_map, icon_px, frame)
	if #badges == 0 then
		return 'This obby has no active/obtainable badges available.[[Category:Pages_with_no_badges]]'
	end

	local rows = {}
	for _, b in ipairs(badges) do
		local href = BADGE_HREF:format(b.string_id or tostring(b.id or 0))
		local stats = b.statistics or {}
		local name_text = b.name ~= '' and b.name or (b.string_id or tostring(b.id))
		local src = thumb_src(thumb_map, b)
		local row = {
			name = { text = name_text, href = href },
			description = b.description ~= '' and b.description or nil,
			awarded = tonumber(stats.awardedCount) or 0,
			win_rate = (tonumber(stats.winRatePercentage) or 0) * 100,
			past_day = tonumber(stats.pastDayAwardedCount) or 0,
			created = iso_date(b.created),
			id = b.string_id or tostring(b.id),
			enabled = b.enabled and 'Yes' or 'No',
		}
		
		if src then
			row.icon = { src = src, width = icon_px, alt = name_text, href = href }
		end
		
		rows[#rows + 1] = row
	end

	local grid_options = {
		columnDefs = {
			aggrid.imageColumn({
				field = 'icon',
				header = 'Icon',
				sortable = false,
				width = icon_px + 24,
				suppressAutoSize = true,
			}),
			aggrid.linkColumn({
				field = 'name',
				header = 'Name',
				filter = 'agTextColumnFilter',
				flex = 1,
				minWidth = 160,
			}),
			{
				field = 'description',
				headerName = 'Description',
				filter = 'agTextColumnFilter',
				flex = 2,
				minWidth = 180,
			},
			{
				headerName = 'Statistics',
				children = {
					{
						field = 'awarded',
						headerName = 'Awarded',
						filter = 'agNumberColumnFilter',
						type = 'numericColumn',
						format = { style = 'number', useGrouping = true, decimals = 0 },
					},
					{
						field = 'win_rate',
						headerName = 'Win rate',
						filter = 'agNumberColumnFilter',
						type = 'numericColumn',
						format = { style = 'number', useGrouping = false, decimals = 1, suffix = '%' },
					},
					{
						field = 'past_day',
						headerName = 'Last 24h',
						filter = 'agNumberColumnFilter',
						type = 'numericColumn',
						format = { style = 'number', useGrouping = true, decimals = 0 },
					},
				},
			},
			{
				headerName = 'Details',
				children = {
					{
						field = 'created',
						headerName = 'Created',
						filter = 'agDateColumnFilter',
						cellDataType = 'dateString',
						format = { style = 'date', dateStyle = 'medium' },
					},
					{
						field = 'id',
						headerName = 'ID',
						filter = 'agTextColumnFilter',
					},
				},
			},
			{
				field = 'enabled',
				headerName = 'Active',
				filter = 'aggridSet',
				width = 110,
			},
		},
		rowData = rows,
		quickSearch = { placeholder = 'Find badges...' },
		expand = true,
		pagination = false,
		rowHeight = math.max(MIN_ROW_HEIGHT, icon_px + ROW_PAD),
		autoSizeStrategy = { type = 'fitCellContents' },
		defaultColDef = { sortable = true, resizable = true },
	}

	local styles = frame:extensionTag({
		name = 'templatestyles',
		args = { src = 'Module:RobloxBadgesV2/styles.css' },
	})

	return styles .. '<div class="t-robloxbadges">' .. aggrid.render(grid_options) .. '</div>'
end

function p.render(frame)
	local args = frame:getParent() and frame:getParent().args or frame.args
	local universe_id = args.universe_id or args.universe or args.uid or args.id
	if not universe_id or universe_id == '' then
		return 'Error: universe_id is required.'
	end

	if universe_id == '0' or universe_id == 0 or tonumber(universe_id) == nil then
		return "Placeholder. Please fill in the universe's ID in the RobloxBadges template.[[Category:Pages_with_missing_RobloxBadges_IDs]]"
	end

	if args.none == 'true' or args.none == true then
		return 'This obby has no active/obtainable badges available.'
	end

	local show_disabled = tostring(args.show_disabled or 'no'):lower() ~= 'no'
	local icon_px = tonumber(args.icon_size) or DEFAULT_ICON_PX

	local badges, err = gather_badges(universe_id)
	if not badges then
		return 'Error fetching badges: ' .. (err or 'unknown')
	end

	if not show_disabled then
		local filtered = {}

		for _, b in ipairs(badges) do
			if b.enabled then
				filtered[#filtered + 1] = b
			end
		end

		badges = filtered
	end

	local thumbs = fetch_thumbnails(badges) or {}

	return build_grid(badges, thumbs, icon_px, frame)
end

return p
