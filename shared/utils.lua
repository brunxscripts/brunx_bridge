Brunx = Brunx or {}
Brunx.Utils = Brunx.Utils or {}

function Brunx.Utils.debug(...)
    if not Config.Debug then return end
    print(('^5[brunx_bridge]^7 %s'):format(table.concat({ ... }, ' ')))
end

function Brunx.Utils.resourceStarted(resource)
    return resource and GetResourceState(resource) == 'started'
end

function Brunx.Utils.firstStarted(resources)
    for _, resource in ipairs(resources or {}) do
        if Brunx.Utils.resourceStarted(resource) then return resource end
    end
    return nil
end

function Brunx.Utils.detectResource(groups, preferred)
    if preferred and preferred ~= 'auto' and preferred ~= 'standalone' then
        local key = preferred:gsub('-', '_')
        local names = groups[preferred] or groups[key]
        if names then
            local found = Brunx.Utils.firstStarted(names)
            if found then return found, key end
        end
        return nil, nil
    end

    local order = {
        'qbox', 'qbcore', 'esx', 'ox', 'vrp',
        'ox_inventory', 'qb_inventory', 'lj_inventory', 'ps_inventory', 'qs_inventory',
        'origen_inventory', 'codem_inventory', 'core_inventory', 'mf_inventory', 'esx_inventory',
        'ox_target', 'qb_target'
    }

    for _, key in ipairs(order) do
        if groups[key] then
            local found = Brunx.Utils.firstStarted(groups[key])
            if found then return found, key end
        end
    end

    for key, names in pairs(groups) do
        local found = Brunx.Utils.firstStarted(names)
        if found then return found, key end
    end

    return nil, nil
end

function Brunx.Utils.safeCall(fn, fallback, ...)
    local ok, result = pcall(fn, ...)
    if ok then return result end
    Brunx.Utils.debug('safeCall error:', result)
    return fallback
end

function Brunx.Utils.deepCopy(tbl)
    if type(tbl) ~= 'table' then return tbl end
    local copy = {}
    for k, v in pairs(tbl) do copy[k] = Brunx.Utils.deepCopy(v) end
    return copy
end

function Brunx.Utils.contains(list, value)
    if not list then return true end
    if type(list) == 'string' then return list == value end
    for _, item in ipairs(list) do
        if item == value then return true end
    end
    return false
end

function Brunx.Utils.normalizeJob(job)
    if not job then return nil end
    if type(job) == 'string' then return { name = job, label = job, grade = 0, gradeName = '0', onDuty = true } end
    local grade = job.grade
    local gradeLevel = 0
    local gradeName = '0'

    if type(grade) == 'table' then
        gradeLevel = grade.level or grade.grade or grade.value or 0
        gradeName = grade.name or grade.label or tostring(gradeLevel)
    else
        gradeLevel = tonumber(grade) or 0
        gradeName = tostring(gradeLevel)
    end

    return {
        name = job.name or job.id,
        label = job.label or job.name or job.id,
        grade = gradeLevel,
        gradeName = gradeName,
        onDuty = job.onduty ~= nil and job.onduty or job.onDuty ~= false
    }
end

function Brunx.Utils.hasGroup(current, required)
    if not required then return true end
    if type(required) == 'string' then required = { [required] = 0 } end
    if type(required) == 'table' and #required > 0 then
        local mapped = {}
        for _, name in ipairs(required) do mapped[name] = 0 end
        required = mapped
    end
    if not current then return false end
    local currentName = current.name or current.job or current
    local currentGrade = tonumber(current.grade or 0) or 0
    local requiredGrade = required[currentName]
    return requiredGrade ~= nil and currentGrade >= (tonumber(requiredGrade) or 0)
end
