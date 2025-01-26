local camera = {}

local screen = require("classes.screen")

local xStart, yStart = 0, 0
local cameraTarget, cameraGroup, snapshot


function camera.init( target, group, snapshotGroup )
	xStart, yStart = target.x, target.y
	cameraTarget, cameraGroup, snapshot = target, group, snapshotGroup
end


function camera.update()
	cameraGroup.x = xStart - cameraTarget.x - screen.width*0.5
	cameraGroup.y = yStart - cameraTarget.y - screen.height*0.5
	snapshot:invalidate()
end


return camera