export type frame_args = { [string | number] : string }

export type frame_parser_value = {
	expand : (self : frame_parser_value) -> string,
}

export type frame = {
	args : frame_args,
	getParent : (self : frame) -> frame?,
	getTitle : (self : frame) -> string,
	preprocess : (self : frame, text : string | { text : string }) -> string,
	expandTemplate : (self : frame, options : { title : string, args : frame_args? }) -> string,
	extensionTag : (
		self : frame,
		name : string | { name : string, content : string?, args : frame_args? },
		content : string?,
		args : frame_args?
	) -> string,
	callParserFunction : (self : frame, name : string | { name : string, args : frame_args? }, ...any) -> string,
	newChild : (self : frame, options : { title : string?, args : frame_args? }) -> frame,
	getArgument : (self : frame, arg : string | number | { name : string | number }) -> frame_parser_value?,
	newParserValue : (self : frame, text : string | { text : string }) -> frame_parser_value,
	newTemplateParserValue : (self : frame, options : { title : string, args : frame_args? }) -> frame_parser_value,
	argumentPairs : (self : frame) -> () -> (string | number?, string?),
}

export type mock_frame_opts = {
	args : frame_args?,
	parent : frame?,
	parent_args : frame_args?,
	title : string?,
}

local function parser_value(text : string) : frame_parser_value
	return {
		expand = function(_self : frame_parser_value) : string
			return text
		end,
	}
end

local function preprocess_text(text : string | { text : string }) : string
	if type(text) == 'table' then
		return text.text
	end
	return text
end

local frame_mock = {}

function frame_mock.mock(opts : mock_frame_opts?) : frame
	local options : mock_frame_opts = opts or {}
	local args = options.args or {}
	local parent = options.parent

	if parent == nil and options.parent_args ~= nil then
		parent = frame_mock.mock({
			args = options.parent_args,
			title = 'Template:AlsoBy',
		})
	end

	local this : frame
	this = {
		args = args,
		getParent = function(_self : frame) : frame?
			return parent
		end,
		getTitle = function(_self : frame) : string
			return options.title or 'Module:AlsoBy'
		end,
		preprocess = function(_self : frame, text : string | { text : string }) : string
			return preprocess_text(text)
		end,
		expandTemplate = function(_self : frame, expand_opts : { title : string, args : frame_args? }) : string
			return '{{expand:' .. expand_opts.title .. '}}'
		end,
		extensionTag = function(
			_self : frame,
			name : string | { name : string, content : string?, args : frame_args? },
			content : string?,
			_tag_args : frame_args?
		) : string
			if type(name) == 'table' then
				return `<{name.name}>{name.content or ''}</{name.name}>`
			end
			return `<{name}>{content or ''}</{name}>`
		end,
		callParserFunction = function(
			_self : frame,
			name : string | { name : string, args : frame_args? },
			... : any
		) : string
			if type(name) == 'table' then
				return '{{#' .. name.name .. '}}'
			end
			return '{{#' .. name .. '}}'
		end,
		newChild = function(_self : frame, child_opts : { title : string?, args : frame_args? }) : frame
			return frame_mock.mock({
				args = child_opts.args,
				title = child_opts.title,
				parent = this,
			})
		end,
		getArgument = function(_self : frame, arg : string | number | { name : string | number }) : frame_parser_value?
			local key : string | number = if type(arg) == 'table' then arg.name else arg
			local value = args[key]
			if value == nil then
				return nil
			end
			return parser_value(value)
		end,
		newParserValue = function(_self : frame, text : string | { text : string }) : frame_parser_value
			return parser_value(preprocess_text(text))
		end,
		newTemplateParserValue = function(
			_self : frame,
			expand_opts : { title : string, args : frame_args? }
		) : frame_parser_value
			return parser_value('{{expand:' .. expand_opts.title .. '}}')
		end,
		argumentPairs = function(_self : frame) : () -> (string | number?, string?)
			return pairs(args) :: any
		end,
	}

	return this
end

return frame_mock
