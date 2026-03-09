local p = {}

local function renderFAQ(frame, question, answer)
    return frame:expandTemplate{
        title = 'FAQ',
        args = {
            question = question,
            answer = answer
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
            string.format('%s features a total of %s stages for players to complete.', obby_name_cap, data.stages)
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
            string.format('%s is a %s type obby.', obby_name_cap, data.subgenre)
        ))
    end
    
    if data.avatar_type and data.avatar_type ~= '' and data.avatar_type ~= 'N/A' then
        local avatarInfo = data.avatar_type
        if avatarInfo:lower() == 'r6' then
            avatarInfo = 'the classic R6'
        elseif avatarInfo:lower() == 'r15' then
            avatarInfo = 'the modern R15'
        end
        
        table.insert(faqs, renderFAQ(frame,
            string.format('What avatar type is recommended for %s?', obby_name),
            string.format('%s is designed for use with %s avatar rigs.', obby_name_cap, avatarInfo)
        ))
    end
    
    if data.year and data.year ~= '' then
        table.insert(faqs, renderFAQ(frame,
            string.format('When was %s released?', obby_name),
            string.format('%s first debuted in %s.', obby_name_cap, data.year)
        ))
    end
    
    return table.concat(faqs, '\n')
end

return p
