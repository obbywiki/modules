local p = {}

function p.main(frame)
    local container = mw.html.create('div')

    container:addClass('ow-cb-container')


    return container .. frame:extensionTag('templatestyles', '', { src = 'Module:ContributingBanner/styles.css' })
end

return p