-- THIS MODULE IS CURRENTLY BEING DRAFTED ON A LOCAL WIKI, AS SUCH ONLY USE LUA 5.1 COMPATIBLE SYNTAX

local p = {}

local get_args = require('Module:Arguments').getArgs
local yesno = require('Module:Yesno')
local FloatingUI = require('Module:FloatingUI')

local SEVERITY_ALIASES = {
	required = 'required',
	red = 'required',
	['1'] = 'required',
	must = 'required',
	recommended = 'recommended',
	high = 'recommended',
	yellow = 'recommended',
	['2'] = 'recommended',
	nice = 'nice',
	green = 'nice',
	['3'] = 'nice',
	optional = 'nice',
	preference = 'preference',
	unmarked = 'preference',
	white = 'preference',
	gray = 'preference',
	grey = 'preference',
	['4'] = 'preference',
	none = 'preference',
}

local SEVERITY_LABELS = {
	required = 'Required',
	recommended = 'Highly recommended',
	nice = 'Nice to have',
	preference = 'Preferences',
}

local LEGEND_ITEMS = {
	{
		id = 'required',
		title = 'Required',
		body = 'You must follow this guideline.',
	},
	{
		id = 'recommended',
		title = 'Highly recommended',
		body = 'You are encouraged to follow this guideline or edit any pages that don\'t.',
	},
	{
		id = 'nice',
		title = 'Nice to have',
		body = 'You should follow this if you can.',
	},
	{
		id = 'preference',
		title = 'Unmarked/Preference',
		body = 'It is up to you.',
	},
}

local SCOPE_ORDER = {
	'content',
	'blog',
	'talk',
	'docs',
}

local SCOPE_META = {
	content = {
		letter = 'C',
		label = 'Content pages',
		hint = 'Mainspace articles and other content pages.',
	},
	blog = {
		letter = 'B',
		label = 'Blogs',
		hint = 'Blog posts.',
	},
	talk = {
		letter = 'T',
		label = 'Talk & comments',
		hint = 'Talk pages, comments, and other discussion.',
	},
	docs = {
		letter = 'D',
		label = 'Docs',
		hint = 'Project, help, and documentation pages.',
	},
}

local SCOPE_ALIASES = {
	content = 'content',
	contents = 'content',
	page = 'content',
	pages = 'content',
	article = 'content',
	articles = 'content',
	main = 'content',
	mainspace = 'content',
	blog = 'blog',
	blogs = 'blog',
	talk = 'talk',
	talks = 'talk',
	['talk pages'] = 'talk',
	['talk page'] = 'talk',
	comment = 'talk',
	comments = 'talk',
	discussion = 'talk',
	discussions = 'talk',
	['talk pages and comments'] = 'talk',
	['talk & comments'] = 'talk',
	docs = 'docs',
	doc = 'docs',
	help = 'docs',
	meta = 'docs',
	documentation = 'docs',
	project = 'docs',
}

local function styles(frame)
	return frame:extensionTag('templatestyles', '', {
		src = 'Module:MetaDoc/styles.css',
	})
end

-- Lua 5.1 `..` does not call __tostring; mw.html has no __concat here.
local function with_styles(html, frame)
	return tostring(html) .. styles(frame)
end

local function resolve_severity(value)
	if value == nil then
		return 'preference'
	end

	local key = mw.ustring.lower(mw.text.trim(tostring(value)))
	return SEVERITY_ALIASES[key] or 'preference'
end

local function add_dot(parent)
	parent:tag('span'):addClass('ow-rule-dot')
end

local function severity_hint(severity)
	for i = 1, #LEGEND_ITEMS do
		if LEGEND_ITEMS[i].id == severity then
			return LEGEND_ITEMS[i].body
		end
	end

	return ''
end

local function render_severity_hover(severity, label)
	local pill = mw.html.create('span')
	pill:addClass('ow-rule-pill')
	pill:tag('span'):addClass('ow-rule-dot'):attr('aria-hidden', 'true')
	pill:tag('span'):addClass('ow-rule-pill-label'):wikitext(label)

	local tooltip = FloatingUI.renderSection({
		desc = severity_hint(severity),
		inline = true,
	})

	return FloatingUI.render(tostring(pill), tooltip, true)
end

local function parse_scopes(value)
	if value == nil then
		return nil
	end

	local raw = mw.text.trim(tostring(value))
	if raw == '' then return nil end

	local lower = mw.ustring.lower(raw)
	if lower == 'all' or lower == 'everywhere' or lower == 'any' then
		return SCOPE_ORDER
	end

	local whole = SCOPE_ALIASES[lower]
	if whole then
		return { whole }
	end

	local normalized = mw.ustring.gsub(raw, '[,;/]+', ',')
	local parts = mw.text.split(normalized, ',', true)
	local seen = {}

	for i = 1, #parts do
		local token = mw.ustring.lower(mw.text.trim(parts[i]))
		local id = SCOPE_ALIASES[token]

		if id then
			seen[id] = true
		end
	end

	local ordered = {}
	for i = 1, #SCOPE_ORDER do
		local id = SCOPE_ORDER[i]

		if seen[id] then
			ordered[#ordered + 1] = id
		end
	end

	if #ordered == 0 then
		return nil
	end
	return ordered
end

local function render_scope_chips(scopes)
	if not scopes then
		return ''
	end

	local cluster = mw.html.create('span')
	cluster:addClass('ow-rule-scopes')
	cluster:attr('aria-label', 'Applies to')

	for i = 1, #scopes do
		local meta = SCOPE_META[scopes[i]]
		local chip = mw.html.create('span')
		chip:addClass('ow-rule-scope')
		chip:attr('aria-hidden', 'true')
		chip:wikitext(meta.letter)

		local tooltip = FloatingUI.renderSection({
			label = meta.label,
			desc = meta.hint,
			inline = true,
		})
		cluster:wikitext(FloatingUI.render(tostring(chip), tooltip, true))
	end

	return tostring(cluster)
end

-- TODO: i18n
local EXAMPLE_LABELS = {
	['do'] = 'Do',
	dont = 'Don\'t',
}

local function list_item_text(line)
	local trimmed = mw.text.trim(line)
	if trimmed == '' then
		return nil
	end

	local item = mw.ustring.gsub(trimmed, '^[*#]+%s*', '')
	if item == '' then
		return nil
	end
	
	return item
end

local function is_list_wikitext(wikitext)
	local lines = mw.text.split(wikitext, '\n', true)
	local saw_item = false

	for i = 1, #lines do
		local trimmed = mw.text.trim(lines[i])

		if trimmed ~= '' then
			if not mw.ustring.match(trimmed, '^[*#]') then
				return false
			end
			saw_item = true
		end
	end

	return saw_item
end

local function parse_side(main, example, note)
	local content = {
		example = example,
		note = note,
	}

	if not main then
		return content
	end

	if is_list_wikitext(main) then
		content.list = main
	elseif not example then
		content.example = main
	end

	return content
end

local function side_has_content(content)
	return content.list or content.example or content.note
end

local function render_list(parent, wikitext)
	local ul = parent:tag('ul')
	local lines = mw.text.split(wikitext, '\n', true)

	for i = 1, #lines do
		local item = list_item_text(lines[i])
		if item then
			ul:tag('li'):wikitext(item)
		end
	end
end

local function render_example(kind, content)
	local box = mw.html.create('div')
	box:addClass('ow-example')

	if kind == 'do' then
		box:addClass('ow-example--do')
		box:addClass('ow-do')
	else
		box:addClass('ow-example--dont')
		box:addClass('ow-dont')
	end

	local head = box:tag('div')
	head:addClass('ow-example-head')
	head:tag('span'):addClass('ow-example-icon'):attr('aria-hidden', 'true')
	head:tag('span'):addClass('ow-example-label'):wikitext(EXAMPLE_LABELS[kind])

	if content.example then
		local sample = box:tag('div')

		sample:addClass('ow-example-sample')
		sample:wikitext('\n' .. mw.text.trim(content.example) .. '\n')
	end

	if content.list or content.note then
		local body = box:tag('div')
		body:addClass('ow-example-body')

		if content.list then
			render_list(body, content.list)
		end

		if content.note then
			local note = body:tag('p')
			note:addClass('ow-example-note')
			note:wikitext(content.note)
		end
	end

	return box
end

local function add_pair_head(parent, kind)
	local head = parent:tag('div')

	head:addClass('ow-example-head')
	head:addClass('ow-example--' .. kind)
	head:addClass('ow-pair-head')
	head:addClass('ow-pair-head--' .. kind)
	head:tag('span'):addClass('ow-example-icon'):attr('aria-hidden', 'true')
	head:tag('span'):addClass('ow-example-label'):wikitext(EXAMPLE_LABELS[kind])
end

local function add_pair_sample(parent, kind, content)
	local sample = parent:tag('div')
	sample:addClass('ow-example-sample')
	sample:addClass('ow-example--' .. kind)
	sample:addClass('ow-pair-sample')
	sample:addClass('ow-pair-sample--' .. kind)
	if content.example then
		sample:wikitext('\n' .. mw.text.trim(content.example) .. '\n')
	else
		sample:addClass('ow-example-sample--empty')
	end
end

local function add_pair_body(parent, kind, content)
	local body = parent:tag('div')
	body:addClass('ow-example-body')
	body:addClass('ow-example--' .. kind)
	body:addClass('ow-pair-body')
	body:addClass('ow-pair-body--' .. kind)
	if kind == 'do' then
		body:addClass('ow-do')
	else
		body:addClass('ow-dont')
	end

	if content.list then
		render_list(body, content.list)
	end
	if content.note then
		local note = body:tag('p')
		note:addClass('ow-example-note')
		note:wikitext(content.note)
	end
	if not content.list and not content.note then
		body:addClass('ow-example-body--empty')
	end
end

local function append_notice(parent, wikitext)
	if not wikitext then
		return
	end
	if mw.text.trim(wikitext) == '' then
		return
	end

	local notice = parent:tag('div')
	notice:addClass('ow-rule-notice')
	notice:tag('span'):addClass('ow-rule-notice-icon'):attr('aria-hidden', 'true')
	local inner = notice:tag('div')
	inner:addClass('ow-rule-notice-body')
	inner:wikitext('\n' .. mw.text.trim(wikitext) .. '\n')
end

local function append_fold(parent, frame, class_name, heading, wikitext)
	if not wikitext then
		return
	end
	if mw.text.trim(wikitext) == '' then
		return
	end

	local summary_inner = mw.html.create()
	summary_inner:tag('span'):addClass('ow-rule-fold-icon'):attr('aria-hidden', 'true')
	summary_inner:tag('span'):addClass('ow-rule-fold-label'):wikitext(heading)

	local summary = frame:extensionTag({
		name = 'summary',
		content = tostring(summary_inner),
		args = {
			class = 'ow-rule-fold-summary',
		},
	})

	local inner = mw.html.create('div')
	inner:addClass('ow-rule-fold-body')
	inner:wikitext('\n' .. mw.text.trim(wikitext) .. '\n')

	local details = frame:extensionTag({
		name = 'details',
		content = summary .. tostring(inner),
		args = {
			class = 'ow-rule-fold ' .. class_name,
		},
	})

	parent:wikitext(details)
end

local function highlight(frame, code, lang, inline)
	local tag_args = {
		lang = lang or 'wikitext',
	}
	if inline then
		tag_args.inline = '1'
	end
	return frame:extensionTag('syntaxhighlight', code, tag_args)
end

local HEADING_DEMO = {
	{ level = 2, class_name = 'ow-markup-heading--2' },
	{ level = 3, class_name = 'ow-markup-heading--3' },
	{ level = 4, class_name = 'ow-markup-heading--4' },
	{ level = 5, class_name = 'ow-markup-heading--5' },
	{ level = 6, class_name = 'ow-markup-heading--6' },
}

local function heading_source(level, title)
	local marks = string.rep('=', level)
	return marks .. ' ' .. title .. ' ' .. marks
end

local function render_heading_markup(frame, heading)
	local box = mw.html.create('div')
	box:addClass('ow-markup')
	box:addClass('ow-markup--headings')

	local label = box:tag('div')
	label:addClass('ow-markup-label')
	label:tag('span'):addClass('ow-markup-icon'):attr('aria-hidden', 'true')
	label:tag('span'):wikitext(heading or 'Markup')

	local body = box:tag('div')
	body:addClass('ow-markup-body')

	for i = 1, #HEADING_DEMO do
		local item = HEADING_DEMO[i]
		local row = body:tag('div')

		row:addClass('ow-markup-heading')
		row:addClass(item.class_name)
		row:wikitext(highlight(frame, heading_source(item.level, 'Title'), 'wikitext', true))
	end

	local never = body:tag('div')
	never:addClass('ow-markup-heading')
	never:addClass('ow-markup-heading--never')
	never:tag('span'):addClass('ow-markup-heading-x'):attr('aria-hidden', 'true')
	never:wikitext(highlight(frame, heading_source(1, 'Title'), 'wikitext', true))
	never:tag('span'):addClass('ow-markup-heading-flag'):wikitext('Never used')

	local note = box:tag('p')
	note:addClass('ow-markup-note')
	note:wikitext('Spaces around the title are preferred for readability purposes. Don\'t skip a level.')

	return box
end

local function render_code_markup(frame, code, lang, heading)
	local box = mw.html.create('div')
	box:addClass('ow-markup')

	local label = box:tag('div')
	label:addClass('ow-markup-label')
	label:tag('span'):addClass('ow-markup-icon'):attr('aria-hidden', 'true')
	label:tag('span'):wikitext(heading or 'Markup')

	local body = box:tag('div')
	body:addClass('ow-markup-body')
	body:wikitext(highlight(frame, code, lang, false))

	return box
end

local LAYOUT_PARSER_NAMES = {
	displaytitle = true,
	shortdesc = true,
	defaultsort = true,
}

local LAYOUT_MAINT_NAMES = {
	underconstruction = true,
	construction = true,
	cleanup = true,
	delete = true,
	maintenance = true,
}

local LAYOUT_REGIONS = {
	['before the lead'] = 'Before the lead',
	['before the lead section'] = 'Before the lead',
	body = 'Body',
	['bottom matter'] = 'Bottom matter',
	bottom = 'Bottom matter',
}

local LAYOUT_ALIASES = {
	lead = 'lead',
	introduction = 'lead',
	['lead section'] = 'lead',
	infobox = 'infobox',
	infoboxes = 'infobox',
	image = 'image',
	images = 'image',
	file = 'image',
	related = 'related',
	['related articles'] = 'related',
	['related articles templates'] = 'related',
	maintenance = 'maintenance',
	['maintenance templates'] = 'maintenance',
	navplate = 'nav',
	navplates = 'nav',
	stub = 'stub',
	['stub templates'] = 'stub',
	categories = 'categories',
	category = 'categories',
	['parser functions'] = 'parser',
}

local LAYOUT_BLOCK_CLASS = {
	parser = 'meta',
	related = 'related',
	maintenance = 'maint',
	stub = 'maint',
	infobox = 'infobox',
	image = 'image',
	lead = 'lead',
	nav = 'nav',
	categories = 'cats',
}

local LAYOUT_BLOCK_KICKER = {
	parser = 'Parser functions',
	related = 'Related articles',
	maintenance = 'Maintenance templates',
	image = 'Images (if no infobox)',
	lead = 'Lead',
	categories = 'Categories',
}

local LAYOUT_DEFAULT_NOTE = 'Layouts are subject to change.'
local LAYOUT_DEFAULT_PLACE = 'Always put the infobox at the top of the page.'

local function split_named_list(value)
	if value == nil then
		return {}
	end

	local normalized = mw.ustring.gsub(tostring(value), '[\n;]+', ',')
	local parts = mw.text.split(normalized, ',', true)
	local items = {}

	for i = 1, #parts do
		local item = mw.text.trim(parts[i])
		if item ~= '' then
			items[#items + 1] = item
		end
	end

	return items
end

local function raw_layout_arg(value)
	if value == nil then
		return nil
	end

	local text = mw.text.unstripNoWiki(tostring(value))
	text = mw.text.trim(text)
	if text == '' then
		return nil
	end

	return text
end

local function template_name(value)
	local trimmed = mw.text.trim(value)
	local inner = mw.ustring.match(trimmed, '^{{(.*)}}$')
	if inner then
		trimmed = inner
	end

	local name = mw.ustring.match(trimmed, '^([^|:]+)') or trimmed
	return mw.text.trim(name)
end

local function template_display(value)
	local name = template_name(value)
	if name == '' then
		return nil
	end

	return '{{' .. name .. '}}'
end

local function parse_layout_heading(line)
	local marks, title, flag = mw.ustring.match(line, '^(=+)[ \t]*(.-)[ \t]*%1[ \t]*(%??)$')
	local level

	if marks then
		level = mw.ustring.len(marks)
	else
		local stars, item = mw.ustring.match(line, '^([*]+)[ \t]*(.+)$')
		if not stars then
			return nil
		end

		level = mw.ustring.len(stars) + 1
		title = item
		flag = ''
		if mw.ustring.match(title, '%?$') then
			flag = '?'
			title = mw.ustring.gsub(title, '%?$', '')
		end
	end

	title = mw.text.trim(title)
	if title == '' then
		return nil
	end

	local optional = flag == '?'
	if mw.ustring.match(mw.ustring.lower(title), '%(optional%)%s*$') then
		optional = true
		title = mw.ustring.gsub(title, '[ \t]*%([Oo]ptional%)%s*$', '')
		title = mw.text.trim(title)
	end

	if title == '' then
		return nil
	end

	return {
		label = title,
		level = level,
		optional = optional,
	}
end

local function normalize_layout_line(line)
	local optional = false
	local text = line
	local stripped = mw.ustring.gsub(text, '%?$', '')

	if stripped ~= text then
		optional = true
		text = mw.text.trim(stripped)
	end

	local lower = mw.ustring.lower(text)
	if mw.ustring.match(lower, '%(optional%)%s*$') then
		optional = true
		text = mw.ustring.gsub(text, '[ \t]*%([Oo]ptional%)%s*$', '')
		text = mw.text.trim(text)
		lower = mw.ustring.lower(text)
	end
	if mw.ustring.match(lower, '%(if no infoboxe?s?%)%s*$') then
		optional = true
		text = mw.ustring.gsub(text, '[ \t]*%(%s*[Ii]f no [Ii]nfoboxe?s?%s*%)%s*$', '')
		text = mw.text.trim(text)
	end

	return text, optional
end

local function classify_layout_token(line)
	local text, optional = normalize_layout_line(line)
	local lower = mw.ustring.lower(text)
	local region = LAYOUT_REGIONS[lower]
	if region then
		return 'region', region, optional
	end

	local alias = LAYOUT_ALIASES[lower]
	if alias then
		local display = nil
		if alias == 'infobox' or alias == 'nav' or alias == 'stub' or alias == 'related' then
			display = template_display(text)
		end
		return alias, display, optional
	end

	local name = template_name(text)
	local name_lower = mw.ustring.lower(name)
	local display = template_display(text)

	if LAYOUT_PARSER_NAMES[name_lower] then
		return 'parser', display, optional
	end
	if LAYOUT_ALIASES[name_lower] then
		return LAYOUT_ALIASES[name_lower], display, optional
	end
	if mw.ustring.find(name_lower, 'infobox', 1, true) then
		return 'infobox', display, optional
	end
	if name_lower == 'stub' then
		return 'stub', display, optional
	end
	if LAYOUT_MAINT_NAMES[name_lower] then
		return 'maintenance', display, optional
	end
	if name_lower == 'alsoby' or mw.ustring.find(name_lower, 'navplate', 1, true) then
		return 'nav', display, optional
	end
	if mw.ustring.find(name_lower, 'related', 1, true) then
		return 'related', display, optional
	end

	return 'unknown', display, optional
end

local function add_layout_token(page, kind, display, optional)
	if kind == 'unknown' then
		if display then
			if page.saw_heading then
				kind = 'nav'
			else
				kind = 'infobox'
			end
		else
			return
		end
	end

	if kind == 'parser' then
		local last = page.blocks[#page.blocks]
		if last and last.kind == 'parser' then
			if display then
				last.items[#last.items + 1] = display
			end
			return
		end

		local items = {}
		if display then
			items[1] = display
		end
		page.blocks[#page.blocks + 1] = {
			kind = 'parser',
			items = items,
			optional = optional,
		}
		return
	end

	if kind == 'region' then
		page.blocks[#page.blocks + 1] = {
			kind = 'region',
			label = display,
		}
		return
	end

	if kind == 'lead' then
		page.blocks[#page.blocks + 1] = {
			kind = 'lead',
			optional = optional,
		}
		page.has_lead = true
		return
	end

	if kind == 'infobox' then
		page.infobox = display or page.infobox or '{{Infobox}}'
		page.blocks[#page.blocks + 1] = {
			kind = 'infobox',
			kicker = page.infobox,
			optional = optional,
		}
		return
	end

	if kind == 'categories' then
		page.blocks[#page.blocks + 1] = {
			kind = 'categories',
			optional = optional,
		}
		page.saw_categories = true
		return
	end

	page.blocks[#page.blocks + 1] = {
		kind = kind,
		kicker = display,
		optional = optional,
	}
end

local function parse_layout_outline(wikitext)
	local page = {
		blocks = {},
	}
	local raw = raw_layout_arg(wikitext)
	if not raw then
		return page
	end

	local lines = mw.text.split(raw, '\n', true)

	for i = 1, #lines do
		local line = mw.text.trim(lines[i])
		if line ~= '' then
			local heading = parse_layout_heading(line)
			if heading then
				page.blocks[#page.blocks + 1] = heading
				page.blocks[#page.blocks].kind = 'heading'
				page.saw_heading = true
			else
				local kind, display, optional = classify_layout_token(line)
				add_layout_token(page, kind, display, optional)
			end
		end
	end

	return page
end

local function parse_layout_categories(value)
	if value == nil then
		return { 'Category', 'Category' }
	end

	local flag = yesno(value, nil)
	if flag == false then
		return nil
	end
	if flag == true then
		return { 'Category', 'Category' }
	end

	local items = split_named_list(value)
	if #items == 0 then
		return { 'Category', 'Category' }
	end

	return items
end

local function parse_parser_list(value)
	local items = split_named_list(raw_layout_arg(value))
	local parsers = {}

	for i = 1, #items do
		local display = template_display(items[i])
		if display then
			parsers[#parsers + 1] = display
		end
	end

	if #parsers == 0 then
		return nil
	end

	return parsers
end

local function find_layout_block(page, kind)
	if not page.blocks then
		return nil
	end

	for i = 1, #page.blocks do
		if page.blocks[i].kind == kind then
			return page.blocks[i], i
		end
	end

	return nil
end

local function upsert_layout_block(page, kind, fields, at_start)
	page.blocks = page.blocks or {}
	local block = find_layout_block(page, kind)
	
	if block then
		if fields.kicker then
			block.kicker = fields.kicker
		end

		if fields.items then
			block.items = fields.items
		end

		if fields.optional ~= nil then
			block.optional = fields.optional
		end

		return block
	end

	block = {
		kind = kind,
		kicker = fields.kicker,
		items = fields.items,
		optional = fields.optional,
	}
	if at_start then
		table.insert(page.blocks, 1, block)
	else
		page.blocks[#page.blocks + 1] = block
	end

	return block
end

local function replace_heading_blocks(page, heading_blocks)
	page.blocks = page.blocks or {}
	local next_blocks = {}
	local inserted = false

	for i = 1, #page.blocks do
		if page.blocks[i].kind ~= 'heading' then
			next_blocks[#next_blocks + 1] = page.blocks[i]
		elseif not inserted then
			for j = 1, #heading_blocks do
				next_blocks[#next_blocks + 1] = heading_blocks[j]
			end
			inserted = true
		end
	end

	if not inserted then
		for j = 1, #heading_blocks do
			next_blocks[#next_blocks + 1] = heading_blocks[j]
		end
	end

	page.blocks = next_blocks
end

local function apply_layout_fields(page, fields)
	page.blocks = page.blocks or {}

	if fields.infobox then
		page.infobox = template_display(fields.infobox)
		upsert_layout_block(page, 'infobox', { kicker = page.infobox }, true)
	end

	if fields.nav then
		upsert_layout_block(page, 'nav', { kicker = template_display(fields.nav) }, false)
	end

	if fields.maintenance then
		local display = template_display(fields.maintenance)
		local name = mw.ustring.lower(template_name(fields.maintenance))
		if name == 'stub' then
			upsert_layout_block(page, 'stub', { kicker = display }, false)
		else
			upsert_layout_block(page, 'maintenance', { kicker = display }, false)
		end
	end

	if fields.parsers then
		upsert_layout_block(page, 'parser', { items = parse_parser_list(fields.parsers) }, false)
	end

	if fields.headings then
		replace_heading_blocks(page, parse_layout_outline(fields.headings).blocks)
	end

	if fields.place then
		page.place = fields.place
	end

	if fields.lead ~= nil then
		page.lead = fields.lead
	end

	if fields.categories ~= nil then
		page.categories = parse_layout_categories(fields.categories)
	end

	if fields.label then
		page.label = fields.label
	end
end

local function insert_auto_lead(page)
	if page.lead == false or page.has_lead then
		return
	end

	local blocks = page.blocks
	local infobox_at
	local body_at
	local heading_at

	for i = 1, #blocks do
		if blocks[i].kind == 'infobox' then
			infobox_at = i
		elseif blocks[i].kind == 'region' and blocks[i].label == 'Body' then
			body_at = i
		elseif blocks[i].kind == 'heading' and not heading_at then
			heading_at = i
		end
	end

	local insert_at = 1
	if body_at then
		insert_at = body_at + 1
	elseif infobox_at then
		insert_at = infobox_at + 1
		while insert_at <= #blocks and blocks[insert_at].kind == 'image' do
			insert_at = insert_at + 1
		end
	elseif heading_at then
		insert_at = heading_at
	end

	table.insert(blocks, insert_at, { kind = 'lead' })
	page.has_lead = true
end

local function finalize_layout_page(page)
	page.blocks = page.blocks or {}

	if page.lead == false then
		local kept = {}

		for i = 1, #page.blocks do
			if page.blocks[i].kind ~= 'lead' then
				kept[#kept + 1] = page.blocks[i]
			end
		end

		page.blocks = kept
		page.has_lead = false
	else
		insert_auto_lead(page)
	end

	if not page.infobox then
		local infobox = find_layout_block(page, 'infobox')

		if infobox then
			page.infobox = infobox.kicker
		end
	end

	if page.categories and not page.saw_categories then
		page.blocks[#page.blocks + 1] = {
			kind = 'categories',
			items = page.categories,
		}
		
		page.saw_categories = true
	elseif page.saw_categories then
		local cats = find_layout_block(page, 'categories')

		if cats and not cats.items then
			cats.items = page.categories or { 'Category', 'Category' }
		end
	end
end

local function numbered_layout_fields(args, n)
	local label = raw_layout_arg(args['tab' .. n] or args['label' .. n])
	local outline = args['layout' .. n] or args['page' .. n]
	local headings = args['headings' .. n]
	local infobox = raw_layout_arg(args['infobox' .. n])
	local nav = raw_layout_arg(args['nav' .. n] or args['navplate' .. n])
	local maintenance = raw_layout_arg(args['maintenance' .. n] or args['stub' .. n])
	local parsers = args['parsers' .. n]
	local place = raw_layout_arg(args['place' .. n])
	local categories = args['categories' .. n]
	local lead = args['lead' .. n]

	if not (label or outline or headings or infobox or nav or maintenance or parsers or place or categories or lead) then
		return nil
	end

	return {
		label = label,
		outline = outline,
		headings = headings,
		infobox = infobox,
		nav = nav,
		maintenance = maintenance,
		parsers = parsers,
		place = place,
		categories = categories,
		lead = lead,
	}
end

local function layout_arg_named(args, name)
	if name == nil then
		return nil
	end

	local direct = args[name]
	if direct ~= nil then
		return direct
	end

	local lower = mw.ustring.lower(name)
	for key, value in pairs(args) do
		if type(key) == 'string' and mw.ustring.lower(key) == lower then
			return value
		end
	end

	return nil
end

local function collect_layout_pages(args)
	local pages = {}
	local tab_names = split_named_list(args.tabs)

	if #tab_names > 0 then
		for i = 1, #tab_names do
			local label = tab_names[i]
			local page = parse_layout_outline(layout_arg_named(args, label))
			local fields = numbered_layout_fields(args, i) or {}

			fields.label = label
			apply_layout_fields(page, fields)

			if page.categories == nil then
				page.categories = parse_layout_categories(args.categories)
			end

			if page.lead == nil then
				page.lead = yesno(args.lead, true)
			else
				page.lead = yesno(page.lead, true)
			end

			finalize_layout_page(page)
			pages[#pages + 1] = page
		end

		return pages
	end

	for i = 1, 30 do
		local fields = numbered_layout_fields(args, i)

		if fields then
			local page = parse_layout_outline(fields.outline)
			apply_layout_fields(page, fields)

			if not page.label then
				page.label = 'Page ' .. i
			end

			if page.categories == nil then
				page.categories = parse_layout_categories(args.categories)
			end

			page.lead = yesno(fields.lead or args.lead, true)
			finalize_layout_page(page)
			pages[#pages + 1] = page
		end
	end

	if #pages > 0 then
		return pages
	end

	if args.layout or args.headings or args.infobox or args.nav or args.navplate or args.maintenance or args.stub or args.parsers then
		local page = parse_layout_outline(args.layout)

		apply_layout_fields(page, {
			label = raw_layout_arg(args.tab or args.label) or 'Page',
			headings = args.headings,
			infobox = raw_layout_arg(args.infobox),
			nav = raw_layout_arg(args.nav or args.navplate),
			maintenance = raw_layout_arg(args.maintenance or args.stub),
			parsers = args.parsers,
			place = raw_layout_arg(args.place),
			categories = args.categories,
			lead = args.lead,
		})

		page.lead = yesno(args.lead, true)

		if page.categories == nil then
			page.categories = parse_layout_categories(args.categories)
		end

		finalize_layout_page(page)
		pages[1] = page
	end

	return pages
end

local function add_layout_lines(parent, count)
	for i = 1, count do
		parent:tag('div'):addClass('ow-layout-lines'):attr('aria-hidden', 'true')
	end
end

local function add_layout_block(parent, kind, kicker, line_count)
	local block = parent:tag('div')
	block:addClass('ow-layout-block')
	block:addClass('ow-layout-block--' .. kind)

	if kind == 'infobox' then
		if kicker then
			block:tag('div'):addClass('ow-layout-kicker'):wikitext(kicker)
		end

		block:tag('div'):addClass('ow-layout-thumb'):attr('aria-hidden', 'true')

		local fields = block:tag('div')
		fields:addClass('ow-layout-fields')

		for i = 1, 9 do
			fields:tag('div'):addClass('ow-layout-field'):attr('aria-hidden', 'true')
		end

		return block
	end

	if kicker then
		block:tag('div'):addClass('ow-layout-kicker'):wikitext(kicker)
	end
	add_layout_lines(block, line_count or 2)
	return block
end

local function render_layout_headings(parent, headings)
	if not headings then
		return
	end

	local current = nil
	for i = 1, #headings do
		local item = headings[i]
		local level = item.level or 2
		local section

		if level <= 2 or not current then
			section = parent:tag('div')
			current = section
		else
			section = current:tag('div')
		end

		section:addClass('ow-layout-section')

		if level > 2 then
			section:addClass('ow-layout-section--sub')
		end

		if item.optional then
			section:addClass('ow-layout-section--optional')
		end

		section:tag('div'):addClass('ow-layout-section-title'):wikitext(
			mw.text.nowiki(heading_source(level, item.label))
		)

		if level <= 2 then
			add_layout_lines(section, 1)
		end
	end
end

local function add_layout_chips(parent, kind, kicker, items)
	local block = parent:tag('div')
	block:addClass('ow-layout-block')
	block:addClass('ow-layout-block--' .. kind)

	if kicker then
		block:tag('div'):addClass('ow-layout-kicker'):wikitext(kicker)
	end

	if items and #items > 0 then
		local row = block:tag('div')
		row:addClass('ow-layout-chips')
		for i = 1, #items do
			row:tag('span'):addClass('ow-layout-chip'):wikitext(mw.text.nowiki(items[i]))
		end
	end

	return block
end

local function render_layout_block(parent, block, extras)
	local kind = block.kind
	local class_name = LAYOUT_BLOCK_CLASS[kind] or kind
	local kicker = block.kicker or LAYOUT_BLOCK_KICKER[kind]
	local node

	if kind == 'region' then
		node = parent:tag('div')
		node:addClass('ow-layout-region')
		if block.label == 'Bottom matter' then
			node:addClass('ow-layout-region--bottom')
		end
		node:wikitext(block.label)
		return node
	end

	if kind == 'infobox' then
		parent:tag('div'):addClass('ow-layout-place'):wikitext(extras.place or LAYOUT_DEFAULT_PLACE)
		node = add_layout_block(parent, 'infobox', mw.text.nowiki(kicker), 2)
	elseif kind == 'lead' then
		node = add_layout_block(parent, 'lead', kicker, 4)
	elseif kind == 'image' then
		node = parent:tag('div')
		node:addClass('ow-layout-block')
		node:addClass('ow-layout-block--image')
		node:tag('div'):addClass('ow-layout-kicker'):wikitext(kicker)
		node:tag('div'):addClass('ow-layout-thumb'):attr('aria-hidden', 'true')
	elseif kind == 'parser' then
		node = add_layout_chips(parent, class_name, kicker, block.items)
	elseif kind == 'categories' then
		node = add_layout_chips(parent, class_name, kicker, block.items or extras.categories)
	elseif kind == 'related' then
		local items = nil

		if block.kicker then
			items = { block.kicker }
		end

		node = add_layout_chips(parent, class_name, LAYOUT_BLOCK_KICKER.related, items)

		if not items then
			add_layout_lines(node, 2)
		end
	elseif kind == 'maintenance' then
		node = add_layout_block(parent, class_name, LAYOUT_BLOCK_KICKER.maintenance, 2)

		if block.kicker then
			node:tag('div'):addClass('ow-layout-kicker'):wikitext(mw.text.nowiki(block.kicker))
		end
	else
		node = add_layout_block(parent, class_name, kicker and mw.text.nowiki(kicker) or nil, 1)
	end

	if block.optional and node then
		node:addClass('ow-layout-block--optional')
	end

	return node
end

local function should_clear_layout_block(block, seen_infobox)
	if not seen_infobox then
		return false
	end

	if block.kind == 'lead' or block.kind == 'heading' or block.kind == 'image' or block.kind == 'infobox' then
		return false
	end

	if block.kind == 'region' and block.label ~= 'Bottom matter' then
		return false
	end

	return true
end

local function render_layout_page(page_type)
	local page = mw.html.create('div')
	page:addClass('ow-layout-page')
	if page_type.infobox then
		page:addClass('ow-layout-page--infobox')
	end

	local blocks = page_type.blocks or {}
	local extras = {
		place = page_type.place,
		categories = page_type.categories,
	}
	local seen_infobox = false
	local i = 1

	while i <= #blocks do
		local block = blocks[i]
		if block.kind == 'heading' then
			local headings = {}

			while i <= #blocks and blocks[i].kind == 'heading' do
				headings[#headings + 1] = blocks[i]
				i = i + 1
			end

			render_layout_headings(page, headings)
		else
			if block.kind == 'infobox' then
				seen_infobox = true
			end

			local node = render_layout_block(page, block, extras)

			if node and should_clear_layout_block(block, seen_infobox and block.kind ~= 'infobox') then
				node:addClass('ow-layout-clear')
			end
			-- related currently may add two nodes; the chips one is last
			i = i + 1
		end
	end

	return tostring(page)
end

local function layout_note_text(value)
	local flag = yesno(value, nil)
	
	if flag == false then
		return nil
	end

	if value == nil or flag == true then
		return LAYOUT_DEFAULT_NOTE
	end

	return value
end

local function render_layout(frame, args)
	local box = mw.html.create('div')
	box:addClass('ow-markup')
	box:addClass('ow-markup--layout')

	local label = box:tag('div')
	label:addClass('ow-markup-label')
	label:tag('span'):addClass('ow-markup-icon'):attr('aria-hidden', 'true')
	label:tag('span'):wikitext(args.title or 'Layout')

	local pages = collect_layout_pages(args)
	if #pages == 0 then
		pages[1] = {
			label = 'Page',
			lead = true,
			blocks = {
				{ kind = 'heading', label = 'Section', level = 2 },
			},
			categories = parse_layout_categories(nil),
		}
		finalize_layout_page(pages[1])
	end

	if #pages == 1 then
		box:wikitext(render_layout_page(pages[1]))
	else
		local tabs = {}
		for i = 1, #pages do
			tabs[#tabs + 1] = '|-|' .. pages[i].label .. '=' .. render_layout_page(pages[i])
		end

		box:wikitext(frame:extensionTag({
			name = 'tabber',
			content = table.concat(tabs),
		}))
	end

	local note_text = layout_note_text(args.note)
	if note_text then
		local note = box:tag('p')
		note:addClass('ow-markup-note')
		note:wikitext(note_text)
	end

	return box
end

local function append_do_dont(parent, do_content, dont_content)
	local has_do = side_has_content(do_content)
	local has_dont = side_has_content(dont_content)

	if not has_do and not has_dont then return end

	local pair = parent:tag('div')
	pair:addClass('ow-do-dont')
	if has_do and has_dont then
		pair:addClass('ow-do-dont--pair')
		add_pair_head(pair, 'do')
		add_pair_head(pair, 'dont')

		if do_content.example or dont_content.example then
			pair:addClass('ow-do-dont--has-sample')
			add_pair_sample(pair, 'do', do_content)
			add_pair_sample(pair, 'dont', dont_content)
		end

		add_pair_body(pair, 'do', do_content)
		add_pair_body(pair, 'dont', dont_content)
		return
	end

	if has_do then
		pair:node(render_example('do', do_content))
	end
	if has_dont then
		pair:node(render_example('dont', dont_content))
	end
end

function p.tldr(frame)
	local args = get_args(frame)
	local box = mw.html.create('div')
	box:addClass('ow-tldr')

	local title = box:tag('p')
	title:addClass('ow-tldr-title')
	title:wikitext(args.title or 'TL;DR')

	local body = box:tag('div')
	body:addClass('ow-tldr-body')

	if args[1] then
		body:wikitext(args[1])
	end

	append_do_dont(
		body,
		parse_side(args['do'], args.do_example, args.do_note),
		parse_side(args['dont'], args.dont_example, args.dont_note)
	)

	return with_styles(box, frame)
end

function p.rule(frame)
	local args = get_args(frame)
	local severity = resolve_severity(args.severity)
	local label = SEVERITY_LABELS[severity]

	local summary_inner = mw.html.create()
	local title = summary_inner:tag('span')

	title:addClass('ow-rule-title')

	if args.title then title:wikitext(args.title) end

	summary_inner:wikitext(render_scope_chips(parse_scopes(args.applies or args.where or args.scope)))
	summary_inner:wikitext(render_severity_hover(severity, label))

	-- this is required, as mw.html doesn't work for <details>/<summary>
	local summary = frame:extensionTag({
		name = 'summary',
		content = tostring(summary_inner),
		args = {
			class = 'ow-rule-summary',
		},
	})

	local body = mw.html.create('div')
	body:addClass('ow-rule-body')

	if args[1] then body:wikitext(args[1]) end

	append_do_dont(body, parse_side(args['do'], args.do_example, args.do_note), parse_side(args['dont'], args.dont_example, args.dont_note))
	append_notice(body, args.notice or args.edge)
	append_fold(body, frame, 'ow-rule-fold--notes', 'Notes', args.notes)
	append_fold(body, frame, 'ow-rule-fold--tips', 'Helpful tips', args.tips)

	local details_args = {
		class = 'ow-rule ow-severity--' .. severity,
	}
	if yesno(args.open, false) then
		details_args.open = 'open'
	end

	local details = frame:extensionTag({
		name = 'details',
		content = summary .. tostring(body),
		args = details_args,
	})

	return FloatingUI.load(frame) .. details .. styles(frame)
end

function p.dos(frame)
	local args = get_args(frame)
	return with_styles(render_example('do', parse_side(args[1], args.example, args.note)), frame)
end

function p.dont(frame)
	local args = get_args(frame)
	return with_styles(render_example('dont', parse_side(args[1], args.example, args.note)), frame)
end

function p.legend(frame)
	local list = mw.html.create('ul')
	list:addClass('ow-severity-key')

	for i = 1, #LEGEND_ITEMS do
		local item = LEGEND_ITEMS[i]
		local li = list:tag('li')

		li:addClass('ow-severity-key-item')
		li:addClass('ow-severity--' .. item.id)
		add_dot(li)

		local text = li:tag('span')

		text:addClass('ow-severity-key-text')
		text:tag('b'):wikitext(item.title):done()
		text:wikitext(': ' .. item.body)
	end

	return with_styles(list, frame)
end

function p.scopekey(frame)
	local list = mw.html.create('ul')
	list:addClass('ow-scope-key')

	for i = 1, #SCOPE_ORDER do
		local meta = SCOPE_META[SCOPE_ORDER[i]]
		local li = list:tag('li')

		li:addClass('ow-scope-key-item')
		li:tag('span'):addClass('ow-rule-scope'):wikitext(meta.letter)

		local text = li:tag('span')
		
		text:addClass('ow-scope-key-text')
		text:tag('b'):wikitext(meta.label):done()
		text:wikitext(': ' .. meta.hint)
	end

	return with_styles(list, frame)
end

function p.markup(frame)
	local args = get_args(frame)
	local type_key = args.type or args.demo
	if not type_key and args[1] then
		type_key = mw.ustring.lower(mw.text.trim(args[1]))
	elseif type_key then
		type_key = mw.ustring.lower(mw.text.trim(type_key))
	end

	if type_key == 'headings' or type_key == 'heading' or type_key == 'sections' then
		return with_styles(render_heading_markup(frame, args.title), frame)
	end

	local code = args.code or args[1]
	if not code or mw.text.trim(code) == '' then
		return ''
	end

	return with_styles(
		render_code_markup(frame, mw.text.trim(code), args.lang, args.title),
		frame
	)
end

function p.layout(frame)
	local args = get_args(frame)
	return with_styles(render_layout(frame, args), frame)
end

local DISCORD_INVITE = 'https://discord.gg/vuJsnzKkKY'

function p.ask(frame)
	local args = get_args(frame)
	local box = mw.html.create('div')
	box:addClass('ow-ask')
	box:tag('span'):addClass('ow-ask-icon'):attr('aria-hidden', 'true')

	local body = box:tag('div')
	body:addClass('ow-ask-body')

	local custom = args[1] or args.text
	if custom and mw.text.trim(custom) ~= '' then
		body:wikitext(mw.text.trim(custom))
	else
		local url = args.url or args.link or DISCORD_INVITE
		body:wikitext('Need a clarification, or extra help? Ask other readers in the [' .. url .. ' Discord server].')
	end

	return with_styles(box, frame)
end

return p
