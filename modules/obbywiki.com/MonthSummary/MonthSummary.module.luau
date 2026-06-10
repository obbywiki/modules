local p = {}

-- local html = mw.html

local months_full = {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'}

local function get_comma_val(num)
	local formatted = num
	while true do  
		local k;

		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end

function p.draw(frame)
    local args = frame:getParent().args
    local target_year = args[1] or os.date("%Y")
    local current_month_name = args[2] or ""

    if not target_year or not current_month_name or not table.find(months_full, current_month_name) then
        return 'Error: Either an invalid year or an invalid month was provided to the MonthSummary template.'
    end

    if not mw.ext.cargo or not mw.ext.cargo.query then return 'Error' end

    local month_data = mw.ext.cargo.query('Obbies', '_pageName=name, visits, subgenre, creator, day', {
        where = "month='" .. tostring(table.find(months_full, current_month_name)) .. "' AND year='" .. target_year .. "'",
        orderBy = "visits DESC",
        limit = 30
    })

    if not month_data or #month_data == 0 then
        return 'No relevant data for this month to display.'
    end

    local single_release = #month_data == 1

    local releases_by_subgenre = {}
    local most_popular_obby = {name = ''; visits = 0; creator = '', day = 0}

    for _, v in pairs(month_data) do
        if v.subgenre then
            if releases_by_subgenre[v.subgenre] then 
                releases_by_subgenre[v.subgenre] += 1
            else
                releases_by_subgenre[v.subgenre] = 1
            end
        end

        if v.name and v.visits then
            if v.vists > most_popular_obby.visits then
                most_popular_obby.name = v.name
                most_popular_obby.visits = v.visits
                most_popular_obby.creator = v.creator
                if v.day then
                    most_popular_obby.creator = v.day
                end
            end
        end
    end

    return `= Summary =\n\nThere {single_release and 'was' or 'were'} {#month_data} {single_release and 'obby' or 'obbies'} released in {current_month_name} of {target_year}, with the most popular obby released being [[{most_popular_obby.name}]] by [[{most_popular_obby.creator}]] with {get_comma_val(most_popular_obby.visits)}{most_popular_obby.day and `releasing on the {most_popular_obby.day}{most_popular_obby.day==1 and 'st' or most_popular_obby.day==2 and 'nd' or most_popular_obby.day==3 and 'rd' or 'th'}` or ''}.`
end

return p