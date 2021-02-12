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