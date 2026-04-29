local p = {}

local html = mw.html

local months_full = {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'}

function p.draw(frame)
    local args = frame:getParent().args
    local target_year = args[1] or os.date("%Y")
    local current_month_name = args[2] or ""

    local container = html.create('div')
        :addClass('ow-month-nav')

    local meta = ''
    local precontent = ''


    if current_month_name and current_month_name ~= '' then
        meta = '{{DISPLAYTITLE:Obbies released in ' .. current_month_name .. ' of ' .. target_year .. '}}{{SHORTDESC:View all documented obbies on the Obby Wiki only released in ' .. current_month_name .. ' of ' .. target_year .. '}}'
        precontent = 'This category contains all obbies created/released (that are documented on this wiki and) that were created in \'\'\'' ..  current_month_name .. '\'\'\' of \'\'\'' .. target_year .. '\'\'\' alone.'
    end

    for i, month in ipairs(months_full) do
        local count = 0

        if mw.ext.cargo and mw.ext.cargo.query then
            local data = mw.ext.cargo.query('Obbies', 'COUNT(*)=count', {
                where = "month='" .. tostring(i) .. "' AND year='" .. target_year .. "'"
            })
            if data and data[1] then
                count = tonumber(data[1].count) or 0
            end
        end

        local isActive = (month:lower() == current_month_name:lower())
        local isEmpty = (count == 0)

        local card = container:tag('div')

        card:addClass('ow-month-card')
        if isActive then card:addClass('ow-month-card is-active') end
        if isEmpty then card:addClass('ow-month-card is-empty') end

        card:tag('div')
            :addClass('ow-month-card__label')
            :wikitext(month .. ' ' .. target_year)

        card:tag('div')
            :addClass('ow-month-card__count')
            :wikitext(count == 1 and count .. ' obby' or count .. ' obbies')

        card:tag('span')
            :addClass('ow-month-card__link')
            :wikitext('[[:Category:' .. month .. '_' .. target_year .. ' ]]')
    end

    local years_container = html.create('div')
        :addClass('ow-month-nav-years')

    for _, v in pairs({'2026','2025','2024','2023','2022','2021','2020','2019','2018'}) do
        local card = years_container:tag('div')

        card:addClass('ow-year-card')
            :wikitext(v)

        card:tag('span')
            :addClass('ow-month-card__link')
            :wikitext('[[:Category:' .. current_month_name .. '_' .. v .. ' ]]')
    end

    return frame:extensionTag('templatestyles', '', { src = 'Template:MonthNav/styles.css' }) .. frame:preprocess(meta) .. precontent .. tostring(container) .. '\n' .. tostring(years_container)
end

return p