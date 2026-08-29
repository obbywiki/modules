local p = {}

local libutil = require('libraryUtil')
local mbox = require( 'Module:Mbox' )._mbox
local hatnote = require( 'Module:Hatnote' )._hatnote

local function styles(frame)
    return frame:extensionTag('templatestyles', '', { src = 'Module:Documentation/styles.css' })
end

local function resolve_pages(title)
    if title.subpageText == 'doc' then
        return title.basePageTitle, title
    end

    return title, mw.title.new(title.fullText .. '/doc')
end

local function page_type_of(title)
    return title.namespace == 828 and 'module' or 'template'
end

local function make_header(subject, doc_page)
    local header = mw.html.create('div')
        :addClass('documentation-header')

    header:tag('span')
        :addClass('documentation-header__title')
        :wikitext('Documentation')

    local vte = header:tag('span')
        :addClass('documentation-header__vte')
        :addClass('noprint')
        :addClass('plainlinks')

    local talk = subject.talkPageTitle
    local talk_link = talk and ('[[' .. talk.fullText .. '|t]]') or 't'

    vte:wikitext(table.concat({
        '[[' .. doc_page.fullText .. '|v]]',
        ' · ',
        talk_link,
        ' · ',
        '[' .. doc_page:fullUrl({ action = 'edit' }) .. ' e]',
    }))

    return tostring(header)
end

function p.doc( frame )
    local title = mw.title.getCurrentTitle()
    local args = require( 'Module:Arguments' ).getArgs( frame )
    local subject, doc_page = resolve_pages(title)

    local page_type = page_type_of(subject)

    local banners = {}

    if args.imported or args.wikipedia then
        if args.imported == 'wikipedia' or args.wikipedia then
            table.insert(banners, mbox(
                `'''{title}''' was imported from [https://en.wikipedia.org/wiki/{title} {title}] on Wikipedia.`,
                `This {page_type} was imported from the English Wikipedia originally, but may contain modifications.`,
                { icon = 'WikimediaUI-Logo-Wikipedia.svg' }
            ))
        elseif args.imported == 'wikipedia-scw' then
            table.insert(banners, mbox(
                `'''{title}''' was imported from [https://en.wikipedia.org/wiki/{title} {title}] on Wikipedia.`,
                `This {page_type} was imported from the English Wikipedia originally, but may contain modifications. It may include additional contents (such as styles, translations, or other adjustments) from the [https://starcitizen.tools Star Citizen Wikis].`,
                { icon = 'WikimediaUI-Logo-Wikipedia.svg' }
            ))
        elseif args.imported == 'scw' or args.imported == 'starcitizenwiki' then
            table.insert(banners, mbox(
                `'''{title}''' was imported from [https://starcitizen.tools/{title} {title}] on the English Star Citizen Wiki.`,
                `This {page_type} was imported from the English Star Citizen Wiki originally, but may contain modifications.`,
                { icon = 'OOjs_UI_icon_download.svg' }
            ))
        elseif args.imported == 'rs' or args.imported == 'runescape' then
            table.insert(banners, mbox(
                `'''{title}''' was imported from [https://runescape.wiki/w/{title} {title}] on the Runescape Wiki.`,
                `This {page_type} was imported from the Runescape Wiki originally, but may contain modifications.`,
                { icon = 'OOjs_UI_icon_download.svg' }
            ))
        end
    end

    if args.synced then
        if args.owsmt_location then
            const owsmt_approx = `https://github.com/obbywiki/modules/blob/main/{page_type}s/{args.owsmt_location}`

            table.insert(banners, mbox(
                `'''{title}''' is maintained and synced from the [{owsmt_approx} OWSMT] repository on GitHub.`,
                `This {page_type} is synced from the upstream OWSMT repository. Any changes should be made or proposed on GitHub, as upstream changes will overwrite any changes here.`,
                { icon = 'WikimediaUI-Code.svg' }
            ))
        else
            table.insert(banners, mbox(
                `'''{title}''' is maintained and synced from the [https://github.com/obbywiki/modules OWSMT] repository on GitHub.`,
                `This {page_type} is synced from the upstream OWSMT repository. Any changes should be made or proposed on GitHub, as upstream changes will overwrite any changes here.`,
                { icon = 'WikimediaUI-Code.svg' }
            ))
        end
    end

    if args.agpl then
        table.insert(banners, mbox(
            `'''{title}''' is licensed under [https://obby.wiki/Obby_Wiki:Attributions AGPL v3].`,
            `This {page_type} was (likely) made by the Obby Wiki and is licensed under the [https://obby.wiki/Obby_Wiki:Attributions GNU Affero General Public License v3.0] and has its origin available publicly on the [https://github.com/obbywiki/modules OWSMT] repository on GitHub. However, the modules, templates, and other resources it may depend on are subject to their own licenses, especially resources that are imported.`,
            { icon = 'OOjs_UI_icon_key.svg' }
        ))
    end

    if args.luau then
        table.insert(banners, mbox(
            `'''{title}''' was automatically transpiled from Luau.`,
            `This module was originally written in Luau. The code on this page was transpiled from the original Luau source code to be compatible with Lua 5.1.5. Transpilated code is not intended to be viewed by humans, and reading it may be difficult. Language features such as types and comments have been removed. Please view the module's original code on [https://github.com/obbywiki/modules GitHub].`,
            { icon = 'Luau.svg' }
        ))
    end

    if args.important then
        table.insert(banners, mbox(
            `'''{title}''' is heavily used across the Obby Wiki.`,
            `This {page_type} has been marked as important. A breaking change could damage the functionality of the Obby Wiki largely. Be careful when making edits.`,
            { icon = 'OOjs_UI_icon_alert.svg' }
        ))
    end

    if mw.title.new( title.fullText .. '/styles.css' ).exists then
        table.insert(banners, hatnote(
            `'''{title}''' loads styles from [[{title.fullText}/styles.css]]`,
            { icon = 'WikimediaUI-Palette.svg' }
        ))
    end

    if page_type == 'module' then
        if mw.title.new( title.fullText .. '/i18n/en.json', 'Module' ).exists or mw.title.new( title.fullText .. '/i18n/qqq.json', 'Module' ).exists then
            table.insert(banners, mbox(
                `'''{title}''' has existing strings available.`,
                `This {page_type} has i18n strings associated with it.`,
                { icon = 'OOjs_UI_icon_language-ltr.svg' }
            ))
        end
    end

    table.insert(banners, styles(frame))
    table.insert(banners, make_header(subject, doc_page))

    return table.concat(banners)
end

function p.usage(frame)
    local args = require('Module:Arguments').getArgs(frame)
    local title = mw.title.getCurrentTitle()
    local subject = resolve_pages(title)
    local page_type = page_type_of(subject)

    local name = args.name or subject.text
    local description = args.description
    local when_to_use = args.when_to_use or args.when or args['when to use']
    local placement = args.where or args.placement or args.position
    local usage = args.usage

    local table_el = mw.html.create('table')
        :addClass('wikitable wikitable--fluid mw-collapsible mw-made-collapsible plainlinks')
        :addClass('documentation-usage')

    table_el:tag('caption'):wikitext('Overview')

    local function add_row(label, value, bold)
        if not value then
            return
        end

        local row = table_el:tag('tr')
        row:tag('th'):wikitext(label)
        row:tag('td'):wikitext(bold and ("'''" .. value .. "'''") or value)
    end

    add_row(page_type == 'module' and 'Module name' or 'Template name', name, true)
    add_row('Description', description)
    add_row('When to use', when_to_use)
    add_row('Usage', usage)
    add_row('Placement', placement)

    return styles(frame) .. tostring(table_el)
end

function p.main ( frame )
    return p.doc(frame)
end

return p