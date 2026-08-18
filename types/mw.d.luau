-- scribunto globals
-- sync with:
-- - types/mw/frame.luau
-- - https://doc.wikimedia.org/scribunto/latest/scribunto.html

export type frame_args = { [string | number] : string }

export type frame_parser_value = {
	expand : (self : frame_parser_value) -> string,
}

export type cargo_query_options = {
	where : string?,
	join : string?,
	groupBy : string?,
	having : string?,
	orderBy : string?,
	limit : (number | string)?,
	offset : (number | string)?,
}

export type cargo_query_result = { { [string] : string } }

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
	callParserFunction : (
		self : frame,
		name : string | { name : string, args : frame_args? },
		...any
	) -> string,
	newChild : (self : frame, options : { title : string?, args : frame_args? }) -> frame,
	getArgument : (self : frame, arg : string | number | { name : string | number }) -> frame_parser_value?,
	newParserValue : (self : frame, text : string | { text : string }) -> frame_parser_value,
	newTemplateParserValue : (self : frame, options : { title : string, args : frame_args? }) -> frame_parser_value,
	argumentPairs : (self : frame) -> () -> (string | number?, string?),
}

declare mw : {
	ext : {
		cargo : {
			query : ( tables : string, fields : string, options : cargo_query_options? ) -> cargo_query_result,
		},
		jsonld : {
			setMainEntity : ( args : { [string] : any } ) -> void,
			addData : ( args : { [string] : any } ) -> void,
		}
	},
	getCurrentFrame : () -> frame,
}
