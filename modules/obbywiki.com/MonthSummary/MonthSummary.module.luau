local p = {}

local months_full = {
	'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December',
}

local PLACEHOLDER_THUMB = 'Standard11placeholder.webp'

local function get_comma_val(num)
	local formatted = tostring(num or 0)
	while true do
		local k
		formatted, k = string.gsub(formatted, '^(-?%d+)(%d%d%d)', '%1,%2')
		if k == 0 then
			break
		end
	end
	return formatted
end

local function ordinal(day)
	local n = tonumber(day)
	if not n then
		return ''
	end
	local mod100 = n % 100
	if mod100 >= 11 and mod100 <= 13 then
		return n .. 'th'
	end
	local mod10 = n % 10
	if mod10 == 1 then
		return n .. 'st'
	elseif mod10 == 2 then
		return n .. 'nd'
	elseif mod10 == 3 then
		return n .. 'rd'
	end
	return n .. 'th'
end

local function normalize_thumbnail(thumbnail)
	if type(thumbnail) ~= 'string' or thumbnail == '' then
		return PLACEHOLDER_THUMB
	end
	local parts = mw.text.split(thumbnail, ':', true)
	if #parts > 1 then
		table.remove(parts, 1)
		return table.concat(parts, ':')
	end
	return thumbnail
end

local function query_month_obbies(target_year, month_name)
	local month_index = table.find(months_full, month_name)
	return mw.ext.cargo.query(
		'Obbies',
		'_pageName=name, visits, subgenre, creator, day, thumbnail',
		{
			where = "month='" .. tostring(month_index) .. "' AND year='" .. target_year .. "'",
			orderBy = 'visits DESC',
			limit = 500,
		}
	)
end

local function aggregate_month(month_data)
	local by_subgenre = {}
	local by_creator = {}
	local total_visits = 0
	local most_popular = { name = '', visits = 0, creator = '', day = 0, thumbnail = '' }
	local top_three = {}

	for _, row in ipairs(month_data) do
		local visits = tonumber(row.visits) or 0
		total_visits += visits

		if #top_three < 3 then
			table.insert(top_three, {
				name = row.name,
				visits = visits,
				creator = row.creator or '',
				day = tonumber(row.day) or 0,
				thumbnail = row.thumbnail or '',
			})
		end

		if row.subgenre and row.subgenre ~= '' then
			local entry = by_subgenre[row.subgenre]
			if entry then
				entry.count += 1
				entry.visits += visits
				if visits > entry.mpo_visits then
					entry.mpo_visits = visits
					entry.mpo = row.name
				end
			else
				by_subgenre[row.subgenre] = {
					count = 1,
					visits = visits,
					mpo_visits = visits,
					mpo = row.name,
				}
			end
		end

		if row.creator and row.creator ~= '' then
			local creator_entry = by_creator[row.creator]
			if creator_entry then
				creator_entry.count += 1
				creator_entry.visits += visits
			else
				by_creator[row.creator] = { count = 1, visits = visits }
			end
		end

		if row.name and visits > most_popular.visits then
			most_popular = {
				name = row.name,
				visits = visits,
				creator = row.creator or '',
				day = tonumber(row.day) or 0,
				thumbnail = row.thumbnail or '',
			}
		end
	end

	local top_subgenre = nil
	local most_visited_subgenre = nil
	local subgenre_count = 0

	for name, entry in pairs(by_subgenre) do
		subgenre_count += 1
		if not top_subgenre or entry.count > top_subgenre.count then
			top_subgenre = { name = name, count = entry.count }
		end
		if not most_visited_subgenre or entry.visits > most_visited_subgenre.visits then
			most_visited_subgenre = { name = name, visits = entry.visits }
		end
	end

	local creator_list = {}
	for name, entry in pairs(by_creator) do
		table.insert(creator_list, {
			name = name,
			count = entry.count,
			visits = entry.visits,
		})
	end

	table.sort(creator_list, function(a, b)
		if a.count ~= b.count then
			return a.count > b.count
		end
		return a.visits > b.visits
	end)

	local top_creators = {}
	local has_repeats = false
	for _, creator in ipairs(creator_list) do
		if creator.count >= 2 then
			has_repeats = true
			break
		end
	end

	if has_repeats then
		for _, creator in ipairs(creator_list) do
			if creator.count >= 2 and #top_creators < 3 then
				table.insert(top_creators, creator)
			end
		end
	elseif #creator_list > 0 then
		table.insert(top_creators, creator_list[1])
	end

	return {
		release_count = #month_data,
		total_visits = total_visits,
		most_popular = most_popular,
		by_subgenre = by_subgenre,
		top_subgenre = top_subgenre,
		most_visited_subgenre = most_visited_subgenre,
		subgenre_count = subgenre_count,
		top_creators = top_creators,
		top_three = top_three,
	}
end

local function render_stat_cards(stats)
	local grid = mw.html.create('div'):addClass('ow-month-summary__stats')

	local function add_stat(label, value, sub)
		local card = grid:tag('div'):addClass('ow-month-summary__stat')
		card:tag('div'):addClass('ow-month-summary__stat-value'):wikitext(value)
		card:tag('div'):addClass('ow-month-summary__stat-label'):wikitext(label)
		if sub and sub ~= '' then
			card:tag('div'):addClass('ow-month-summary__stat-sub'):wikitext(sub)
		end
	end

	add_stat('Obbies released', tostring(stats.release_count))
	add_stat('Total visits', get_comma_val(stats.total_visits))

	if stats.top_subgenre then
		add_stat(
			'Top sub-genre',
			`[[{stats.top_subgenre.name}]]`,
			`{stats.top_subgenre.count} release{stats.top_subgenre.count == 1 and '' or 's'}`
		)
	else
		add_stat('Top sub-genre', '—')
	end

	local popular = stats.most_popular
	if popular.name ~= '' then
		add_stat(
			'Most popular',
			`[[{popular.name}]]`,
			`{get_comma_val(popular.visits)} visits`
		)
	else
		add_stat('Most popular', '—')
	end

	return grid
end

local function render_top_releases(top_three)
	if not top_three or #top_three == 0 then
		return nil
	end

	local section = mw.html.create('div'):addClass('ow-month-summary__section')
	section:tag('div'):addClass('ow-month-summary__section-title'):wikitext('Top releases')

	local grid = section:tag('div'):addClass('ow-month-summary__top')

	for i, obby in ipairs(top_three) do
		local card = grid:tag('div'):addClass('ow-month-summary__release')
		card:tag('div'):addClass('ow-month-summary__release-rank'):wikitext(tostring(i))

		local thumb_name = normalize_thumbnail(obby.thumbnail)
		card:tag('div')
			:addClass('ow-month-summary__release-thumb')
			:wikitext(`[[File:{thumb_name}|320px|alt={obby.name}|link=]]`)

		local meta = card:tag('div'):addClass('ow-month-summary__release-meta')
		meta:tag('div'):addClass('ow-month-summary__release-title'):wikitext(obby.name)

		if obby.creator and obby.creator ~= '' then
			meta:tag('div')
				:addClass('ow-month-summary__release-creator')
				:wikitext('by ' .. obby.creator)
		end

		meta:tag('div')
			:addClass('ow-month-summary__release-visits')
			:wikitext(`{get_comma_val(obby.visits)} visits`)

		card:tag('span')
			:addClass('ow-month-summary__release-link')
			:wikitext(`[[{obby.name}]]`)
	end

	return section
end

local function render_top_creators(top_creators)
	if not top_creators or #top_creators == 0 then
		return nil
	end

	local section = mw.html.create('div'):addClass('ow-month-summary__section')
	section:tag('div'):addClass('ow-month-summary__section-title'):wikitext('Most active creators')

	local grid = section:tag('div'):addClass('ow-month-summary__creators')

	for _, creator in ipairs(top_creators) do
		local card = grid:tag('div'):addClass('ow-month-summary__creator')
		card:tag('div'):addClass('ow-month-summary__creator-name'):wikitext(creator.name)
		card:tag('div')
			:addClass('ow-month-summary__creator-count')
			:wikitext(
				`{creator.count} release{creator.count == 1 and '' or 's'} · {get_comma_val(creator.visits)} visits`
			)
		card:tag('span')
			:addClass('ow-month-summary__creator-link')
			:wikitext(`[[{creator.name}]]`)
	end

	return section
end

local function render_subgenre_table(by_subgenre, stats, month_name, target_year)
	local section = mw.html.create('div'):addClass('ow-month-summary__section')
	section:tag('div'):addClass('ow-month-summary__section-title'):wikitext('Releases by sub-genre')

	local intro_parts = {}
	if stats.subgenre_count > 0 and stats.top_subgenre then
		local genre_word = stats.subgenre_count == 1 and 'sub-genre' or 'sub-genres'
		table.insert(
			intro_parts,
			`{stats.subgenre_count} {genre_word} this month; most frequent was [[{stats.top_subgenre.name}]] ({stats.top_subgenre.count}).`
		)
		if stats.most_visited_subgenre then
			local same = stats.top_subgenre.name == stats.most_visited_subgenre.name
			table.insert(
				intro_parts,
				`Most visited was {same and 'also ' or ''}[[{stats.most_visited_subgenre.name}]] ({get_comma_val(stats.most_visited_subgenre.visits)} visits).`
			)
		end
	else
		table.insert(intro_parts, `No sub-genre breakdown available for {month_name} {target_year}.`)
	end

	section:tag('p')
		:addClass('ow-month-summary__section-intro')
		:wikitext(table.concat(intro_parts, ' '))

	local table_el = mw.html.create('table')
		:addClass('wikitable sortable plainlinks')
		:addClass('mw-collapsible mw-made-collapsible wikitable--fluid')
		:addClass('ow-month-summary__table')

	local header = table_el:tag('tr')
	header:tag('th'):wikitext('Sub-genre')
	header:tag('th'):wikitext('Total')
	header:tag('th'):wikitext('Visits')
	header:tag('th'):wikitext('Most popular obby')

	for name, entry in pairs(by_subgenre) do
		local row = table_el:tag('tr')
		row:tag('td'):wikitext(`[[{name}]]`)
		row:tag('td'):wikitext(tostring(entry.count))
		row:tag('td'):wikitext(get_comma_val(entry.visits))
		row:tag('td'):wikitext(`[[{entry.mpo}]] ({get_comma_val(entry.mpo_visits)} visits)`)
	end

	section:node(table_el)
	return section
end

function p.draw(frame)
	local args = frame:getParent().args
	local target_year = args[1] or os.date('%Y')
	local current_month_name = args[2] or ''

	if not target_year or not current_month_name or not table.find(months_full, current_month_name) then
		return 'Error: Either an invalid year or an invalid month was provided to the MonthSummary template.'
	end

	if not mw.ext.cargo or not mw.ext.cargo.query then
		return 'Error'
	end

	local month_data = query_month_obbies(target_year, current_month_name)

	if not month_data or #month_data == 0 then
		return 'No relevant data for this month to display.'
	end

	local stats = aggregate_month(month_data)
	local styles = frame:extensionTag('templatestyles', '', {
		src = 'Template:MonthSummary/styles.css',
	})

	local root = mw.html.create('div'):addClass('ow-month-summary')
	root:node(render_stat_cards(stats))

	local top_releases = render_top_releases(stats.top_three)
	if top_releases then
		root:node(top_releases)
	end

	local top_creators = render_top_creators(stats.top_creators)
	if top_creators then
		root:node(top_creators)
	end

	root:node(render_subgenre_table(
		stats.by_subgenre,
		stats,
		current_month_name,
		target_year
	))

	local popular = stats.most_popular
	local day_note = ''
	if popular.day ~= 0 then
		day_note = `, released on the {ordinal(popular.day)} of {current_month_name}`
	end

	local summary_line = `There {stats.release_count == 1 and 'was' or 'were'} '''{stats.release_count}''' {stats.release_count == 1 and 'obby' or 'obbies'} released in {current_month_name} of {target_year}`
	if popular.name ~= '' then
		summary_line ..= `, led by [[{popular.name}]] by [[{popular.creator}]] with '''{get_comma_val(popular.visits)} visits'''{day_note}`
	end
	summary_line ..= '.'

	return styles .. `=Summary=\n\n{summary_line}\n\n` .. tostring(root)
end

return p
