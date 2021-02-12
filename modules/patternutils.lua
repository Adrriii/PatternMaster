function patternutils.loadPatterns()
    local patternList = {}
    local layers = data.GetDataLayers()
    
    for _,layer in pairs(layers) do
        table.insert(patternList, data.GetVariableName(layer))
    end
    return patternList
end

function patternutils.loadPattern(name)
    local pattern = {
        occurences = {}
    }
    local values = util.strsplit(data.Load(name), ";")

    pattern.name = name
    pattern.startOffset = values[1]
    pattern.endOffset = values[2]

    if values[3] then
        pattern.occurences = util.strsplit(values[3], "/")
    end
    return pattern
end

function patternutils.savePattern(pattern)
    local str = pattern.startOffset .. ";" .. pattern.endOffset .. ";/"

    for _,v in pairs(pattern.occurences) do
        if v != nil and v != '' then
            str = str .. v .."/"
        end
    end

    data.Save(pattern.name, str)
end