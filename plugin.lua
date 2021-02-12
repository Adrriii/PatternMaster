--[[

    THIS FILE IS AUTOGENERATED WITH THE COMPILE.PY FILE.
    THIS IS DONE IN ORDER TO ALLOW A MULTIFILE MODULE STRUCTURE
    FOR THE PROJECT.

    For users:
        Don't worry too much about it. You only really need the
        plugin.lua file and the settings.ini file. Delete everything
        else, if you really don't care about anything.

    For developers:
        Please refrain from editing the plugin.lua file directly.
        Rather, do edit the modules directly and then compile with
        the provided script.

]]

-- MODULES:
data = {}
editor = {}
gui = {}
mathematics = {}
menu = {}
patternutils = {}
style = {}
sv = {}
util = {}
window = {}
-------------------------------------------------------------------------------------
-- modules\data.lua
-------------------------------------------------------------------------------------

-- Inspired from https://github.com/Illuminati-CRAZ/Memory-2

prefix = "PatternMasterData"

function data.FindLayerThatStartsWith(str)
    for _, layer in pairs(map.EditorLayers) do
        if util.StartsWith(layer.Name, str) then
            return layer
        end
    end
end

function data.Save(name, value)
    name = prefix .. "|" .. name
    local data_layer = data.FindLayerThatStartsWith(name .. ":")

    if data_layer then
        actions.RenameLayer(data_layer, name .. ":" .. value)
    else
        data_layer = utils.CreateEditorLayer(name .. ":" .. value)
        actions.CreateLayer(data_layer)
    end
end

function data.Delete(name)
    name = prefix .. "|" .. name
    local data_layer = data.FindLayerThatStartsWith(name .. ":")

    if data_layer then
        actions.RemoveLayer(data_layer)
    end
end

function data.Load(name)
    name = prefix .. "|" .. name
    local data_layer = data.FindLayerThatStartsWith(name .. ":")

    if data_layer then
        return data_layer.Name:sub(#name + 2, #data_layer.Name)
    end
end

function data.LoadLayer(layer)
    return util.strsplit(layer,":")[2]
end

function data.GetVariableName(layer)
    if util.StartsWith(layer, prefix) then
        return util.strsplit(util.strsplit(layer,"|")[2],":")[1]
    end
end

function data.GetDataLayers()
    local layers = {}
    for _, layer in pairs(map.EditorLayers) do
        if util.StartsWith(layer.Name, prefix) then
            table.insert(layers, layer.Name)
        end
    end
    return layers
end

-------------------------------------------------------------------------------------
-- modules\editor.lua
-------------------------------------------------------------------------------------

function editor.placeElements(elements, type)
    if #elements == 0 then return end
    local status = "Inserted " .. #elements .. " "
    if not type or type == 0 then
        actions.PlaceScrollVelocityBatch(elements)
        status = status .. "SV"
    elseif type == 1 then
        actions.PlaceHitObjectBatch(elements)
        status = status .. "note"
    elseif type == 2 then
        actions.PlaceTimingPointBatch(elements)
        status = status .. "BPM Point"
    end
    local pluralS = #elements == 1 and "" or "s"
    statusMessage = status .. pluralS  .. "!"
end

function editor.removeElements(elements, type)
    if #elements == 0 then return end
    local status = "Removed " .. #elements .. " "
    if not type or type == 0 then
        actions.RemoveScrollVelocityBatch(elements)
        status = status .. "SVs"
    elseif type == 1 then
        actions.RemoveHitObjectBatch(elements)
        status = status .. "notes"
    elseif type == 2 then
        actions.RemoveTimingPointBatch(elements)
        status = status .. "BPM Points"
    end
    statusMessage = status .. "!"
end

editor.typeAttributes = {
    -- SV
    [0] = {
        "StartTime",
        "Multiplier"
    },
    -- "Note"
    [1] = {
        "StartTime",
        "Lane",
        "EndTime",
        -- "HitSound", left out because there's some trouble with comparing hitsound values
        "EditorLayer"
    },
    -- BPM
    [2] = {
        "StartTime",
        "Bpm",
        -- "Signature", same reason
    }
}

--- Manipulates a table of elements with specified functions and returns a new table
-- Iterates over each possible attribute for a given type, it will apply a function
-- if one has been defined for that type in the settings table.
-- @param elements Table of elements to manipulate
-- @param typeMode Number between 0 and 2, representing the type SV, note or BPM
-- @param settings Table, where each key is a attribute of a type and the value is a function to apply to that attribute

--[[
    Example:
        settings = {
            StartTime = function(t) return t + 100 end
        }

        would shift all StartTimes by 100
]]

function editor.createNewTableOfElements(elements, typeMode, settings)
    local newTable = {}

    for i, element in pairs(elements) do
        local newElement = {}
        for _, attribute in pairs(editor.typeAttributes[typeMode]) do
            if settings[attribute] then
                newElement[attribute] = settings[attribute](element[attribute])
            else
                newElement[attribute] = element[attribute]
            end
        end

        newTable[i] = newElement
    end

    local newElements = {}

    for i, el in pairs(newTable) do
        if typeMode == 0 then
            newElements[i] = utils.CreateScrollVelocity(el.StartTime, el.Multiplier)
        elseif typeMode == 1 then
            newElements[i] = utils.CreateHitObject(el.StartTime, el.Lane, el.EndTime, nil)
        elseif typeMode == 2 then
            newElements[i] = utils.CreateTimingPoint(el.StartTime, el.Bpm, nil)
        end
    end

    return newElements
end

-------------------------------------------------------------------------------------
-- modules\gui.lua
-------------------------------------------------------------------------------------

function gui.title(title, skipSeparator, helpMarkerText)
    if not skipSeparator then
        gui.spacing()
        imgui.Separator()
    end
    gui.spacing()
    imgui.Text(string.upper(title))
    if helpMarkerText then
        gui.helpMarker(helpMarkerText)
    end
    gui.spacing()
end

function gui.sameLine()
    imgui.SameLine(0, style.SAMELINE_SPACING)
end

function gui.separator()
    gui.spacing()
    imgui.Separator()
end

function gui.spacing()
    imgui.Dummy({0,5})
end

function gui.tooltip(text)
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(imgui.GetFontSize() * 25)
        imgui.Text(text)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function gui.helpMarker(text)
    imgui.SameLine()
    imgui.TextDisabled("(?)")
    gui.tooltip(text)
end

function gui.printVars(vars, title)
    if imgui.CollapsingHeader(title, imgui_tree_node_flags.DefaultOpen) then
        imgui.Columns(3)
        gui.separator()

        imgui.Text("var");      imgui.NextColumn();
        imgui.Text("type");     imgui.NextColumn();
        imgui.Text("value");    imgui.NextColumn();

        gui.separator()

        if vars == state then
            local varList = { "DeltaTime", "UnixTime", "IsWindowHovered", "Values", "SongTime", "SelectedHitObjects", "CurrentTimingPoint" }
            for _, value in pairs(varList) do
                util.toString(value);               imgui.NextColumn();
                util.toString(type(vars[value]));   imgui.NextColumn();
                util.toString(vars[value]);         imgui.NextColumn();
            end
        else
            for key, value in pairs(vars) do
                util.toString(key);             imgui.NextColumn();
                util.toString(type(value));     imgui.NextColumn();
                util.toString(value);           imgui.NextColumn();
            end
        end

        imgui.Columns(1)
        gui.separator()
    end
end

function gui.plot(values, title, valueAttribute)
    if not values or #values == 0 then return end

    local trueValues

    if valueAttribute and values[1][valueAttribute] then
        trueValues = {}
        for i, value in pairs(values) do
            trueValues[i] = value[valueAttribute]
        end
    else
        trueValues = values
    end

    imgui.PlotLines(
        title,
        trueValues, #trueValues,
        0,
        nil,
        nil, nil,
        imgui.CreateVector2( -- does not seem to work with a normal table
            style.CONTENT_WIDTH,
            200
        )
    )
end

-- utils.OpenUrl() has been removed so i'll have to make do with this
function gui.hyperlink(url)
    imgui.PushItemWidth(imgui.GetContentRegionAvailWidth())
    imgui.InputText("##"..url, url, #url, imgui_input_text_flags.AutoSelectAll)
    imgui.PopItemWidth()
end

function gui.bulletList(listOfLines)
    if type(listOfLines) ~= "table" then return end
    for _, line in pairs(listOfLines) do
        imgui.BulletText(line)
    end
end

function gui.InputOffset(vars, label, var, status, tooltip)
    local widths = util.calcAbsoluteWidths({ 0.25, 0.7 })

    if imgui.Button("Current           "..var, {widths[1], style.DEFAULT_WIDGET_HEIGHT}) then
        vars[var] = state.SongTime
        statusMessage = status
    end

    gui.tooltip(tooltip)

    gui.sameLine()

    imgui.PushItemWidth(widths[2])
    _, vars[var] = imgui.InputInt(label .." offset in ms", vars[var], 1)
    imgui.PopItemWidth()
end

-------------------------------------------------------------------------------------
-- modules\mathematics.lua
-------------------------------------------------------------------------------------

-- Simple recursive implementation of the binomial coefficient
function mathematics.binom(n, k)
    if k == 0 or k == n then return 1 end
    return mathematics.binom(n-1, k-1) + mathematics.binom(n-1, k)
end

-- Currently unused
function mathematics.bernsteinPolynomial(i,n,t) return mathematics.binom(n,i) * t^i * (1-t)^(n-i) end

-- Derivative for *any* bezier curve with at point t
-- Currently unused
function mathematics.bezierDerivative(P, t)
    local n = #P
    local sum = 0
    for i = 0, n-2, 1 do sum = sum + mathematics.bernsteinPolynomial(i,n-2,t) * (P[i+2].y - P[i+1].y) end
    return sum
end

function mathematics.cubicBezier(P, t)
    return P[1] + 3*t*(P[2]-P[1]) + 3*t^2*(P[1]+P[3]-2*P[2]) + t^3*(P[4]-P[1]+3*P[2]-3*P[3])
end

function mathematics.round(x, n) return tonumber(string.format("%." .. (n or 0) .. "f", x)) end

function mathematics.clamp(x, min, max)
    if x < min then x = min end
    if x > max then x = max end
    return x
end

function mathematics.min(t)
    local min = t[1]
    for _, value in pairs(t) do
        if value < min then min = value end
    end

    return min
end

function mathematics.max(t)
    local max = t[1]
    for _, value in pairs(t) do
        if value > max then max = value end
    end

    return max
end

mathematics.comparisonOperators = {
    "=", "!=", "<", "<=", ">=", ">"
}

-- No minus/division/root since they are present in the given operators already
-- Add negative values to subtract, multiply with 1/x to divide by x etc.
mathematics.arithmeticOperators = {
    "=", "+", "×", "^"
}

function mathematics.evaluateComparison(operator, value1, value2)
    local compareFunctions = {
        ["="]  = function (v1, v2) return v1 == v2 end,
        ["!="] = function (v1, v2) return v1 ~= v2 end,
        ["<"]  = function (v1, v2) return v1 < v2 end,
        ["<="] = function (v1, v2) return v1 <= v2 end,
        [">="] = function (v1, v2) return v1 >= v2 end,
        [">"]  = function (v1, v2) return v1 > v2 end
    }

    return compareFunctions[operator](value1, value2)
end

function mathematics.evaluateArithmetics(operator, oldValue, changeValue)
    local arithmeticFunctions = {
        ["="] = function (v1, v2) return v2 end,
        ["+"] = function (v1, v2) return v1 + v2 end,
        ["×"] = function (v1, v2) return v1 * v2 end,
        ["^"] = function (v1, v2) return v1 ^ v2 end
    }

    return arithmeticFunctions[operator](oldValue, changeValue)
end

-------------------------------------------------------------------------------------
-- modules\menu.lua
-------------------------------------------------------------------------------------

function menu.addPattern(patterns)
    local menuID = "new_pattern"

    if imgui.BeginTabItem("New Pattern") then

        local vars = {
            startOffset = 0,
            endOffset = 0,
            patternName = "MyPattern"
        }
        util.retrieveStateVariables(menuID, vars)
        local widths = util.calcAbsoluteWidths(style.BUTTON_WIDGET_RATIOS)
        
        gui.InputOffset(vars, "Start", "startOffset", "Copied start offset", "Sets the start of the pattern at the current position")
        gui.InputOffset(vars, "End", "endOffset", "Copied end offset", "Sets the end of the pattern at the current position")

        imgui.PushItemWidth(widths[2])
        _,vars.patternName = imgui.InputText("##", vars.patternName, 50, 4112)
        imgui.PopItemWidth()

        gui.sameLine()

        if imgui.Button("Add", {widths[1], style.DEFAULT_WIDGET_HEIGHT}) then
            statusMessage = "Added "..vars.patternName
            data.Save(vars.patternName, vars.startOffset .. ";" .. vars.endOffset)

        end

        util.saveStateVariables(menuID, vars)

        imgui.EndTabItem()
    end
end

function menu.pattern(pattern)
    local menuID = pattern.name
    if imgui.BeginTabItem(pattern.name) then
        imgui.Text("Starts at "..pattern.startOffset..", ends at "..pattern.endOffset)

        local vars = {
            startOffset = tonumber(pattern.startOffset),
            endOffset = tonumber(pattern.endOffset),
            patternName = pattern.name
        }
        util.retrieveStateVariables(menuID, vars)

        local widths = util.calcAbsoluteWidths(style.BUTTON_WIDGET_RATIOS)

        if imgui.Button("Go to", {widths[1], style.DEFAULT_WIDGET_HEIGHT}) then
            actions.GoToObjects(pattern.startOffset)
        end
        
        gui.InputOffset(vars, "Start", "startOffset", "Copied start offset", "Sets the start of the pattern at the current position")
        gui.InputOffset(vars, "End", "endOffset", "Copied end offset", "Sets the end of the pattern at the current position")

        if imgui.Button("Apply", {widths[1], style.DEFAULT_WIDGET_HEIGHT}) then
            statusMessage = "Edited "..vars.patternName
            data.Save(vars.patternName, vars.startOffset .. ";" .. vars.endOffset)
        end

        if imgui.Button("Delete", {widths[1], style.DEFAULT_WIDGET_HEIGHT}) then
            statusMessage = "Deleted "..vars.patternName
            data.Delete(vars.patternName, vars.startOffset .. ";" .. vars.endOffset)
        end

        util.saveStateVariables(menuID, vars)
        imgui.EndTabItem()
    end
end

-------------------------------------------------------------------------------------
-- modules\patternutils.lua
-------------------------------------------------------------------------------------

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

-------------------------------------------------------------------------------------
-- modules\style.lua
-------------------------------------------------------------------------------------

style.SAMELINE_SPACING = 4
style.CONTENT_WIDTH = 250
style.DEFAULT_WIDGET_HEIGHT = 26
style.HYPERLINK_COLOR = { 0.53, 0.66, 0.96, 1.00 }
style.BUTTON_WIDGET_RATIOS = { 0.3, 0.7 }
style.FULLSIZE_WIDGET_SIZE = {style.CONTENT_WIDTH, style.DEFAULT_WIDGET_HEIGHT}

function style.applyStyle()

    -- COLORS

    imgui.PushStyleColor(   imgui_col.WindowBg,                { 0.11, 0.11 ,0.11, 1.00 })
    imgui.PushStyleColor(   imgui_col.FrameBg,                 { 0.20, 0.29 ,0.42, 0.59 })
    imgui.PushStyleColor(   imgui_col.FrameBgHovered,          { 0.35, 0.51 ,0.74, 0.78 })
    imgui.PushStyleColor(   imgui_col.FrameBgActive,           { 0.17, 0.27 ,0.39, 0.67 })
    imgui.PushStyleColor(   imgui_col.TitleBg,                 { 0.11, 0.11 ,0.11, 1.00 })
    imgui.PushStyleColor(   imgui_col.TitleBgActive,           { 0.19, 0.21 ,0.23, 1.00 })
    imgui.PushStyleColor(   imgui_col.TitleBgCollapsed,        { 0.20, 0.25 ,0.30, 1.00 })
    imgui.PushStyleColor(   imgui_col.ScrollbarGrab,           { 0.44, 0.44 ,0.44, 1.00 })
    imgui.PushStyleColor(   imgui_col.ScrollbarGrabHovered,    { 0.75, 0.73 ,0.73, 1.00 })
    imgui.PushStyleColor(   imgui_col.ScrollbarGrabActive,     { 0.99, 0.99 ,0.99, 1.00 })
    imgui.PushStyleColor(   imgui_col.CheckMark,               { 1.00, 1.00 ,1.00, 1.00 })
    imgui.PushStyleColor(   imgui_col.Button,                  { 0.57, 0.79 ,0.84, 0.40 })
    imgui.PushStyleColor(   imgui_col.ButtonHovered,           { 0.40, 0.62 ,0.64, 1.00 })
    imgui.PushStyleColor(   imgui_col.ButtonActive,            { 0.24, 0.74 ,0.76, 1.00 })
    imgui.PushStyleColor(   imgui_col.Tab,                     { 0.30, 0.33 ,0.38, 0.86 })
    imgui.PushStyleColor(   imgui_col.TabHovered,              { 0.67, 0.71 ,0.75, 0.80 })
    imgui.PushStyleColor(   imgui_col.TabActive,               { 0.39, 0.65 ,0.74, 1.00 })
    imgui.PushStyleColor(   imgui_col.SliderGrab,              { 0.39, 0.65 ,0.74, 1.00 })
    imgui.PushStyleColor(   imgui_col.SliderGrabActive,        { 0.39, 0.65 ,0.74, 1.00 })

    -- VALUES

    local rounding = 0

    imgui.PushStyleVar( imgui_style_var.WindowPadding,      { 20, 10 } )
    imgui.PushStyleVar( imgui_style_var.FramePadding,       {  9,  6 } )
    imgui.PushStyleVar( imgui_style_var.ItemSpacing,        { style.DEFAULT_WIDGET_HEIGHT/2 - 1,  4 } )
    imgui.PushStyleVar( imgui_style_var.ItemInnerSpacing,   { style.SAMELINE_SPACING, 6 } )
    imgui.PushStyleVar( imgui_style_var.ScrollbarSize,      10         )
    imgui.PushStyleVar( imgui_style_var.WindowBorderSize,   0          )
    imgui.PushStyleVar( imgui_style_var.WindowRounding,     rounding   )
    imgui.PushStyleVar( imgui_style_var.ChildRounding,      rounding   )
    imgui.PushStyleVar( imgui_style_var.FrameRounding,      rounding   )
    imgui.PushStyleVar( imgui_style_var.ScrollbarRounding,  rounding   )
    imgui.PushStyleVar( imgui_style_var.TabRounding,        rounding   )
end

function style.rgb1ToUint(r, g, b, a)
    return a * 16 ^ 6 + b * 16 ^ 4 + g * 16 ^ 2 + r
end

-------------------------------------------------------------------------------------
-- modules\sv.lua
-------------------------------------------------------------------------------------

-- Returns a list of SV objects as defined in Quaver.API/Maps/Structures/SliderVelocityInfo.cs
function sv.linear(startSV, endSV, startOffset, endOffset, intermediatePoints, skipEndSV)

    local timeInterval = (endOffset - startOffset)/intermediatePoints
    local velocityInterval = (endSV - startSV)/intermediatePoints

    if skipEndSV then intermediatePoints = intermediatePoints - 1 end

    local SVs = {}

    for step = 0, intermediatePoints, 1 do
        local offset = step * timeInterval + startOffset
        local velocity = step * velocityInterval + startSV
        SVs[step+1] = utils.CreateScrollVelocity(offset, velocity)
    end

    return SVs
end

function sv.stutter(offsets, startSV, duration, averageSV, skipEndSV, skipFinalEndSV, effectDurationMode, effectDurationValue)
    local SVs = {}

    for i, offset in ipairs(offsets) do
        if i == #offsets then break end

        table.insert(SVs, utils.CreateScrollVelocity(offset, startSV))

        local length
        if effectDurationMode == 0 then -- scale with distance between notes
            length = (offsets[i+1] - offset) * effectDurationValue
        elseif effectDurationMode == 1 then -- scale with snap
            length = effectDurationValue * 60000/map.GetTimingPointAt(offset).Bpm
        elseif effectDurationMode == 2 then -- absolute length
            length = effectDurationValue
        end

        table.insert(SVs, utils.CreateScrollVelocity(length*duration + offset, (duration*startSV-averageSV)/(duration-1)))

        local lastOffsetEnd = offset+length
        if skipEndSV == false and (offsets[i+1] ~= lastOffsetEnd) then
            table.insert(SVs, utils.CreateScrollVelocity(lastOffsetEnd, averageSV))
        end
    end

    if skipFinalEndSV == false then
        table.insert(SVs, utils.CreateScrollVelocity(offsets[#offsets], averageSV))
    end

    return SVs
end

--[[
    about beziers

    i originally planned to support any number of control points from 3 (quadratic)
    to, idk, 10 or something

    i ran into some issues when trying to write general code for all orders of n,
    which made me give up on them for now

    the way to *properly* do it
        - find length t at position x
        - use the derivative of bezier to find y at t

    problem is that i cant reliably perform the first step for any curve
    so i guess i'll be using a very bad approach to this for now... if you know more about
    this stuff please get in contact with me
]]

-- @return table of scroll velocities
function sv.cubicBezier(P1_x, P1_y, P2_x, P2_y, startOffset, endOffset, averageSV, intermediatePoints, skipEndSV)

    local stepInterval = 1/intermediatePoints
    local timeInterval = (endOffset - startOffset) * stepInterval

    -- the larger this number, the more accurate the final sv is
    -- ... and the longer it's going to take
    local totalSampleSize = 2500
    local allBezierSamples = {}
    for t=0, 1, 1/totalSampleSize do
        local x = mathematics.cubicBezier({0, P1_x, P2_x, 1}, t)
        local y = mathematics.cubicBezier({0, P1_y, P2_y, 1}, t)
        table.insert(allBezierSamples, {x=x,y=y})
    end

    local SVs = {}
    local positions = {}

    local currentPoint = 0

    for sampleCounter = 1, totalSampleSize, 1 do
        if allBezierSamples[sampleCounter].x > currentPoint then
            table.insert(positions, allBezierSamples[sampleCounter].y)
            currentPoint = currentPoint + stepInterval
        end
    end

    for i = 2, intermediatePoints, 1 do
        local offset = (i-2) * timeInterval + startOffset
        local velocity = mathematics.round((positions[i] - (positions[i-1] or 0)) * averageSV * intermediatePoints, 2)
        SVs[i-1] = utils.CreateScrollVelocity(offset, velocity)
    end

    table.insert(SVs, utils.CreateScrollVelocity((intermediatePoints - 1) * timeInterval + startOffset, SVs[#SVs].Multiplier))

    if skipEndSV == false then
        table.insert(SVs, utils.CreateScrollVelocity(endOffset, averageSV))
    end

    return SVs, util.subdivideTable(allBezierSamples, 1, 50, true)
end


--[[
    Example for cross multiply taken from reamberPy

    baseSVs    | (1.0) ------- (2.0) ------- (3.0) |
    crossSVs   | (1.0)  (1.5) ------- (2.0) ------ |
    __________ | _________________________________ |
    result     | (1.0) ------- (3.0) ------- (6.0) |
]]

function sv.crossMultiply(baseSVs, crossSVs)
    local SVs = {}
    local crossIndex = 1

    for i, baseSV in pairs(baseSVs) do
        while crossIndex < #crossSVs and baseSV.StartTime > crossSVs[crossIndex+1].StartTime do
            crossIndex = crossIndex + 1
        end

        SVs[i] = utils.CreateScrollVelocity(
            baseSV.StartTime,
            baseSV.Multiplier * crossSVs[crossIndex].Multiplier
        )
    end

    return SVs
end

-------------------------------------------------------------------------------------
-- modules\util.lua
-------------------------------------------------------------------------------------

function util.retrieveStateVariables(menuID, variables)
    for key, value in pairs(variables) do
        variables[key] = state.GetValue(menuID..key) or value
    end
end

function util.saveStateVariables(menuID, variables)
    for key, value in pairs(variables) do
        state.SetValue(menuID..key, value)
    end
end

function util.printTable(table)
    util.toString(table, true)
    if table then
        imgui.Columns(2)
        imgui.Text("Key");   imgui.NextColumn();
        imgui.Text("Value"); imgui.NextColumn();
        imgui.Separator()
        for key, value in pairs(table) do
            util.toString(key, true);   imgui.NextColumn();
            util.toString(value, true); imgui.NextColumn();
        end
        imgui.Columns(1)
    end
end

function util.toString(var, imguiText)
    local string = ""

    if var == nil then string = "<null>"
    elseif type(var) == "table" then string = "<table.length=".. #var ..">"
    elseif var == "" then string = "<empty string>"
    else string = "<" .. type(var) .. "=" .. var .. ">" end

    if imguiText then imgui.Text(string) end
    return string
end

function util.calcAbsoluteWidths(relativeWidths, width)
    local absoluteWidths = {}
    local n = #relativeWidths
    local totalWidth = width or style.CONTENT_WIDTH
    for i, value in pairs(relativeWidths) do
        absoluteWidths[i] = (value * totalWidth) - (style.SAMELINE_SPACING/n)
    end
    return absoluteWidths
end

function util.subdivideTable(oldTable, nKeep, nRemove, keepStartAndEnd)
    local newTable = {}

    if keepStartAndEnd then table.insert(newTable, oldTable[1]) end

    for i, value in pairs(oldTable) do
        if i % (nKeep + nRemove) < nKeep then
            table.insert(newTable, value)
        end
    end

    if keepStartAndEnd then table.insert(newTable, oldTable[#oldTable]) end

    return newTable
end

function util.mapFunctionToTable(oldTable, func, params)
    local newTable = {}
    for i, value in pairs(oldTable) do
        if params then
            newTable[i] = func(value, table.unpack(params))
        else
            newTable[i] = func(value)
        end
    end
    return newTable
end

function util.uniqueBy(t, attribute)
    local hash = {}
    local res = {}

    for _,v in ipairs(t) do
        local key = attribute and v[attribute] or v
        if (not hash[key]) then
            res[#res+1] = v
            hash[key] = true
        end
    end

    return res
end

function util.filter(t, condition)
    local filtered = {}
    for key, value in pairs(t) do
        if condition(key, value) then table.insert(filtered, value) end
    end
    return filtered
end

function util.mergeUnique(t1, t2, keysToCompare)
    local hash = {}
    local newTable = {}

    for _, t in pairs({t1, t2}) do
        for _, element in pairs(t) do
            -- You can't directly set the table as the hash value, since tables
            -- are compared by reference and everything with tables is pass by reference
            local hashValue = ""
            for _, key in pairs(keysToCompare) do
                hashValue = hashValue .. element[key] .. "|"
            end

            if not hash[hashValue] then
                table.insert(newTable, element)
                hash[hashValue] = true
            end
        end
    end

    return newTable
end

--http://lua-users.org/wiki/StringRecipes
function util.StartsWith(str, start)
    return str:sub(1, #start) == start
end

--https://gist.github.com/jaredallard/ddb152179831dd23b230
function util.strsplit(str, delimiter)
    local result = { }
    local from  = 1
    local delim_from, delim_to = string.find( str, delimiter, from  )
    while delim_from do
        table.insert( result, string.sub( str, from , delim_from-1 ) )
        from  = delim_to + 1
        delim_from, delim_to = string.find( str, delimiter, from  )
    end
    table.insert( result, string.sub( str, from  ) )
    return result
end

-------------------------------------------------------------------------------------
-- modules\window.lua
-------------------------------------------------------------------------------------

function window.main()
    local menuID = "global"

    statusMessage = state.GetValue("statusMessage") or "b2021.2.12"

    imgui.Begin("Pattern Master", true, imgui_window_flags.AlwaysAutoResize)
    local patterns = patternutils.loadPatterns()

    imgui.BeginTabBar("function_selection")
    menu.addPattern(patterns)
    for _,p in pairs(patterns) do
        menu.pattern(patternutils.loadPattern(p))
    end
    imgui.EndTabBar()

    gui.separator()
    imgui.TextDisabled(statusMessage)

    -- This line needs to be added, so that the UI under it in-game
    -- is not able to be clicked. If you have multiple windows, you'll want to check if
    -- either one is hovered.
    state.IsWindowHovered = imgui.IsWindowHovered()
    imgui.End()

    state.SetValue("statusMessage", statusMessage)
end

-------------------------------------------------------------------------------------
-- modules\_main.lua
-------------------------------------------------------------------------------------

-- MoonSharp Documentation - http://www.moonsharp.org/getting_started.html
-- ImGui - https://github.com/ocornut/imgui
-- ImGui.NET - https://github.com/mellinoe/ImGui.NET
-- Quaver Plugin Guide - https://github.com/IceDynamix/QuaverPluginGuide/blob/master/quaver_plugin_guide.md

-- MAIN ------------------------------------------------------

function draw()
    style.applyStyle()
    window.main()
end