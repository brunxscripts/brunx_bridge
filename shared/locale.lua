Locales = Locales or {}

function _L(key, ...)
    local lang = Config and Config.Locale or 'en'
    local locale = Locales[lang] or Locales.en or {}
    local fallback = Locales.en or {}
    local str = locale[key] or fallback[key] or key

    if select('#', ...) > 0 then
        return string.format(str, ...)
    end

    return str
end
