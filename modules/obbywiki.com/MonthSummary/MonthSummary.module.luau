local p = {}

-- local html = mw.html

local months_full = {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'}

function p.draw(frame)
    local args = frame:getParent().args
    local target_year = args[1] or os.date("%Y")
    local current_month_name = args[2] or ""

    if not target_year or not current_month_name or not table.find(months_full, target_year) then
        return 'Error: Either an invalid year or an invalid month was provided to the MonthSummary template.'
    end

    if not mw.ext.cargo or not mw.ext.cargo.query then return 'Error' end

    local month_data = mw.ext.cargo.query('Obbies', '_pageName=name, visits, subgenre', {
        where = "month='" .. current_month_name .. "' AND year='" .. target_year .. "'",
        orderBy = "visits DESC",
        limit = 30
    })

    if not month_data or #month_data == 0 then
        return 'No relevant data for this month to display.'
    end

    local single_release = #month_data == 1

    local releases_by_subgenre = {}

    for _, v in pairs(month_data) do
        if v and v.subgenre then
            if releases_by_subgenre[v.subgenre] then 
                releases_by_subgenre[v.subgenre] += 1
            else
                releases_by_subgenre[v.subgenre] = 1
            end
        end
    end



    return `= Summary =\n\nThere {single_release and 'was' or 'were'} {#month_data} {single_release and 'obby' or 'obbies'} released in {current_month_name} of {target_year}`
end

return p