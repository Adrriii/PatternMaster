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
            data.Save(vars.patternName, vars.startOffset .. ";" .. vars.endOffset .. ";/")

        end

        util.saveStateVariables(menuID, vars)

        imgui.EndTabItem()
    end
end

function menu.pattern(pattern)
    local menuID = pattern.name
    if imgui.BeginTabItem(pattern.name) then
        imgui.Text("Starts at "..pattern.startOffset..", ends at "..pattern.endOffset)
        imgui.spacing()

        local vars = {
            startOffset = tonumber(pattern.startOffset),
            endOffset = tonumber(pattern.endOffset),
            newOffset = 0,
            patternName = pattern.name
        }
        util.retrieveStateVariables(menuID, vars)

        local widths = util.calcAbsoluteWidths(style.BUTTON_WIDGET_RATIOS)

        if imgui.Button("Go to "..pattern.name, {widths[1] * 2, style.DEFAULT_WIDGET_HEIGHT}) then
            actions.GoToObjects(pattern.startOffset)
        end
        imgui.spacing()

        if imgui.Button("Refresh "..pattern.name, {widths[1] * 2, style.DEFAULT_WIDGET_HEIGHT}) then
            state.SetValue("statusMessage", "Working...")
            patternutils.refresh(pattern)
            statusMessage = "Refreshed "..vars.patternName
        end
        imgui.spacing()

        imgui.Separator()

        imgui.Text("Edit")
        imgui.spacing()
        
        gui.InputOffset(vars, "Start", "startOffset", "Copied start offset", "Sets the start of the pattern at the current position")
        gui.InputOffset(vars, "End", "endOffset", "Copied end offset", "Sets the end of the pattern at the current position")

        if imgui.Button("Apply", {widths[1], style.DEFAULT_WIDGET_HEIGHT}) then
            pattern.startOffset = vars.startOffset
            pattern.endOffset = vars.endOffset
            patternutils.savePattern(pattern)
            statusMessage = "Edited "..vars.patternName
        end
        imgui.spacing()

        imgui.Separator()

        imgui.Text("Occurences")
        imgui.spacing()
        
        gui.InputOffset(vars, "New", "newOffset", "Copied new offset", "Adds a new occurence for this pattern")

        if imgui.Button("Add", {widths[1], style.DEFAULT_WIDGET_HEIGHT}) then
            table.insert(pattern.occurences, vars.newOffset)
            patternutils.savePattern(pattern)
            statusMessage = "Added ".. vars.newOffset .." to "..vars.patternName
        end
        imgui.spacing()

        local c = 0
        for _,v in pairs(pattern.occurences) do
            c = c + 1
            if v != nil and v != '' then
                if imgui.Button(v, {widths[1], style.DEFAULT_WIDGET_HEIGHT}) then
                    actions.GoToObjects(v)
                end
                gui.sameLine()
                if imgui.Button("Delete            "..v.."|"..c, {widths[1] * 0.75, style.DEFAULT_WIDGET_HEIGHT}) then
                    local new_occ = {}
                    for _,test in pairs(pattern.occurences) do
                        if test != nil and test != '' then
                            if(v != test) then 
                                table.insert(new_occ, test)
                            end
                        end
                    end
                    pattern.occurences = new_occ
                    patternutils.savePattern(pattern)
                end
            end
        end
        imgui.spacing()

        imgui.Separator()

        imgui.spacing()
        imgui.spacing()

        if imgui.Button("Delete this pattern", {widths[1] * 2, style.DEFAULT_WIDGET_HEIGHT}) then
            statusMessage = "Deleted "..vars.patternName
            data.Delete(vars.patternName, vars.startOffset .. ";" .. vars.endOffset)
        end

        util.saveStateVariables(menuID, vars)
        imgui.EndTabItem()
    end
end