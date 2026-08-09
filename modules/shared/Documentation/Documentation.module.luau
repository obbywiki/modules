local p = {}

local libutil = require('libraryUtil')
local mbox = require( 'Module:Mbox' )._mbox

function p.doc( frame )
    local title = mw.title.getCurrentTitle()
    local args = require( 'Module:Arguments' ).getArgs( frame )

    local page_type = title.namespace == 828 and 'module' or 'template'

    local rets = {}

    if args.synced then
        table.insert(rets, mbox(
            `'''{title}''' is maintained and synced from the [https://github.com/obbywiki/modules OWSMT] repository on GitHub.`,
            `This {page_type} is synced from the upstream OWSMT repository. Any changes should be made or proposed on GitHub, as upstream changes will overwrite any changes here.`,
            { icon = 'WikimediaUI-Code.svg' }
        ))
    end

    if args.luau then
        table.insert(rets, mbox(
            `'''{title}''' was automatically transpiled from Luau.`,
            `This module was originally written in Luau. The code on this page was transpiled from the original Luau source code to be compatible with Lua 5.1.5. Transpilated code is not intended to be viewed by humans, and reading it may be difficult. Language features such as types and comments have been removed. Please view the module's original code on [https://github.com/obbywiki/modules GitHub].`,
            { icon = 'Luau.svg' }
        ))
    end

    if args.important then
        table.insert(rets, mbox(
            `'''{title}''' is heavily used across the Obby Wiki.`,
            `This {page_type} has been marked as important. A breaking change could damage the functionality of the Obby Wiki largely. Be careful when making edits.`,
            { icon = 'WikimediaUI-Code.svg' }
        ))
    end

    return table.concat(rets)
end

function p.main ( frame )
    return p.doc(frame)
end

return p