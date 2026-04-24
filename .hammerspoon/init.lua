-- Toggle Ghostty visibility — iTerm2 hotkey-window style.
local function toggleGhostty()
    local app = hs.application.get("com.mitchellh.ghostty")
    if app then
        if app:isFrontmost() then
            app:hide()
        else
            app:activate()
        end
    else
        hs.application.launchOrFocus("Ghostty")
    end
end

hs.hotkey.bind({ "cmd" }, "`", toggleGhostty)
hs.hotkey.bind({ "cmd" }, "escape", toggleGhostty)

hs.alert.show("Hammerspoon loaded", 1)
