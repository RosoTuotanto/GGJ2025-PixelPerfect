local camera = {}


local xStart, yStart = 0, 0
local cameraTarget, cameraGroup


function camera.init( target, group )
	xStart, yStart = target.x, target.y
	cameraTarget, cameraGroup = target, group
end


function camera.update()
	cameraGroup.x = xStart - cameraTarget.x
	cameraGroup.y = yStart - cameraTarget.y
end


return camera