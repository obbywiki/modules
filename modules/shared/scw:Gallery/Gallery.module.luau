local getArgs = require('Module:Arguments').getArgs
local p = {}
local root

function p.main(frame)
	local args = getArgs(frame)
	return p._main(args)
end

function p._main(args)
	local filearg = ''
	local height = '120'
	local prependarg = '[[File:'
	local apprendarg = '|frameless|' .. 'x' .. height .. 'px]]'
	
	for key,value in pairs(args) do
			local content = args[key]
			-- Check if arg is a valid file name
			if content:match('.[^{}<>]+%.%w+') then
				content = prependarg .. content .. apprendarg
			end
	    	filearg = filearg .. content
	end
	
	root = mw.html.create('div')
	root
		:addClass('template-gallery citizen-overflow')
		:wikitext( filearg )
	
	return tostring(root)
end

return p