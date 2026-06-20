local p = {}

local navplate = require( 'Module:Navplate' )

local function render()
    return navplate.fromData( { 
        title = 'Other Wikis',
        subtitle = "[[List of all known obby-related wikis|Obby-related wikis by year]]",
        id = 1,
        items = {
            {
                label = '2019',
                pages = '[[Eternal Towers of Hell Wiki]]'
            },
            {
                label = '2022',
                pages = "[[Roblox Difficulty Chart Obby Wiki]][[Aek's Hellscape Steeples Wiki]]"
            }
        }
     } )
end

function p.main()
    return render()
end

return p