Utils = Utils or {}

function Utils.Debug(...)
    if Config and Config.Debug then
        print('[brnx_bridge]', ...)
    end
end

function Utils.ResourceStarted(resource)
    return resource and GetResourceState(resource) == 'started'
end

function Utils.FirstStarted(resources)
    for _, resource in ipairs(resources or {}) do
        if Utils.ResourceStarted(resource) then
            return resource
        end
    end
    return nil
end

function Utils.NormalizeGrade(grade)
    if type(grade) == 'table' then
        return tonumber(grade.level or grade.grade or grade.id or grade.rank or grade.value or grade.gradeLevel or 0) or 0
    end

    return tonumber(grade or 0) or 0
end

function Utils.NormalizeBoss(value)
    return value == true or value == 1 or value == '1' or value == 'true'
end

function Utils.NormalizeJob(job)
    if type(job) == 'string' then
        return {
            name = job,
            label = job,
            grade = 0,
            gradeLabel = nil,
            isBoss = false,
            type = nil,
            duty = true
        }
    end

    if type(job) ~= 'table' then
        return {
            name = nil,
            label = nil,
            grade = 0,
            gradeLabel = nil,
            isBoss = false,
            type = nil,
            duty = nil
        }
    end

    local grade = job.grade or job.grade_level or job.gradeLevel
    local gradeLabel = job.gradeLabel or job.grade_label or job.gradeName or job.grade_name

    if type(grade) == 'table' then
        gradeLabel = gradeLabel or grade.name or grade.label
    end

    return {
        name = job.name or job.job or job.id,
        label = job.label or job.jobLabel or job.name or job.job or job.id,
        grade = Utils.NormalizeGrade(grade),
        gradeLabel = gradeLabel,
        isBoss = Utils.NormalizeBoss(job.isBoss or job.isboss or job.boss),
        type = job.type or job.jobType,
        duty = job.onduty or job.onDuty or job.duty
    }
end
