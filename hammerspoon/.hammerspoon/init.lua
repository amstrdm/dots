-- Auto-apply saved display layouts when monitors change

local home = os.getenv("HOME")
local scriptPath = home .. "/dplayout/display-layout-manager.sh"

local function applyLayout()
	hs.task.new("/bin/bash", function() end, { scriptPath, "apply" }):start()
end

screenWatcher = hs.screen.watcher.new(function()
	-- small delay so macOS can finish detecting all screens
	hs.timer.doAfter(1, applyLayout)
end)

screenWatcher:start()

-- Optional: apply once on Hammerspoon reload
applyLayout()
