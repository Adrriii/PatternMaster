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
        objects = {},
		svs = {},
    }
    local values = util.strsplit(data.Load(name), ";")

    pattern.name = name
    pattern.startOffset = values[1]
    pattern.endOffset = values[2]

    if values[3] then
        for _,o in pairs(util.strsplit(values[3], "/")) do
            local occurence_data = util.strsplit(o, "#")
            local occurence = {
                time = o,
                mirror = false,
                sv = false,
            }
            if occurence_data[1] != '' then
                occurence.time = occurence_data[1]
            end
            if occurence_data[2] then
                occurence.mirror = tonumber(occurence_data[2]) == 1
            end
            if occurence_data[3] then
                occurence.sv = tonumber(occurence_data[3]) == 1
            end

            if(occurence.time != '') then
                table.insert(pattern.occurences, occurence)
            end
        end
    end

    return pattern
end

function patternutils.savePattern(pattern)
    local str = pattern.startOffset .. ";" .. pattern.endOffset .. ";/"
    
    for _,v in pairs(pattern.occurences) do
        if v.time != nil and v.time != '' then
            str = str .. v.time .. "#" .. (v.mirror and 1 or 0) .. "#" .. (v.sv and 1 or 0) .."/"
        end
    end

    data.Save(pattern.name, str)
end

function patternutils.refresh(pattern)
    pattern.objects = {}
	pattern.svs = {}

    for _,note in pairs(map.HitObjects) do
        if note.StartTime >= tonumber(pattern.startOffset) and note.StartTime <= tonumber(pattern.endOffset) + 1 then
            table.insert(pattern.objects, note)
        end
    end

	for _,sv in pairs(map.ScrollVelocities) do
		if sv.StartTime >= tonumber(pattern.startOffset - 1) and sv.StartTime <= tonumber(pattern.endOffset) then
			table.insert(pattern.svs, sv)
		end
	end

    for _,o in pairs(pattern.occurences) do
        if o.time != nil and o.time != '' then
            patternutils.copyPattern(pattern, o.time, o.mirror, o.sv)
        end
    end
end

function patternutils.copyPattern(pattern, offset, mirror, sv)
    local diff = (offset - tonumber(pattern.startOffset))

	if sv then
		local oldsvs = {}
		for _,sv in pairs(map.ScrollVelocities) do
			if sv.StartTime >= tonumber(pattern.startOffset - 1) + diff and sv.StartTime <= tonumber(pattern.endOffset - 1) + diff then
				table.insert(oldsvs, sv)
			end
		end

		local newsvs = {}
		for _,sv in pairs(pattern.svs) do
			table.insert(newsvs, utils.CreateScrollVelocity(sv.StartTime + diff, sv.Multiplier))
		end

		actions.RemoveScrollVelocityBatch(oldsvs)
		actions.PlaceScrollVelocityBatch(newsvs)
	else
		local oldhits = {}
		for _,note in pairs(map.HitObjects) do
			if note.StartTime >= tonumber(pattern.startOffset) + diff and note.StartTime <= tonumber(pattern.endOffset) + diff + 1 then
				table.insert(oldhits, note)
			end
		end

		local newhits = {}
		for _,note in pairs(pattern.objects) do
			local endtime = note.EndTime
			local lane = note.Lane
			local keys = tostring(map.Mode):gsub("Keys","")
			if endtime ~= 0 then endtime = note.EndTime + diff end
			if mirror then
				lane = -lane + (keys + 1) -- exchange lanes according to keys if mirror
			end
			table.insert(newhits, utils.CreateHitObject(note.StartTime + diff, lane, endtime, note.HitSound))
		end

		actions.RemoveHitObjectBatch(oldhits)
		actions.PlaceHitObjectBatch(newhits)
	end
end