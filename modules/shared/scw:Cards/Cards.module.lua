local mArguments --initialize lazily
local getArgNums = require('Module:Common').getArgNums
local p = {}


--Implements {{cards}} from the frame
function p.cards(frame)
	mArguments = require('Module:Arguments')
	return p._cards(mArguments.getArgs(frame), frame)
end

function p._cards(args, frame)
	if not args then
		return 'Missing arguments'
	end

	local html = mw.html.create('div'):addClass('template-cards')
	local columns = 0

	for i, _ in ipairs(getArgNums('content', args)) do
		local num = tostring(i)
		local content = args['content' .. num]
		if not content then return end

		local card = mw.html.create('div'):addClass('template-card')

		local column = args['column' .. num]
		if column then
			card:addClass('template-card--col-' .. column)
			columns = columns + tonumber(column)
		else
			columns = columns + 1
		end

		local header = args['header' .. num]
		if header then
			card:tag('div'):addClass('template-card-header')
				:wikitext(header)
				:done()
		end

		card:tag('div'):addClass('template-card-content')
			:wikitext(content)
			:done()

		html:node(card)
	end

	html:css('grid-template-columns', string.format('repeat(%d, minmax(0, 1fr))', columns))

	return frame:extensionTag {
		name = 'templatestyles', args = { src = 'Module:Cards/styles.css' }
	} .. tostring(html)
end

return p