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
