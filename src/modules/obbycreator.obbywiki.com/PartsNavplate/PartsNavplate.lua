local p = {}

local navplate = require( 'Module:Navplate' )

local cargo = mw.ext.cargo

local function render()
    local data = {
        {
            ['type'] = 'Basic Parts',
            ['parts'] = {
                'All Basic Parts',
            }
        },

        {
            ['type'] = 'Advanced Parts',
            ['parts'] = {
                'Advanced Tools Part',
                'Button',
                'Button Deactivator',
                'Checkpoint',
                'Conveyor',
                'Fading Part',
                'Falling Part',
                'Gear Part',
                'Gear Remover Part',
                'Global Properties Part',
                'Heal Part',
                'Jump Pad',
                'Lava',
                'Load Part',
                'Music Part',
                'Music Zone',
                'Pressure Plate',
                'Quiz Part',
                'Reset Part',
                'Respawn Part',
                'Seat Part',
                'Speed Pad',
                'Teleport Pad',
                'Timed Lava',
                'Timed Part',
                'Trip Part'
            }
        },

        {
            ['type'] = 'Moving Parts',
            ['parts'] = {
                'Push Block',
                'Push Ball',
                'Lava Push Block',
                'Push Corner Wedge',
                'Push Corner Wedge',
                'Push Corner Cylinder',
                'Moving Part',
                'Moving Fading Part',
                'Moving Conveyor',
                'Moving Lava',
                'Moving Timed Part',
                'Moving Trip Part',
                'Spin Part',
                'Spin Conveyor',
                'Spin Fading Part',
                'Spin Lava',
                'Spin Timed Part',
                'Spin Trip Part',
            }
        },

        {
            ['type'] = 'Cart Rides',
            ['parts'] = {
                'Cart Spawner Rail',
                'Corner Track',
                'Ramp Track',
                'Slow Ramp Track',
                'Straight Track',
                'Straight Track with Bump'
            }
        },

        {
            ['type'] = 'Special',
            ['parts'] = {
                'Character Model',
                'Mannequin'
            }
        },

        {
            ['type'] = 'PreMades',
            ['parts'] = {
                'Obstacle PreMades',
                'Decoration PreMades',
                'Hardcore PreMades',
                'Other PreMades',
                'PreMades'
            }
        }
    }

    local grouping = {}
    local types = {}

    for _, row in ipairs( data ) do
        local label = row.type or 'Other Parts'
        if not grouping[label] then
            grouping[label] = {}
            table.insert( types, label )
        end

        for _, part in ipairs( row.parts ) do
            local link = '[[' .. part .. ']]'
            table.insert( grouping[label], link )
        end
    end

    local items = {}
    for _, label in ipairs( types ) do
        table.insert( items, {
            label = label,
            pages = table.concat( grouping[label], '' )
        } )
    end

    return navplate.fromData( { 
        title = 'All Parts',
        subtitle = "Obby Creator Wiki",
        id = 1,
        items = items
     } )
end

function p.main( frame )
    return render()
end

return p