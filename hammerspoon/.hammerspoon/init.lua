local home = os.getenv("HOME")
local script = home .. "/dplayout/display-layout-manager.sh"

-- Check once at startup if the script exists
if not hs.fs.attributes(script, "mode") then
	hs.alert.show("Display script not found:\n" .. script)
	print("[DisplayLayout] ERROR: script not found at " .. script)
end

local function runLayout(action)
	-- If script missing, abort early
	if not hs.fs.attributes(script, "mode") then
		hs.alert.show("Cannot " .. action .. " layout.\nScript missing:\n" .. script)
		print("[DisplayLayout] ABORT: script missing for action " .. action)
		return
	end

	-- Use zsh login shell so PATH etc. are loaded (like in your terminal)
	local cmd = string.format("/bin/zsh -lc '%s %s'", script, action)
	local ok, out, err, rc = hs.execute(cmd, true)

	print(
		string.format(
			"[DisplayLayout] action=%s ok=%s rc=%s\nOUT:\n%s\nERR:\n%s\n",
			action,
			tostring(ok),
			tostring(rc),
			out or "",
			err or ""
		)
	)

	if not ok or rc ~= 0 then
		hs.alert.show("Display layout " .. action .. " failed (see Console)")
		return
	end

	local pastTense = {
		save = "saved",
		apply = "applied",
	}

	hs.alert.show("Display layout " .. (pastTense[action] or action))
end

-- ===== Auto-apply toggle =====

local autoApplyEnabled = true -- default: ON
local screenWatcher = nil
local menuIcon = hs.menubar.new()

local function autoApply()
	runLayout("apply")
end

-- Screen watcher callback
local function screenChanged()
	if not autoApplyEnabled then
		return
	end
	-- small delay so macOS can finish detecting all screens
	hs.timer.doAfter(1, autoApply)
end

screenWatcher = hs.screen.watcher.new(screenChanged)
screenWatcher:start()

-- ===== MENU BAR ICON & MENU =====

local function rebuildMenu()
	menuIcon:setTitle("🖥")
	menuIcon:setMenu({
		{
			title = autoApplyEnabled and "✅ Auto-Apply: On" or "❌ Auto-Apply: Off",
			fn = function()
				autoApplyEnabled = not autoApplyEnabled
				hs.alert.show("Auto-Apply " .. (autoApplyEnabled and "enabled" or "disabled"))
				rebuildMenu()
			end,
		},
		{ title = "-" },
		{
			title = "Save Layout",
			fn = function()
				runLayout("save")
			end,
		},
		{
			title = "Apply Layout (once)",
			fn = function()
				runLayout("apply")
			end,
		},
		{ title = "-" },
		{
			title = "Reload Config",
			fn = function()
				hs.reload()
			end,
		},
	})
end

rebuildMenu()

-- Optional: apply once on reload (only if auto-apply is currently enabled)
if autoApplyEnabled then
	autoApply()
end

hs.window.animationDuration = 0

local function moveWindowToNextDisplayAndFullscreen()
	local win = hs.window.focusedWindow()
	if not win then
		return
	end

	local wasFullscreen = win:isFullScreen()

	-- Step 1: if already in true macOS fullscreen, leave fullscreen first
	if wasFullscreen then
		win:setFullScreen(false)
		hs.timer.usleep(900000) -- wait 0.9 sec for macOS Space transition
	end

	-- Step 2: move to next display
	win = hs.window.focusedWindow()
	if not win then
		return
	end

	local screen = win:screen()
	local nextScreen = screen:next()

	win:moveToScreen(nextScreen, false, true, 0)
	hs.timer.usleep(300000)

	-- Step 3: enter true macOS fullscreen
	win = hs.window.focusedWindow()
	if win then
		win:setFullScreen(true)
	end
end

hs.hotkey.bind({ "cmd", "ctrl", "alt" }, "Right", moveWindowToNextDisplayAndFullscreen)
