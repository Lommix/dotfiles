hl.monitor({ output = "DP-1", mode = "2560x1440", position = "0x0", scale = 1 })
hl.monitor({ output = "DP-3", mode = "3440x1440@99.98Hz", position = "2560x0", scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080", position = "6000x0", scale = 1 })
hl.monitor({ output = "eDP-1", mode = "2880x1800@120.00000Hz", position = "0x0", scale = 2 })

hl.config({
  input = {
    kb_layout = "de",
    kb_variant = "nodeadkeys",
    numlock_by_default = true,
    repeat_delay = 300,
    repeat_rate = 50,
    touchpad = {
      natural_scroll = true,
      disable_while_typing = true,
      clickfinger_behavior = true,
      scroll_factor = 0.5,
    },
    special_fallthrough = true,
    follow_mouse = 1,
  },
})

hl.device({
  name = "wacom-intuos-bt-s-pen",
  output = "DP-3",
  relative_input = true,
})

hl.device({
  name = "wacom-intuos-m-pen",
  output = "DP-3",
  relative_input = false,
  region_size = { 3840, 2160 },
})

hl.config({
  binds = {
    scroll_event_delay = 0,
  },
})

hl.config({
  general = {
    gaps_in = 4,
    gaps_out = 8,
    gaps_workspaces = 0,
    border_size = 2,
    col = {
      active_border = "rgba(A0FFFFFF)",
      inactive_border = "rgba(000000FF)",
    },
    resize_on_border = true,
    no_focus_fallback = true,
    layout = "dwindle",
  },
})

hl.config({
  dwindle = {
    preserve_split = true,
    smart_resizing = true,
    smart_split = false,
    force_split = 1,
  },
})

hl.config({
  group = {
    col = {
      border_active = "rgba(A0FFFFFF)",
      border_inactive = "rgba(000000FF)",
    },
    groupbar = {
      gaps_out = 0,
      gaps_in = 0,
      indicator_height = 0,
      height = 22,
      rounding = 0,
      gradient_rounding = 0,
      enabled = true,
      gradients = true,
      col = {
        inactive = "rgba(183825FF)",
        active = "rgba(388545FF)",
        locked_active = "rgba(383845FF)",
        locked_inactive = "rgba(181825FF)",
      },
      gradient_round_only_edges = false,
      font_size = 13,
    },
  },
})

hl.config({
  decoration = {
    rounding = 2,
  },
})

hl.curve("linear", { type = "bezier", points = { {0, 0}, {1, 1} } })
hl.curve("md3_standard", { type = "bezier", points = { {0.2, 0}, {0, 1} } })
hl.curve("md3_decel", { type = "bezier", points = { {0.05, 0.7}, {0.1, 1} } })
hl.curve("md3_accel", { type = "bezier", points = { {0.3, 0}, {0.8, 0.15} } })
hl.curve("overshot", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.1} } })
hl.curve("crazyshot", { type = "bezier", points = { {0.1, 1.5}, {0.76, 0.92} } })
hl.curve("hyprnostretch", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.0} } })
hl.curve("menu_decel", { type = "bezier", points = { {0.1, 1}, {0, 1} } })
hl.curve("menu_accel", { type = "bezier", points = { {0.38, 0.04}, {1, 0.07} } })
hl.curve("easeInOutCirc", { type = "bezier", points = { {0.85, 0}, {0.15, 1} } })
hl.curve("easeOutCirc", { type = "bezier", points = { {0, 0.55}, {0.45, 1} } })
hl.curve("easeOutExpo", { type = "bezier", points = { {0.16, 1}, {0.3, 1} } })
hl.curve("softAcDecel", { type = "bezier", points = { {0.26, 0.26}, {0.15, 1} } })
hl.curve("md2", { type = "bezier", points = { {0.4, 0}, {0.2, 1} } })

hl.animation({ leaf = "windows", enabled = true, speed = 2, bezier = "md3_decel", style = "popin 60%" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 2, bezier = "md3_decel", style = "popin 60%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "md3_accel", style = "popin 60%" })
hl.animation({ leaf = "border", enabled = true, speed = 2, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 2, bezier = "md3_decel" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 2, bezier = "menu_decel", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2, bezier = "menu_accel" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 2, bezier = "menu_decel" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 2, bezier = "menu_accel" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "md2", style = "slidefadevert popin 40%" })

hl.config({
  misc = {
    vrr = 0,
    focus_on_activate = true,
    animate_manual_resizes = false,
    animate_mouse_windowdragging = false,
    enable_swallow = false,
    swallow_regex = "(foot|kitty|allacritty|Alacritty)",
    disable_hyprland_logo = true,
    force_default_wallpaper = 0,
    allow_session_lock_restore = true,
    initial_workspace_tracking = true,
    font_family = "Lilex Nerd Font Propo",
  },
})