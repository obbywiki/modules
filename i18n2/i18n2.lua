-- i18n (internationalization) module for obbywiki
-- Provides a simple translation system with language fallback

local i18n = {}

local metatable = {}
local methodtable = {}

metatable.__index = methodtable

--- Cache for loaded translation data
local cache = {}

--- Default/fallback language
local DEFAULT_LANG = 'en'

--- Current language code
local current_lang = nil


--- Supported language codes for subpage detection
local SUPPORTED_LANGS = {
    ['en'] = true,
    ['ja'] = true,
    ['ko'] = true,
    ['zh'] = true,
    ['de'] = true,
    ['fr'] = true,
    ['es'] = true,
    ['pt'] = true,
    ['ru'] = true,
    ['it'] = true,
    ['pl'] = true,
    ['nl'] = true,
    ['tr'] = true,
    ['ar'] = true,
    ['th'] = true,
    ['vi'] = true,
    ['id'] = true,
}


--- Get the current language code by checking subpage first, then content language
---
--- @return string Language code (e.g., 'en', 'ja')
local function get_content_language()
    -- Use cached value if available (per-request cache)
    if current_lang then
        return current_lang
    end

    -- First, try to detect language from page title subpage (e.g., /Page/ja, /Page/en)
    local success, title = pcall(function()
        return mw.title.getCurrentTitle()
    end)

    if success and title then
        local page_title = title.text or ''
        local subpage = title.subpageText or ''
        
        -- subpageText returns the base page name if there's no subpage
        -- So we need to check if it's actually different
        if subpage ~= '' and subpage ~= page_title and SUPPORTED_LANGS[subpage] then
            current_lang = subpage
            return current_lang
        end

        -- Also try to extract manually from page title
        local lang_suffix = string.match(page_title, '/([^/]+)$')
        if lang_suffix and SUPPORTED_LANGS[lang_suffix] then
            current_lang = lang_suffix
            return current_lang
        end
    end

    -- Fall back to wiki's content language
    local lang_success, mwlang = pcall(function()
        return mw.language.getContentLanguage():getCode()
    end)

    if lang_success and mwlang then
        current_lang = mwlang
    else
        current_lang = DEFAULT_LANG
    end

    return current_lang
end


--- Load a translation dataset for a given module
---
--- @param module_name string The module name (e.g., 'ObbyGameInfobox')
--- @param lang string The language code
--- @return table|nil The translation data
local function load_translations(module_name, lang)
    local cache_key = module_name .. '_' .. lang

    if cache[cache_key] ~= nil then
        return cache[cache_key]
    end

    -- Try to load from Module:ModuleName/i18n/lang.json
    local dataset_name = string.format('Module:%s/i18n/%s.json', module_name, lang)
    local success, data = pcall(mw.loadJsonData, dataset_name)

    if not success then
        -- Try alternative path: Module:i18n/ModuleName/lang.json
        dataset_name = string.format('Module:i18n/%s/%s.json', module_name, lang)
        success, data = pcall(mw.loadJsonData, dataset_name)
    end

    if not success then
        cache[cache_key] = false
        return nil
    end

    cache[cache_key] = data
    return data
end


--- Set the current language manually
---
--- @param lang string The language code
function methodtable:set_language(lang)
    current_lang = lang
end


--- Get a translation for a given key
---
--- @param key string The translation key
--- @param fallback string|nil Optional fallback value if key not found
--- @return string The translated string or key/fallback
function methodtable:get(key, fallback)
    local lang = get_content_language()
    local module_name = self.module_name

    -- Try current language first
    local data = load_translations(module_name, lang)
    if data and data[key] then
        return data[key]
    end

    -- Try fallback language
    if lang ~= DEFAULT_LANG then
        data = load_translations(module_name, DEFAULT_LANG)
        if data and data[key] then
            return data[key]
        end
    end

    -- Return fallback or key itself
    return fallback or key
end


--- Get a translation with parameter substitution
--- Uses $1, $2, etc. as placeholders
---
--- @param key string The translation key
--- @param ... any Values to substitute
--- @return string The translated string with substitutions
function methodtable:format(key, ...)
    local message = self:get(key)
    local params = {...}

    for i, param in ipairs(params) do
        message = string.gsub(message, '%$' .. i, tostring(param))
    end

    return message
end


--- Get all translations as a table (useful for debugging)
---
--- @return table All loaded translations for current language
function methodtable:get_all()
    local lang = get_content_language()
    local data = load_translations(self.module_name, lang)
    return data or {}
end


--- Create a new i18n instance for a specific module
---
--- @param module_name string The module name for which to load translations
--- @return table i18n instance
function i18n.new(module_name)
    local instance = {
        module_name = module_name
    }

    setmetatable(instance, metatable)

    return instance
end


--- Utility: Get the language chain (current + fallbacks)
---
--- @return table Array of language codes
function i18n.get_language_chain()
    local langs = { get_content_language() }

    local success, fallbacks = pcall(function()
        return mw.language.getContentLanguage():getFallbackLanguages()
    end)

    if success and fallbacks then
        for _, fb in ipairs(fallbacks) do
            table.insert(langs, fb)
        end
    end

    -- Ensure default language is in the chain
    local found_default = false
    for _, l in ipairs(langs) do
        if l == DEFAULT_LANG then
            found_default = true
            break
        end
    end

    if not found_default then
        table.insert(langs, DEFAULT_LANG)
    end

    return langs
end


return i18n
