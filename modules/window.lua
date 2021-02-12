function window.main()
    local menuID = "global"

    statusMessage = state.GetValue("statusMessage") or "%VERSION%"

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