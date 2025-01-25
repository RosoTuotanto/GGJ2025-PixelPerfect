local composer = require("composer")
local scene = composer.newScene()

---------------------------------------------------------------------------

-- Common plugins, modules, libraries & classes.
local screen = require("classes.screen")
local loadsave, savedata

---------------------------------------------------------------------------

-- Forward declarations & variables.

local player
local action = {}
local moveSpeed = 5


---------------------------------------------------------------------------

-- Functions.

local function moveCharacter()

	-- See if one of the selected action buttons is down and move the player.
	if action["a"] or action["left"] then
		player:translate( -moveSpeed, 0 )

	end
	if action["d"] or action["right"] then
		player:translate( moveSpeed, 0 )

	end
	if action["w"] or action["up"] then
		player:translate( 0, -moveSpeed )

	end
	if action["s"] or action["down"] then
		player:translate( 0, moveSpeed )

	end
end

local function onKeyEvent( event )
	if event.phase == "down" then
		action[event.keyName] = true

	else
		action[event.keyName] = false
	end
end
---------------------------------------------------------------------------

function scene:create( event )
	local sceneGroup = self.view
	-- If the project uses savedata, then load existing data or set it up.
	if event.params and event.params.usesSavedata then
		loadsave = require("classes.loadsave")
		savedata = loadsave.load("data.json")

		if not savedata then
			-- Assign initial values for save data.
			savedata = {

			}
			loadsave.save( savedata, "data.json" )
		end

		-- Assign/update variables based on save data, e.g. volume, highscores, etc.

	end


	local background = display.newRect( sceneGroup, display.contentCenterX, display.contentCenterY, 5500, 5500 )
	background.fill.effect = "generator.checkerboard"

	background.fill.effect.color1 = { 0.8, 0, 0.2, 1 }
	background.fill.effect.color2 = { 0.2, 0.2, 0.2, 1 }
	background.fill.effect.xStep = 32
	background.fill.effect.yStep = 32

	player = display.newRect( sceneGroup, display.contentCenterX, display.contentCenterY, 55, 55 )

	player:setFillColor( 1, 0, 1, 1 )



end

---------------------------------------------------------------------------

function scene:show( event )
	local sceneGroup = self.view

	if event.phase == "will" then
		-- If coming from launchScreen scene, then start by removing it.
		if composer._previousScene == "scenes.launchScreen" then
			composer.removeScene( "scenes.launchScreen" )
		end

	elseif event.phase == "did" then
		Runtime:addEventListener( "enterFrame", moveCharacter )
		Runtime:addEventListener( "key", onKeyEvent )

	end
end

---------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )

---------------------------------------------------------------------------

return scene