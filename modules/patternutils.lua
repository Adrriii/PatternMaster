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
        occurences = {},
        objects = {}
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

function patternutils.refresh(pattern)
    pattern.objects = {}

    for _,note in pairs(map.HitObjects) do
        if note.StartTime >= tonumber(pattern.startOffset) and note.StartTime <= tonumber(pattern.endOffset) + 1 then
            table.insert(pattern.objects, note)
        end
    end
    
    for _,o in pairs(pattern.occurences) do
        if o != nil and o != '' then
            patternutils.copyPattern(pattern, o)
        end
    end
end

function patternutils.copyPattern(pattern, offset)
    local diff = (offset - tonumber(pattern.startOffset))

    local oldhits = {}
    for _,note in pairs(map.HitObjects) do
        if note.StartTime >= tonumber(pattern.startOffset) + diff and note.StartTime <= tonumber(pattern.endOffset) + diff + 1 then
            table.insert(oldhits, note)
        end
    end

    local newhits = {}
    for _,note in pairs(pattern.objects) do
        local endtime = note.EndTime
        if endtime ~= 0 then endtime = note.EndTime + diff end
        table.insert(newhits, utils.CreateHitObject(note.StartTime + diff, note.Lane, endtime, note.HitSound))
    end

    actions.RemoveHitObjectBatch(oldhits)
    actions.PlaceHitObjectBatch(newhits)
end