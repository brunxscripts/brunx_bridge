Locale = Locale or {}
Locale.Data = {}

local function loadLocale(locale)
    local file = LoadResourceFile(GetCurrentResourceName(), ('locales/%s.json'):format(locale))
    if not file then return {} end
    local ok, decoded = pcall(json.decode, file)
    if not ok or type(decoded) ~= 'table' then return {} end
    return decoded
end

function Locale.Init()
    Locale.Data = loadLocale(Config.Locale or 'en')
    if (Config.Locale or 'en') ~= 'en' then
        local fallback = loadLocale('en')
        for key, value in pairs(fallback) do
            if Locale.Data[key] == nil then Locale.Data[key] = value end
        end
    end
end

function _L(key, vars)
    local value = Locale.Data[key] or key
    if vars then
        for k, v in pairs(vars) do
            value = value:gsub(('{{%s}}'):format(k), tostring(v))
        end
    end
    return value
end
