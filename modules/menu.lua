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

        local vars = {
            startOffset = 0,
            endOffset = 0,
            patternName = "MyPattern"
        }
        util.retrieveStateVariables(menuID, vars)

        local widths = util.calcAbsoluteWidths(style.BUTTON_WIDGET_RATIOS)
        
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