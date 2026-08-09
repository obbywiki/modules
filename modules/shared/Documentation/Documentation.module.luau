local p = {}

local libutil = require('libraryUtil')
local mbox = require( 'Module:Mbox' )._mbox

function p.doc( frame )
    local title = mw.title.getCurrentTitle()
    local args = require( 'Module:Arguments' ).getArgs( frame )

    local page_type = title.namespace == 828 and 'module' or 'template'

    local rets = {}

    if args.synced == true then
        table.insert(rets, mbox(
            `{title} is maintained and synced from the [https://github.com/obbywiki/modules OWSMT] repository on GitHub`,
            `This {page_type} is synced from the upstream OWSMT repository. Any changes should be made or proposed on GitHub, as upstream changes will overwrite any changes here.`,
            { icon = 'WikimediaUI-Code.svg' }
        ))
    end

    return table.concat(rets)
end

function p.main ( frame )
    return p.doc(frame)
end

return p