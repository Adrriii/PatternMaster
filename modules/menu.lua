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
            patternName = pattern.name,
			asSV = false,
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
            table.insert(pattern.occurences, {time=vars.newOffset, mirror=false, sv=false})
            patternutils.savePattern(pattern)
            statusMessage = "Added ".. vars.newOffset .." to "..vars.patternName
        end
		gui.sameLine()
        if imgui.Button("Add Current", {widths[2], style.DEFAULT_WIDGET_HEIGHT}) then
            table.insert(pattern.occurences, {time=math.floor(state.SongTime), mirror=false, sv=vars.asSV})
            patternutils.savePattern(pattern)
            statusMessage = "Added ".. math.floor(state.SongTime) .." to "..vars.patternName
        end
		gui.sameLine()
		_, vars.asSV = imgui.Checkbox("As SV ?", vars.asSV)
        imgui.spacing()

        local c = 0
        local spaces = ""
        for _,v in pairs(pattern.occurences) do
            c = c + 1
            if v != nil and v != '' then
                if imgui.Button("Go to ".. v.time, {widths[1]*1.5, style.DEFAULT_WIDGET_HEIGHT}) then
                    actions.GoToObjects(v.time)
                end
                gui.sameLine()
                if imgui.Button("Delete            ".. v.time .."|"..c, {widths[1] * 0.75, style.DEFAULT_WIDGET_HEIGHT}) then
                    local new_occ = {}
                    for _,test in pairs(pattern.occurences) do
                        if test.time != nil and test.time != '' then
                            if(v.time != test.time) then
                                table.insert(new_occ, {time=test.time, mirror=test.mirror, sv=test.sv})
                            end
                        end
                    end
                    pattern.occurences = new_occ
                    patternutils.savePattern(pattern)
                end
                gui.sameLine()
                _, mirror_after = imgui.Checkbox("Mirror? ", v.mirror)

                if v.mirror != mirror_after then
                    local new_occ = {}
                    for _,test in pairs(pattern.occurences) do
                        if test.time != nil and test.time != '' then
                            if test.time == v.time then
                                table.insert(new_occ, {time=test.time, mirror=mirror_after, sv=test.sv})
                            else
                                table.insert(new_occ, {time=test.time, mirror=test.mirror, sv=test.sv})
                            end
                        end
                    end
                    pattern.occurences = new_occ
                    patternutils.savePattern(pattern)
                end

                gui.sameLine()
                _, sv_after = imgui.Checkbox("SV? ", v.sv)

                if v.sv != sv_after then
                    local new_occ = {}
                    for _,test in pairs(pattern.occurences) do
                        if test.time != nil and test.time != '' then
                            if test.time == v.time then
                                table.insert(new_occ, {time=test.time, mirror=test.mirror, sv=sv_after})
                            else
                                table.insert(new_occ, {time=test.time, mirror=test.mirror, sv=test.sv})
                            end
                        end
                    end
                    pattern.occurences = new_occ
                    patternutils.savePattern(pattern)
                end
            end
            spaces = spaces .. " "
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