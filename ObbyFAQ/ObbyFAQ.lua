local p = {}

local function renderFAQ(frame, question, answer, render_also_by, creator_name)
    return frame:expandTemplate{
        title = 'FAQ',
        args = {
            question = question,
            answer = answer .. (render_also_by and frame:preprocess('{{AlsoBy|' .. creator_name .. '}}') or '')
        }
    }
end

local function capitalize(str)
    return (str:gsub("^%l", string.upper))
end

local months_full = {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'}

local function month_by_index(month)
	local monthnum = tonumber(month)

	if not monthnum then return 'N/A' end

	return months_full[monthnum] or 'N/A'
end

local function page_exists(page_title)
    local title = mw.title.new(page_title)
    return title and title.exists
end

function p.main(frame)
    local args = require('Module:Arguments').getArgs(frame)
    local pageName = args.page or mw.title.getCurrentTitle().text
    
    local results = mw.ext.cargo.query(
        'Obbies',
        'name, creator, developers, stages, tier, subgenre, avatar_type, year, month',
        {
            where = '_pageName="' .. pageName .. '"',
            limit = 1
        }
    )
    
    if not results or #results == 0 then
        return '<!-- No ObbyFAQ data found for ' .. pageName .. ' -->'
    end
    
    local data = results[1]
    local faqs = {}
    local obby_name = data.name or pageName
    local obby_name_cap = capitalize(obby_name)

    if not data.year then data.year = 2025 end
    if not data.month then data.month = 1 end
    
    local creator_name = (data.creator and data.creator ~= '') and data.creator or 'an unknown developer'
    local dev_list = (data.developers and data.developers ~= '') and data.developers or nil

    local created_relative

    -- e.g., less than a year ago

    if data.year and data.month then
        local current_timestamp = os.time()
        local time = os.time({year = tonumber(data.year or 0), month = tonumber(data.month or 0), day = 1})

        local diff = current_timestamp - time
        local years = math.floor(diff / 31536000)
        local months = math.floor((diff % 31536000) / 2592000)

        if years > 0 then
            created_relative = string.format('%d year%s and %d month%s ago', years, years ~= 1 and 's' or '', months, months ~= 1 and 's' or '')
        elseif months > 0 then
            created_relative = string.format('%d month%s ago', months, months ~= 1 and 's' or '')
        else
            created_relative = 'less than a month ago'
        end
    end
    
    local creator_answer = string.format('\'\'\'%s\'\'\' was created by %s and was initially released by them approximately %s in %s of %s.', obby_name_cap, page_exists(creator_name) and '[[' .. creator_name .. ']]' or ("'''" .. creator_name .. "'''"), created_relative, month_by_index(data.month), data.year)
    if dev_list then
        creator_answer = creator_answer .. ' Additionally, it was developed with the help of ' .. dev_list .. '.'
    end
    
    table.insert(faqs, renderFAQ(frame, 
        string.format('Who created %s?', obby_name),
        creator_answer
    ))
    
    if data.stages and data.stages ~= '' and tonumber(data.stages) ~= 0 then
        table.insert(faqs, renderFAQ(frame,
            string.format('How many stages does %s have?', obby_name),
            string.format('As of now, %s features a total of %s stages for players to complete.', obby_name_cap, data.stages)
        ))
    end
    
    if data.tier and data.tier ~= '' and data.tier ~= '0' then
        local subgenre = (data.subgenre and data.subgenre ~= '') and data.subgenre or 'obby'
        table.insert(faqs, renderFAQ(frame,
            string.format('What is the difficulty tier of %s?', obby_name),
            string.format('%s is officially classified as a **Tier %s** %s.', obby_name_cap, data.tier, subgenre)
        ))
    elseif data.subgenre and data.subgenre ~= '' then
        table.insert(faqs, renderFAQ(frame,
            string.format('What type of obby is %s?', obby_name),
            string.format('%s is classed in the sub-genre of a "\'\'\'%s\'\'\'".', obby_name_cap, page_exists(data.subgenre) and '[[' .. data.subgenre .. ']]' or data.subgenre)
        ))
    end
    
    if data.avatar_type and data.avatar_type ~= '' and data.avatar_type ~= 'N/A' then
        local avatar_ending = data.avatar_type
        if avatar_ending:lower() == 'r6' then
            avatar_ending = 'the classic R6 avatar rigs. While they support less customizability, they are used frequently in obbies for their simplicity, consistency, and familiarity. This is a standard for most obbies.'
        elseif avatar_ending:lower() == 'r15' then
            avatar_ending = 'the modern R15 avatar rigs. This rig is rarely used in obbies and hints at either custom physics or poor playability.'
        elseif avatar_ending:lower() == 'choice' then
            avatar_ending = 'any avatar type. This allows players to use any avatar type they prefer, whether it be R6, R15, or any other avatar type. This means that whichever avatar type you use on your profile will be used in game for specifically you.'
        end
        
        table.insert(faqs, renderFAQ(frame,
            string.format('What avatar type does %s use?', obby_name),
            string.format('%s is designed for use with %s', obby_name_cap, avatar_ending)
        ))
    end
    
    if data.year and data.year ~= '' then
        table.insert(faqs, renderFAQ(frame,
            string.format('When was %s released?', obby_name),
            string.format('%s was first released in %s of %s, around %s.%s', obby_name_cap, month_by_index(data.month), data.year, created_relative, (data.visits and string.format(' Since then, %s has received a total of %s visits.', obby_name_cap, data.visits) or ''))
        ))
    end

    if data.creator and page_exists(data.creator) then
        table.insert(faqs, renderFAQ(frame,
            string.format('Where can I find additional obbies by %s?', creator_name),
            string.format('You can find any existing pages at the dedicated \'\'\'%s\'\'\' on the Obby Wiki.\n\n', '[[' .. creator_name .. ']]'),
            true,
            creator_name
        ))
    end
    
    return table.concat(faqs, '\n')
end

return p
