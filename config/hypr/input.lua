-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.

-- Give the Apple trackpad a macOS-like precision region: slow finger motion
-- is heavily decelerated, ordinary motion stays near the previous gain, and
-- fast flicks accelerate. A flat final gain prevents runaway extrapolation.
-- Based on fufexan's macOS-like cubic libinput curve, scaled to half gain
-- for this trackpad's high-resolution input and capped above speed 10.
-- https://gist.github.com/fufexan/e6bcccb7787116b8f9c31160fc8bc543
local trackpad_gain = {
  { 0.0, 0.0500 },
  { 0.5, 0.0531 },
  { 1.0, 0.0575 },
  { 2.0, 0.0700 },
  { 4.0, 0.1100 },
  { 6.0, 0.1700 },
  { 8.0, 0.2500 },
  { 10.0, 0.3500 },
  { 31.5, 0.3500 },
}

local function custom_accel_profile(step, npoints)
  local function gain_at(speed)
    if speed <= trackpad_gain[1][1] then return trackpad_gain[1][2] end
    for i = 1, #trackpad_gain - 1 do
      local x0, g0 = trackpad_gain[i][1], trackpad_gain[i][2]
      local x1, g1 = trackpad_gain[i + 1][1], trackpad_gain[i + 1][2]
      if speed <= x1 then return g0 + (g1 - g0) * (speed - x0) / (x1 - x0) end
    end
    return trackpad_gain[#trackpad_gain][2]
  end

  local points = {}
  for i = 0, npoints - 1 do
    local speed = i * step
    points[#points + 1] = string.format("%.4f", speed * gain_at(speed))
  end
  return string.format("custom %.3f %s", step, table.concat(points, " "))
end

hl.device({
  name = "apple-spi-trackpad",
  accel_profile = custom_accel_profile(0.5, 64),
  -- Accelerated two-finger scrolling: fine control at low speed and useful
  -- travel on deliberate swipes. Samples are spaced by 0.1 input units.
  scroll_points = "0.1 0.000 0.020 0.050 0.090 0.140 0.210 0.300 0.420 0.600 0.900 1.200 1.430 1.560",
})

-- Keep the more deliberate repeat timing used by the Fedora Asahi port. The
-- upstream 250 ms delay is easy to trigger on an Apple laptop keyboard and can
-- duplicate characters in the lock-screen password field.
hl.config({
  input = {
    repeat_rate = 40,
    repeat_delay = 600,
    sensitivity = 0.25,
    touchpad = {
      natural_scroll = true,
      tap_to_click = false,
      scroll_factor = 0.12,
    },
  },
})

-- Keyboard layout and options.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input
-- hl.config({
--   input = {
--     -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt.
--     kb_layout = "us,dk,eu",
--     kb_options = "compose:caps,shift:both_capslock_cancel,grp:alts_toggle",
--
--     -- Use a specific keyboard variant if needed (e.g. intl for international keyboards).
--     kb_variant = "intl",
--
--     -- Change speed of keyboard repeat.
--     repeat_rate = 40,
--     repeat_delay = 250,
--
--     -- Start with numlock on by default.
--     numlock_by_default = true,
--
--     -- Increase sensitivity for mouse/trackpad (default: 0).
--     sensitivity = 0.35,
--
--     -- Turn off mouse acceleration (default: adaptive).
--     accel_profile = "flat",
--
--     touchpad = {
--       -- Use natural (inverse) scrolling.
--       natural_scroll = true,
--
--       -- Use two-finger clicks for right-click instead of lower-right corner.
--       clickfinger_behavior = true,
--
--       -- Control the speed of your scrolling.
--       scroll_factor = 0.4,
--
--       -- Enable the touchpad while typing.
--       disable_while_typing = false,
--
--       -- Left-click-and-drag with three fingers.
--       drag_3fg = 1,
--     },
--   },
-- })

-- App-specific touchpad scroll speeds. Override Omarchy's accelerated terminal
-- defaults so terminal scrolling matches the system trackpad factor.
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 0.12 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.12 })
-- Chromium and Chromium --app windows add kinetic coasting themselves, so use
-- a gentler input scale there. Packaged web apps use chrome-<host>__-Default.
o.window("(chromium-browser|chrome-.*)", { scroll_touchpad = 0.015 })

-- Enable three-finger horizontal swipes for changing workspaces.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Enable touchpad gestures for moving focus (helpful on scrolling layout).
-- hl.gesture({ fingers = 3, direction = "left", action = function() hl.dispatch(hl.dsp.focus({ direction = "l" })) end })
-- hl.gesture({ fingers = 3, direction = "right", action = function() hl.dispatch(hl.dsp.focus({ direction = "r" })) end })
