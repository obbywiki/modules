-- EXPERIMENTAL BY @WLFT
-- Scribunto Lua 5.1


local p = {}

local html = mw.html

-- only in lua 5.1, honestly feels like they just made it up that it wasnt in this release randomly to spite me
function find(tbl, val)
    for key, value in pairs(tbl) do
        if value == val then
            return key
        end
    end
    return nil
end

function split_by_comma(inputstr)
    local t = {}
    for str in string.gmatch(inputstr, "([^,]+)") do
        table.insert(t, str)
    end
    return t
end

local function format_expiry_date(date_str)
    if not date_str or date_str == '' or date_str == 'never' or date_str == '0' then
        return "<i>No Expiry</i>"
    end

    date_str = mw.text.trim(date_str)

    local iso = date_str
    if date_str:match('^%d%d%d%d%-%d%d%-%d%d$') then
        -- Default to end of day for date-only expiry
        iso = date_str .. 'T23:59:59+00:00'
    elseif date_str:match('^%d%d%d%d%-%d%d%-%d%d%s+%d%d:%d%d$') then
        local d, t = date_str:match('^(%d%d%d%d%-%d%d%-%d%d)%s+(%d%d:%d%d)$')
        iso = d .. 'T' .. t .. ':00+00:00'
    end

    local lang = mw.getContentLanguage()
    local has_time = not date_str:match('^%d%d%d%d%-%d%d%-%d%d$')
    local fmt = has_time and 'j F Y, H:i (\U\T\C)' or 'j F Y'

    local s, res = pcall(lang.formatDate, lang, fmt, iso, true)

    if s then
        local s_ts, ts_str = pcall(lang.formatDate, lang, 'U', iso, true)
        if s_ts then
            local expiry_ts = tonumber(ts_str)
            if expiry_ts and os.time() > expiry_ts then
                return '<s>' .. res .. '</s>'
            end
        end
        return res
    else
        return date_str
    end
end

local function build_table(opt, exc_args)
    local tbl = html.create("table")
        :addClass("wikitable sortable plainlinks")
        :addClass("mw-collapsible mw-made-collapsible wikitable--fluid")
        :css("width", "100%")

    tbl:tag('caption')
        :wikitext(opt.i and '[[File:' .. opt.i .. '|20px]] ' or '')
        :wikitext(opt.n and opt.n .. ' Codes&nbsp;' or 'Codes&nbsp;')

     local thead = tbl:tag("tr")
     thead:tag("th"):wikitext("Code")
     thead:tag("th"):wikitext("Expires")
     thead:tag("th"):wikitext("Reward")

     for i, v in pairs(exc_args) do
        if v ~= nil and type(v) == 'string' and not find({'root_place_id', 'start_place_id', 'name', 'icon'}, i) then
            local row = tbl:tag("tr")

            local res = split_by_comma(v)

            if res then
                if res[1] then
                    row:tag("td"):wikitext('<code>' .. res[1] .. '</code>')
                end

                if res[2] then
                    row:tag("td"):wikitext(format_expiry_date(res[2]))
                end

                if res[3] then
                    row:tag("td"):wikitext(res[3])
                end
            end
        end
     end

     return tostring(tbl)
end

function p.render(frame)
    local args = frame:getParent() and frame:getParent().args or frame.args

    local optional_root_place_id = args.root_place_id or args.start_place_id or 0
    local optional_name = args.name or ''
    local optional_icon = args.icon or ''

    local exc_args = args

    if exc_args['root_place_id'] then exc_args['root_place_id'] = nil end
    if exc_args['start_place_id'] then exc_args['start_place_id'] = nil end
    if exc_args['name'] then exc_args['name'] = nil end
    if exc_args['icon'] then exc_args['icon'] = nil end

    return build_table({r = optional_root_place_id, n = optional_name, i = optional_icon}, exc_args)
end

return p