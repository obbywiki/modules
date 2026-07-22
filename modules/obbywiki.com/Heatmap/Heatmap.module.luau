local p = {}

local FloatingUI = require('Module:FloatingUI')

local months_full = {
	'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December',
}

local weekday_labels = { 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat' }

local METRICS = {
	releases = function(_row)
		return 1
	end,
	-- visits = function(row)
	-- 	return tonumber(row.visits) or 0
	-- end,
}

local function cargo_escape(value)
	return tostring(value or ''):gsub("'", "''")
end

local function days_in_month(year, month)
	local lengths = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
	if month == 2 then
		if (year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0) then
			return 29
		end
	end
	return lengths[month]
end

local function date_key(year, month, day)
	return string.format('%04d-%02d-%02d', year, month, day)
end

local function to_timestamp(year, month, day)
	return os.time({ year = year, month = month, day = day, hour = 12 })
end

local function from_timestamp(ts)
	local t = os.date('*t', ts)
	return t.year, t.month, t.day, t.wday
end

-- lua wday: 1=Sunday ... 7=Saturday -> 0=Sunday ... 6=Saturday
local function weekday_index(year, month, day)
	local _, _, _, wday = from_timestamp(to_timestamp(year, month, day))
	return wday - 1
end

local function add_days(year, month, day, delta)
	local ts = to_timestamp(year, month, day) + (delta * 86400)
	local y, m, d = from_timestamp(ts)
	return y, m, d
end

local function compare_dates(y1, m1, d1, y2, m2, d2)
	if y1 ~= y2 then
		return y1 < y2 and -1 or 1
	end
	if m1 ~= m2 then
		return m1 < m2 and -1 or 1
	end
	if d1 ~= d2 then
		return d1 < d2 and -1 or 1
	end
	return 0
end

local function resolve_month(raw)
	if not raw or raw == '' then
		return nil, nil
	end

	local as_num = tonumber(raw)
	if as_num and as_num >= 1 and as_num <= 12 then
		return as_num, months_full[as_num]
	end

	local trimmed = mw.text.trim(tostring(raw))
	for i, name in ipairs(months_full) do
		if string.lower(name) == string.lower(trimmed) then
			return i, name
		end
	end

	return nil, nil
end

local function resolve_range(scope, year_arg, month_arg, context)
	local today = os.date('*t')
	local end_y, end_m, end_d = today.year, today.month, today.day

	if scope == 'last' then
		local start_y, start_m, start_d = add_days(end_y, end_m, end_d, -364)
		return {
			start_y = start_y,
			start_m = start_m,
			start_d = start_d,
			end_y = end_y,
			end_m = end_m,
			end_d = end_d,
			label = 'Last 365 days',
		}
	end

	local year = tonumber(year_arg) or today.year

	if scope == 'month' then
		local month_index, month_name = resolve_month(month_arg)
		if not month_index then
			return nil, 'Heatmap: month scope requires a valid month (name or 1-12).'
		end

		local label = month_name .. ' ' .. tostring(year)

		-- Full-year canvas with the selected month in focus
		if context == 'year' then
			return {
				start_y = year,
				start_m = 1,
				start_d = 1,
				end_y = year,
				end_m = 12,
				end_d = 31,
				label = label,
				focus_year = year,
				focus_month = month_index,
			}
		end

		local dim = days_in_month(year, month_index)
		return {
			start_y = year,
			start_m = month_index,
			start_d = 1,
			end_y = year,
			end_m = month_index,
			end_d = dim,
			label = label,
			focus_year = year,
			focus_month = month_index,
		}
	end

	-- scope == 'year'
	return {
		start_y = year,
		start_m = 1,
		start_d = 1,
		end_y = year,
		end_m = 12,
		end_d = 31,
		label = tostring(year),
	}
end

local function normalize_developer(raw, force_user)
	if not raw or raw == '' then
		return nil
	end

	local trimmed = mw.text.trim(tostring(raw))
	if trimmed == '' then
		return nil
	end

	if force_user and string.sub(trimmed, 1, 1) ~= '@' then
		return '@' .. trimmed
	end

	return trimmed
end

local function build_developer_clause(developer)
	local escaped = cargo_escape(developer)
	local is_user = string.sub(developer, 1, 1) == '@'

	if is_user then
		-- developed (list) or sole creator when developers list is empty / omits them
		return "(developers HOLDS '"
			.. escaped
			.. "' OR creator='"
			.. escaped
			.. "')"
	end

	-- studio / brand pages credit via creator
	return "creator='" .. escaped .. "'"
end

local function build_where(scope, range, context, developer)
	local date_where

	if scope == 'month' and context ~= 'year' then
		date_where = "year='"
			.. cargo_escape(range.start_y)
			.. "' AND month='"
			.. cargo_escape(range.start_m)
			.. "'"
	elseif scope == 'year' or (scope == 'month' and context == 'year') then
		local year = range.focus_year or range.start_y
		date_where = "year='" .. cargo_escape(year) .. "'"
	else
		-- last: pull spanning calendar years, filter in Lua
		date_where = "year>='"
			.. cargo_escape(range.start_y)
			.. "' AND year<='"
			.. cargo_escape(range.end_y)
			.. "'"
	end

	if developer then
		return date_where .. ' AND ' .. build_developer_clause(developer)
	end

	return date_where
end

local function query_obbies(where)
	if not mw.ext.cargo or not mw.ext.cargo.query then
		return nil, 'Heatmap: Cargo is unavailable.'
	end

	local rows = mw.ext.cargo.query('Obbies', '_pageName=name, day, month, year', {
		where = where,
		limit = 2000,
	})

	return rows or {}
end

local function in_range(y, m, d, range)
	if compare_dates(y, m, d, range.start_y, range.start_m, range.start_d) < 0 then
		return false
	end
	if compare_dates(y, m, d, range.end_y, range.end_m, range.end_d) > 0 then
		return false
	end
	return true
end

local function bucket_counts(rows, range, metric_fn)
	local counts = {}
	local names_by_day = {}
	local total = 0
	local focus_total = 0
	local has_focus = range.focus_month ~= nil

	for _, row in ipairs(rows) do
		local y = tonumber(row.year)
		local m = tonumber(row.month)
		local d = tonumber(row.day)
		if y and m and d and d > 0 and m >= 1 and m <= 12 then
			if in_range(y, m, d, range) then
				local key = date_key(y, m, d)
				local amount = metric_fn(row) or 0
				if amount > 0 then
					counts[key] = (counts[key] or 0) + amount
					total += amount
					if has_focus and y == range.focus_year and m == range.focus_month then
						focus_total += amount
					end

					local page_name = row.name
					if type(page_name) == 'string' and page_name ~= '' then
						local day_names = names_by_day[key]
						if not day_names then
							day_names = {}
							names_by_day[key] = day_names
						end
						table.insert(day_names, page_name)
					end
				end
			end
		end
	end

	if has_focus then
		return counts, focus_total, names_by_day
	end
	return counts, total, names_by_day
end

local function is_focus_day(day, range)
	if not range.focus_month then
		return true
	end
	return day.year == range.focus_year and day.month == range.focus_month
end

local function max_count(counts)
	local max_n = 0
	for _, n in pairs(counts) do
		if n > max_n then
			max_n = n
		end
	end
	return max_n
end

local function intensity_level(count, max_n)
	if count == 0 or max_n == 0 then
		return 0
	end
	local step = max_n / 4
	if count <= step then
		return 1
	elseif count <= step * 2 then
		return 2
	elseif count <= step * 3 then
		return 3
	end
	return 4
end

local MAX_TOOLTIP_LINKS = 12

local function format_day_tooltip(count, year, month, day, mode, names)
	local month_name = months_full[month] or tostring(month)
	local noun
	if mode == 'releases' then
		noun = count == 1 and 'release' or 'releases'
	else
		noun = mode
	end

	local heading = tostring(count)
		.. ' '
		.. noun
		.. ' on '
		.. month_name
		.. ' '
		.. tostring(day)
		.. ', '
		.. tostring(year)

	if not names or #names == 0 then
		return heading
	end

	-- Stable order; keep tip short so FloatingUI stays light on busy days
	table.sort(names)
	local lines = { "'''" .. heading .. "'''" }
	local shown = math.min(#names, MAX_TOOLTIP_LINKS)
	for i = 1, shown do
		table.insert(lines, '* [[' .. names[i] .. ']]')
	end
	if #names > MAX_TOOLTIP_LINKS then
		table.insert(lines, '* …and ' .. tostring(#names - MAX_TOOLTIP_LINKS) .. ' more')
	end

	return table.concat(lines, '\n')
end

local function build_day_list(range)
	local days = {}
	local y, m, d = range.start_y, range.start_m, range.start_d
	while compare_dates(y, m, d, range.end_y, range.end_m, range.end_d) <= 0 do
		table.insert(days, { year = y, month = m, day = d, key = date_key(y, m, d) })
		y, m, d = add_days(y, m, d, 1)
	end
	return days
end

local FILLER_WEEKS = 32

local function append_side_filler(parent, side)
	local filler = parent:tag('div')
		:addClass('ow-heatmap__filler')
		:addClass('ow-heatmap__filler--' .. side)

	for _ = 1, FILLER_WEEKS * 7 do
		filler:tag('div')
			:addClass('ow-heatmap__cell')
			:addClass('ow-heatmap__cell--dummy')
	end

	return filler
end

local function append_pad_cell(grid)
	grid:tag('div')
		:addClass('ow-heatmap__day')
		:addClass('ow-heatmap__day--pad')
		:tag('div')
		:addClass('ow-heatmap__cell')
		:addClass('ow-heatmap__cell--dummy')
end

local function render_heatmap(range, counts, total, mode, developer, names_by_day)
	local max_n = max_count(counts)
	local day_list = build_day_list(range)
	local start_pad = weekday_index(range.start_y, range.start_m, range.start_d)
	local has_focus = range.focus_month ~= nil
		and (range.start_m ~= range.focus_month or range.end_m ~= range.focus_month)

	local root = mw.html.create('div'):addClass('ow-heatmap')
	if has_focus then
		root:addClass('ow-heatmap--month-focus')
	end
	if developer then
		root:addClass('ow-heatmap--developer')
	end

	local caption_noun = 'releases'
	if mode == 'releases' then
		caption_noun = total == 1 and 'release' or 'releases'
	else
		caption_noun = mode
	end

	local caption = tostring(total) .. ' ' .. caption_noun .. ' · ' .. range.label
	if developer then
		caption ..= ' · [[' .. developer .. ']]'
	end

	root:tag('div')
		:addClass('ow-heatmap__caption')
		:wikitext(caption)

	local scroll = root:tag('div'):addClass('ow-heatmap__scroll')
	local calendar = scroll:tag('div'):addClass('ow-heatmap__calendar')

	-- month labels: spacer | filler | track | filler
	local months_row = calendar:tag('div'):addClass('ow-heatmap__months')
	months_row:tag('div'):addClass('ow-heatmap__months-spacer')
	months_row:tag('div')
		:addClass('ow-heatmap__filler')
		:addClass('ow-heatmap__filler--start')
	local months_track = months_row:tag('div'):addClass('ow-heatmap__months-track')
	months_row:tag('div')
		:addClass('ow-heatmap__filler')
		:addClass('ow-heatmap__filler--end')

	-- body: weekdays | filler | grid | filler
	local body = calendar:tag('div'):addClass('ow-heatmap__body')

	local labels = body:tag('div'):addClass('ow-heatmap__weekdays')
	for i, label in ipairs(weekday_labels) do
		-- only show Mon, Wed, Fri
		local show = (i == 2 or i == 4 or i == 6)
		labels:tag('div')
			:addClass('ow-heatmap__weekday')
			:wikitext(show and label or '')
	end

	append_side_filler(body, 'start')

	local grid = body:tag('div'):addClass('ow-heatmap__grid')

	append_side_filler(body, 'end')

	-- leading pads (before first day) — visible dummies, not holes
	for _ = 1, start_pad do
		append_pad_cell(grid)
	end

	local week_count = 0
	local cells_placed = start_pad
	local last_month_label = nil
	local month_labels = {} -- { week_index, label, month }

	for _, day in ipairs(day_list) do
		local count = counts[day.key] or 0
		local level = intensity_level(count, max_n)
		local week_index = math.floor(cells_placed / 7)
		local focused = is_focus_day(day, range)

		if day.month ~= last_month_label then
			last_month_label = day.month

			-- place label on this week if not already labeled for this month nearby
			local month_name = string.sub(months_full[day.month] or '', 1, 3)
			local should_add = true

			if #month_labels > 0 then
				local prev = month_labels[#month_labels]
				if prev.week == week_index then
					should_add = false
				end
			end

			if should_add then
				table.insert(month_labels, {
					week = week_index,
					label = month_name,
					month = day.month,
				})
			end
		end

		local cell = mw.html.create('div')
			:addClass('ow-heatmap__cell')
			:addClass('ow-heatmap__cell--l' .. tostring(level))

		if count > 0 then
			cell:addClass('ow-heatmap__cell--has-data')
		end

		local day_el = grid:tag('div'):addClass('ow-heatmap__day')
		if has_focus and not focused then
			day_el:addClass('ow-heatmap__day--dimmed')
		elseif has_focus and focused then
			day_el:addClass('ow-heatmap__day--focus')
		end

		-- Only attach FloatingUI when there is data — empty days were flooding the DOM
		if count > 0 then
			local tooltip = format_day_tooltip(
				count,
				day.year,
				day.month,
				day.day,
				mode,
				names_by_day and names_by_day[day.key]
			)
			day_el:wikitext(FloatingUI.render(tostring(cell), tooltip))
		else
			day_el:node(cell)
		end

		cells_placed += 1
		week_count = math.max(week_count, week_index + 1)
	end

	-- trailing pads to complete the last week column
	local trailing = (7 - (cells_placed % 7)) % 7
	for _ = 1, trailing do
		append_pad_cell(grid)
	end

	if trailing > 0 then
		week_count = math.max(week_count, math.floor((cells_placed + trailing - 1) / 7) + 1)
	end

	grid:css('grid-template-columns', 'repeat(' .. tostring(week_count) .. ', var(--ow-heatmap-cell-size))')

	-- render month labels into track with column offsets
	local label_index = 1
	for w = 0, week_count - 1 do
		local slot = months_track:tag('div'):addClass('ow-heatmap__month')
		if label_index <= #month_labels and month_labels[label_index].week == w then
			local entry = month_labels[label_index]
			if has_focus then
				if entry.month == range.focus_month then
					slot:addClass('ow-heatmap__month--focus')
				else
					slot:addClass('ow-heatmap__month--dimmed')
				end
			end
			slot:wikitext(entry.label)
			label_index += 1
		end
	end
	months_track:css('grid-template-columns', 'repeat(' .. tostring(week_count) .. ', var(--ow-heatmap-cell-size))')

	local legend = root:tag('div'):addClass('ow-heatmap__legend')
	legend:tag('span'):addClass('ow-heatmap__legend-label'):wikitext('Less')
	for level = 0, 4 do
		legend:tag('div')
			:addClass('ow-heatmap__cell')
			:addClass('ow-heatmap__cell--l' .. tostring(level))
			:addClass('ow-heatmap__legend-swatch')
	end
	legend:tag('span'):addClass('ow-heatmap__legend-label'):wikitext('More')

	return root
end

function p.draw(frame)
	local args = frame:getParent().args
	local scope = string.lower(mw.text.trim(args.scope or 'last'))
	local mode = string.lower(mw.text.trim(args.mode or 'releases'))
	local context = string.lower(mw.text.trim(args.context or ''))
	local year_arg = args.year
	local month_arg = args.month
	local developer
	if args.player and mw.text.trim(tostring(args.player)) ~= '' then
		developer = normalize_developer(args.player, true)
	else
		developer = normalize_developer(args.developer or args.creator, false)
	end

	if scope ~= 'year' and scope ~= 'month' and scope ~= 'last' then
		return 'Heatmap: scope must be year, month, or last.'
	end

	if context ~= '' and context ~= 'year' then
		return 'Heatmap: context must be year when set.'
	end

	if context == 'year' and scope ~= 'month' then
		return 'Heatmap: context=year is only valid with scope=month.'
	end

	local metric_fn = METRICS[mode]
	if not metric_fn then
		return 'Heatmap: unknown mode "' .. mode .. '". Supported: releases.'
	end

	if scope == 'month' and (not month_arg or month_arg == '') then
		return 'Heatmap: month scope requires a month parameter.'
	end

	local range, range_err = resolve_range(scope, year_arg, month_arg, context)
	if not range then
		return range_err
	end

	local rows, query_err = query_obbies(build_where(scope, range, context, developer))
	if not rows then
		return query_err
	end

	local counts, total, names_by_day = bucket_counts(rows, range, metric_fn)
	local root = render_heatmap(range, counts, total, mode, developer, names_by_day)

	local styles = frame:extensionTag('templatestyles', '', {
		src = 'Template:Heatmap/styles.css',
	})

	return FloatingUI.load(frame) .. styles .. tostring(root)
end

return p
