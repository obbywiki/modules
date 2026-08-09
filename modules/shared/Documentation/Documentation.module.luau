--!strict

local p = {}

local libutil = require('libraryUtil')
local mbox = require( 'Module:Mbox' )._mbox

function p.doc( frame )
    local title = mw.title.getCurrentTitle()
    local args = frame:getParent().args
    local page = args[1]

    local page_type = title.namespace == 828 and 'module' or 'template'

    return mbox(
        'This is a test header',
        'with a test description',
        { icon = 'WikimediaUI-Code.svg' }
    )
end

function p.main ( frame )
    return p.doc(frame)
end

return p