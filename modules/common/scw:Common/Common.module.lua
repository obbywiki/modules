local common = {}

--- Convert an input to number
---@param num string|integer Input
---@param onFail string|integer Output if conversion fails
---@param base integer Base for tonumber, defaults to 10
---@return number
function common.toNumber( num, onFail, base )
	base = base or 10

    if num == nil then
        return onFail
    end

    return tonumber( num ) or onFail
end

--- Formats a number according to the content language
---@param num number|string
function common.formatNum( num, onFail )
    local converted = common.toNumber( num, false )

    if converted == nil or converted == false then
    	return onFail or false
	end

    local converted = mw.language.getContentLanguage():formatNum( converted )

    return string.gsub( converted, '−', '-' )
end

--- Removes (...) suffixes
---@param pageName string
---@param suffix string|table
function common.removeTypeSuffix( pageName, suffix )
    if type( suffix ) == 'table' then
        for _, toRemove in pairs( suffix ) do
            pageName = common.removeTypeSuffix( pageName, toRemove )
        end

        return pageName
    end

    return mw.text.trim( pageName:gsub( '%(' .. suffix .. '%)', '' ), '_ ' )
end

--- Create interwiki links for a given title
---@param pageName string
function common.generateInterWikiLinks( pageName )
	if pageName == nil or #pageName == '' then
		return ''
	end

	local prefixes = { 'de', 'zh' }
	local suffixes = {}

	local out = ''

	for _, prefix in pairs( prefixes ) do
		local page = common.removeTypeSuffix( pageName, suffixes )
		out = out .. string.format( '[[%s:%s]]', prefix, page )
	end
	
	return out
end

--- Checks if Setting SMW Data was successful
---@param result table
function common.checkSmwResult( result )
	if result == nil then
        return
	end

    if result ~= true and result.error ~= nil then
        error( 'Semantic Mediawiki error ' .. result.error )
    end
end

--- Checks if Api Request was successful and if the Response is valid
---@param response table
---@param errorOnData boolean
---@param errorOnData boolean
---@return boolean
function common.checkApiResponse( response, errorOnStatus, errorOnData )
    if response[ 'status_code' ] ~= nil and response[ 'status_code' ] ~= 200 then
        if errorOnStatus == nil or errorOnStatus == true then
            error( 'API request returns the error code ' .. response[ 'status_code' ] .. '(' .. response[ 'message' ] .. ')', 0 )
        end
        return false
    end

    if response[ 'data' ] == nil then
        if errorOnData == nil or errorOnData == true then
            error( 'API data does not contain a "data" field', 0 )
        end
        return false
    end
    return true
end

--- Walks a table in order, can be used like pairs()
---@param t table
---@param order function - Sorting function OPTIONAL
function common.spairs( t, order )
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

--- Alternative for doing table[key][key], this returns nil instead of an error if it doesn't exist
---@param object table?
---@param ... string
function common.safeAccess( object, ... )
    local value = object
    if not value then return end
    for _, key in ipairs( { ... } ) do
        value = value[ key ]
        if value == nil then return nil end
    end
    return value
end

--- Split a string with seperator
---@param str string Input string
---@param sep string Seperator
---@return table<string>
function common.split( str, sep )
    local matches = {}
    for matchedString in string.gmatch( str, '([^' .. sep .. ']+)' ) do
        table.insert( matches, string.gsub( matchedString, '%b()', '' ) or '' )
    end
    return matches
end

--- Remove parentheses and their content
--- Primairly used for starmap related things, such as making `TrueName (OldName)` > `TrueName`
---@param inputString string
---@return string
function common.removeParentheses( inputString )
    return string.match( string.gsub( inputString, '%b()', '' ), '^%s*(.*%S)' ) or ''
end

--- Trim a string
---@param str string
---@return string
function common.trim( str )
    return string.match( str, '([^:%(%s]+)' )
end

--- Uses Module:Pluralize to pluralize a string
---@param str string
---@return string
function common.pluralize( str )
    return require( 'Module:Pluralize' ).pluralize( { args = { str } } )
end

--- Returns a table containing the numbers of the arguments that exist
--- for the specified prefix. For example, if the prefix was 'data', and
--- 'data1', 'data2', and 'data5' exist, it would return {1, 2, 5}.
---
--- @param prefix string Prefix of the argument name
--- @param args table Table of arguments
--- @return table Table of argument numbers
function common.getArgNums(prefix, args)
	local nums = {}
	for k, v in pairs(args) do
		local num = tostring(k):match('^' .. prefix .. '([1-9]%d*)$')
		if num then table.insert(nums, tonumber(num)) end
	end
	table.sort(nums)
	return nums
end

return common
