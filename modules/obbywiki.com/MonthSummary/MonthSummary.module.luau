local p = {}

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
                releases_by_subgenre[v.subgenre].count += 1

                if v.visits then
                    releases_by_subgenre[v.subgenre].visits += v.visits

                    if tonumber(v.visits) > releases_by_subgenre[v.subgenre].mpo_visits then
                        releases_by_subgenre[v.subgenre].mpo_visits = tonumber(v.visits)
                        releases_by_subgenre[v.subgenre].mpo = v.name
                    end
                end
            else
                releases_by_subgenre[v.subgenre] = {count = 1; visits = tonumber(v.visits) or 0; mpo_visits = tonumber(v.visits) or 0; mpo = v.name}
            end
        end

        if v.name and v.visits then
            if tonumber(v.visits) > most_popular_obby.visits then
                most_popular_obby.name = v.name
                most_popular_obby.visits = tonumber(v.visits)
                most_popular_obby.creator = v.creator
                if v.day then
                    most_popular_obby.day = v.day
                else
                    most_popular_obby.day = 0
                end
            end
        end
    end

    local stbl = mw.html.create('table')
        :addClass("wikitable sortable plainlinks")
		:addClass("mw-collapsible mw-made-collapsible wikitable--fluid")
		:css("width", "100%")

    local thead = stbl:tag('tr')
        :tag('th'):wikitext('Sub-genre')
        :tag('th'):wikitext('Total')
        :tag('th'):wikitext('Visits')
        :tag('th'):wikitext('Most Popular Obby')

    for i, v in pairs(releases_by_subgenre) do
        local row = stbl:tag('tr')


        row:tag('td'):wikitext(`[[{i}]]`)
        row:tag('td'):wikitext(v.count)
        row:tag('td'):wikitext(get_comma_val(v.visits))
        row:tag('td'):wikitext(`[[{v.mpo}]] ({get_comma_val(v.mpo_visits)} visits)`)
    end

    local most_frequent_subgenre, most_popular_subgenre

    local most_frequent_subgenre_count, most_popular_subgenre_visits = 0, 0

    local subgenre_release_count = 0

    for i, v in pairs(releases_by_subgenre) do
        if v.count > most_frequent_subgenre_count then
            most_frequent_subgenre_count = v.count
            
            most_frequent_subgenre = {count = v.count, _index = i}
        end

        if tonumber(v.visits) > most_popular_subgenre_visits then
            most_popular_subgenre_visits = tonumber(v.visits)

            most_popular_subgenre = {visits = tonumber(v.visits), _index = i}
        end

        subgenre_release_count += 1
    end

    return `=Summary=\n\nThere {single_release and 'was' or 'were'} {#month_data} {single_release and 'obby' or 'obbies'} released in {current_month_name} of {target_year}, with the most popular obby released being [[{most_popular_obby.name}]] by [[{most_popular_obby.creator}]] with '''{get_comma_val(tostring(most_popular_obby.visits))} visits''' {most_popular_obby.day ~= 0 and ` that was released on the {most_popular_obby.day}{most_popular_obby.day==1 and 'st' or most_popular_obby.day==2 and 'nd' or most_popular_obby.day==3 and 'rd' or 'th'} of {current_month_name}` or ''}.\n\n{(mw.html.create('h2'):wikitext('Releases by Sub-genre'))}\nThis month saw {subgenre_release_count} {subgenre_release_count==1 and 'sub-genre' or 'different sub-genres'} with the most frequent sub-genre of {current_month_name} {target_year} being [[{most_frequent_subgenre._index}]] with a total of {most_frequent_subgenre.count} {most_frequent_subgenre.count==1 and 'obby' or 'obbies'} in that sub-genre released with-in the month. The sub-genre that received the most visits was {most_frequent_subgenre._index==most_popular_subgenre._index and 'also'} the [[{most_popular_subgenre._index}]] sub-genre with a total of '''{get_comma_val(tostring(most_popular_subgenre.visits))} visits''' between all obbies in that sub-genre of the month. See the full list below:\n{tostring(stbl)}\n\n`
end

return p