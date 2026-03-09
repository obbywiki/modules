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
        'name, creator, developers, stages, tier, subgenre, avatar_type, year, month, day, is_public',
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

    if data.year and data.month then
        local current_timestamp = os.time()
        local time = os.time({year = tonumber(data.year or 0), month = tonumber(data.month or 0), day = tonumber(data.day or 1)})

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
    
    -- Question 1: Creator/Developer
    local creator_answer = string.format('\'\'\'%s\'\'\' was developed by %s and was initially released on the Roblox platform in %s of %s (approximately %s).', obby_name_cap, page_exists(creator_name) and '[[' .. creator_name .. ']]' or ("'''" .. creator_name .. "'''"), month_by_index(data.month), data.year, created_relative)
    if dev_list then
        creator_answer = creator_answer .. ' The game was created with additional development contributions from \'\'\'' .. dev_list .. '\'\'\'.'
    end
    
    table.insert(faqs, renderFAQ(frame, 
        string.format('Who is the developer of %s?', obby_name),
        creator_answer
    ))

    -- Question 2: How to play
    local is_public = data.is_public == '1' or data.is_public == true or data.is_public == 'yes'
    local play_answer = string.format('You can play \'\'\'%s\'\'\' for free on Roblox. The game is %s to the public, meaning anyone with a Roblox account can join and start playing. Simply search for the game title on the Roblox website or mobile app to begin your adventure. Alternatively, you can directly click %s to reach the Roblox page.', obby_name, is_public and 'currently open' or 'currently set to private or unlisted', '[https://roblox.com/games/' .. data.id .. '/ this link]')
    
    table.insert(faqs, renderFAQ(frame,
        string.format('How do I play %s on Roblox?', obby_name),
        play_answer
    ))
    
    -- Question 3: Stages/Levels
    if data.stages and data.stages ~= '' and tonumber(data.stages) ~= 0 then
        table.insert(faqs, renderFAQ(frame,
            string.format('How many stages (levels) are in %s?', obby_name),
            string.format('Selection from our database indicates that \'\'\'%s\'\'\' features a total of %s unique stages for players to complete. Each stage presents different platforming challenges that increase in difficulty as you progress.', obby_name_cap, data.stages)
        ))
    end
    
    -- Question 4: Tier/Difficulty
    if data.tier and data.tier ~= '' and data.tier ~= '0' then
        local subgenre = (data.subgenre and data.subgenre ~= '') and data.subgenre or 'obby'
        table.insert(faqs, renderFAQ(frame,
            string.format('What is the official difficulty tier for %s?', obby_name),
            string.format('\'\'\'%s\'\'\' is officially classified as a **Tier %s** %s. This tier rating helps players understand the level of skill and precision required to finish the game compared to other experiences on the Obby Wiki. The higher the tier, the harder the obby. See more information on the [[Tiers]] page.', obby_name_cap, data.tier, subgenre)
        ))
    elseif data.subgenre and data.subgenre ~= '' then
        table.insert(faqs, renderFAQ(frame,
            string.format('What type of obby subgenre is %s?', obby_name),
            string.format('\'\'\'%s\'\'\' is falls under the sub-genre of a "\'\'\'%s\'\'\'". This category describes the specific gameplay style and mechanics you can expect when playing.', obby_name_cap, page_exists(data.subgenre) and '[[' .. data.subgenre .. ']]' or data.subgenre)
        ))
    end
    
    -- Question 5: Avatar Type
    if data.avatar_type and data.avatar_type ~= '' and data.avatar_type ~= 'N/A' then
        local avatar_ending = data.avatar_type
        local avatar_details = ''
        if avatar_ending:lower() == 'r6' then
            avatar_details = 'the classic \'\'\'R6\'\'\' avatar rigs. R6 avatars are a staple in the obby community due to their consistent physics and predictable movement, making them ideal for steady and enjoyable gameplay in obbies. This is typically a standard for most obby developers.'
        elseif avatar_ending:lower() == 'r15' then
            avatar_details = 'the modern \'\'\'R15\'\'\' avatar rigs. This rig offers more articulation but is less common in traditional obbies as it can sometimes introduce variable physics during jumps.'
        elseif avatar_ending:lower() == 'choice' then
            avatar_details = 'whichever avatar type the player prefers (**R6 or R15**). This flexibility allows you to use your personal avatar settings while navigating the game\'s obstacles.'
        else
            avatar_details = string.format('the %s avatar rig system.', avatar_ending)
        end
        
        table.insert(faqs, renderFAQ(frame,
            string.format('Does %s use R6 or R15 Roblox avatars?', obby_name),
            string.format('\'\'\'%s\'\'\' is specifically designed for use with %s', obby_name_cap, avatar_details)
        ))
    end
    
    if data.year and data.year ~= '' then
        table.insert(faqs, renderFAQ(frame,
            string.format('When was %s released?', obby_name),
            string.format('\'\'\'%s\'\'\' was first released in %s of %s, around %s.%s', obby_name_cap, month_by_index(data.month), data.year, created_relative, (data.visits and string.format(' Since then, %s has received a total of %s visits.', obby_name_cap, data.visits) or ''))
        ))
    end

    if data.creator and page_exists(data.creator) then
        table.insert(faqs, renderFAQ(frame,
            string.format('Where can I find more obbies created by %s?', creator_name),
            string.format('If you enjoy playing \'\'\'%s\'\'\', you can find a full list of other games and projects by %s on their dedicated wiki page: %s. This is the best place to discover similar projects by them as well as more information and keep up with their latest releases.', obby_name_cap, creator_name, '[[' .. creator_name .. ']]'),
            true,
            creator_name
        ))
    end
    
    return table.concat(faqs, '\n')
end

return p
