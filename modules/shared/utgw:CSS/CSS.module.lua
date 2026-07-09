-- imported from https://tagging.wiki/wiki/Module:CSS

local p = {}
local allowedNS = {
	[2] = true, -- User:
	[8] = true, -- MediaWiki:
}

function p.import_css(frame)
	local content = frame:getParent().args.content or frame.args.content
	if content ~= nil then
		return tostring(mw.html.create("span")
			:addClass("import-css")
			:attr("data-css", content)
			:attr("data-css-hash", mw.hash.hashValue("xxh3", content))
			:attr("data-from", "_content_"))
	end
	
	local titleArg = frame:getParent().args[1] or frame.args[1]
	local titleObject = mw.title.new(titleArg or "")
	local errorMsg
	
	if titleArg == nil then errorMsg = "[[T:CSS]] error: No parameters provided"
	elseif titleObject == nil then errorMsg = "[[T:CSS]] error: Parameter “" .. frame:extensionTag("nowiki", titleArg) .. "” is not a valid page name"
	elseif not titleObject.exists then errorMsg = "[[T:CSS]] error: Page “[[" .. titleArg .. "]]” does not exist"
	elseif not allowedNS[titleObject.namespace] then errorMsg = "[[T:CSS]] error: Page “[[" .. titleArg .. "]]” is not in the User or MediaWiki namespaces"
	elseif titleObject.contentModel ~= "css" then errorMsg = "[[T:CSS]] error: Page “[[" .. titleArg .. "]]” is not a CSS page" end
	
	if errorMsg ~= nil then return
		tostring(mw.html.create("strong"):addClass("error"):wikitext(errorMsg)) ..
		"[[Category:Pages with T:CSS errors]]"
	else
		content = titleObject:getContent()
		return tostring(mw.html.create("span")
			:addClass("import-css")
			:attr("data-css", content)
			:attr("data-css-hash", mw.hash.hashValue("xxh3", content))
			:attr("data-from", titleArg))
	end
end

return p
