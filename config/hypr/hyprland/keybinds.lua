local browser = "firefox-developer-edition"
local files = "dolphin"
local launcher = "fuzzel"
local term = "kitty"

hl.bind("SUPER + XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { locked = true })
hl.bind("ALT + XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%"), { locked = true })
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%"), { locked = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, non_consuming = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, non_consuming = true })

hl.bind("SUPER + B", hl.dsp.exec_cmd("killall -SIGUSR1 waybar"))

hl.bind("SUPER + Return", hl.dsp.exec_cmd(term))
hl.bind("SUPER + D", hl.dsp.exec_cmd(launcher))
hl.bind("SUPER + E", hl.dsp.exec_cmd(files))
hl.bind("SUPER + W", hl.dsp.exec_cmd(browser))
hl.bind("SUPER + F", hl.dsp.window.fullscreen())
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload; killall ags hyprpaper; ags & hyprpaper"))
hl.bind("SUPER + O", hl.dsp.exec_cmd("flatpak run md.obsidian.Obsidian"))
hl.bind("SUPER + A", hl.dsp.exec_cmd("aseprite"))

hl.bind("SUPER + SHIFT + Q", hl.dsp.window.kill())
hl.bind("SUPER + SHIFT + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + SHIFT + X", hl.dsp.exit())
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd([[grim -g "$(slurp)" - | swappy -f -]]))
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("~/.local/bin/colorpicker.sh"))

-- poe
-- hl.bind("SHIFT + mouse_up", hl.dsp.exec_cmd("wlrctl pointer click"))
-- hl.bind("SHIFT + mouse_down", hl.dsp.exec_cmd("wlrctl pointer click"))
-- hl.bind("CONTROL + mouse_up", hl.dsp.exec_cmd("wlrctl pointer click right"))
-- hl.bind("CONTROL + mouse_down", hl.dsp.exec_cmd("wlrctl pointer click right"))

hl.bind("SUPER + SHIFT + T", hl.dsp.group.toggle())
hl.bind("SUPER + SHIFT + L", hl.dsp.group.lock_active({ action = "toggle" }))

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + down", hl.dsp.window.move({ direction = "down" }))
hl.bind("SUPER + P", hl.dsp.window.pin())

hl.bind("SUPER + h", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + l", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + j", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + k", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + CONTROL + h", hl.dsp.group.prev())
hl.bind("SUPER + CONTROL + l", hl.dsp.group.next())

hl.bind("SUPER + Minus", hl.dsp.layout("splitratio -0.02"), { non_consuming = true })
hl.bind("SUPER + Plus", hl.dsp.layout("splitratio +0.02"), { non_consuming = true })

for i = 1, 10 do
  local key = i % 10
  hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("loginctl lock-session && systemctl suspend"), { locked = true })
