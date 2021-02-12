function patternutils.loadPatterns()
    local patternList = {}
    local layers = data.GetDataLayers()
    
    for _,layer in pairs(layers) do
        table.insert(patternList, data.GetVariableName(layer))
    end
    return patternList
end

function patternutils.loadPattern(name)
    local pattern = {}
    local values = util.strsplit(data.Load(name),";")

    pattern.name = name
    pattern.startOffset = values[1]
    pattern.endOffset = values[2]

    return pattern
end