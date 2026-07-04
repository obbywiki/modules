--!strict

local p = {}

local libutil = require('libraryUtil')

function p.doc( frame )
    local title = mw.title.getCurrentTitle()
    local args = frame:getParent().args
    local page = args[1]

    local page_type = title.namespace == 828 and 'module' or 'template'
end