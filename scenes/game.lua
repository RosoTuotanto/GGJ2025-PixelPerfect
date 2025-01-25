local composer = require("composer")
local scene = composer.newScene()

---------------------------------------------------------------------------

-- Common plugins, modules, libraries & classes.
local screen = require("classes.screen")
local camera = require("classes.camera")
local physics = require( "physics" )
local dialogueData = require("data.dialogue")
local loadsave, savedata

---------------------------------------------------------------------------

-- Forward declarations & variables.

local player
local dialogueImage, dialogueText, dialogueBox
local action = {}
local moveSpeed = 15
local groupLevel = display.newGroup()
local groupUI = display.newGroup()
local gameState = "normal"
local targetID
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

	camera.update()
end


local function onLocalCollision( self, event )
	local other = event.other

	if other.id then

		if ( event.phase == "began" ) then
			targetID = other.id

		elseif ( event.phase == "ended" ) then
			targetID = nil

		end
	end
end


local function dialogueStart()
	gameState = "dialogue"
	Runtime:removeEventListener("enterFrame", moveCharacter)

	local data = dialogueData[targetID]
	for key, value in pairs(data) do
		print(key, value)
	end


	dialogueImage = display.newImageRect( groupUI, data.image, 960, 640 )
	dialogueImage.x = screen.centerX +300
	dialogueImage.y = screen.centerY

	dialogueBox = display.newImageRect( groupUI, "assets/images/ui/puhekupla.png", 937, 695 )
	dialogueBox.x = screen.centerX
	dialogueBox.y = screen.centerY

	dialogueText = display.newText({
			parent = groupUI,
			text = data.text,
			x = screen.centerX,
			y = screen.centerY,
			width = screen.width - 60,
			font = "assets/fonts/MedodicaRegular.otf",
			fontSize = 24,
			align = "center"
		})
end

local function dialogueEnd()
	gameState = "normal"
	Runtime:addEventListener("enterFrame", moveCharacter)

	display.remove(dialogueImage)
	display.remove(dialogueText)
	display.remove(dialogueBox)

end


local function onKeyEvent( event )
	if event.phase == "down" then
		action[event.keyName] = true


		if event.keyName == "space" then
			if targetID then

				if gameState == "normal" then
					dialogueStart()
				elseif gameState == "dialogue" then
					dialogueEnd()
				end
				--print(gameState)
			end
		end
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

	physics.start()
	physics.setGravity( 0, 0 )
	physics.setDrawMode( "hybrid" )

	local background = display.newRect( groupLevel, display.contentCenterX, display.contentCenterY, 5500, 5500 )
	background.fill.effect = "generator.checkerboard"
	background.fill.effect.color1 = { 0.8, 0, 0.2, 1 }
	background.fill.effect.color2 = { 0.2, 0.2, 0.2, 1 }
	background.fill.effect.xStep = 32
	background.fill.effect.yStep = 32

	physics.addBody( background, "static",
		{
			chain={
				-background.width*0.5, -background.height*0.5,
				background.width*0.5, -background.height*0.5,
				background.width*0.5, background.height*0.5,
				-background.width*0.5, background.height*0.5,
			},
			connectFirstAndLastChainVertex = true
		}
	)

	player = display.newRect( groupLevel, display.contentCenterX, display.contentCenterY, 55, 55 )
	player:setFillColor( 1, 0, 1, 1 )
	physics.addBody( player, "dynamic" )
	player.isFixedRotation = true

	player.collision = onLocalCollision
	player:addEventListener( "collision" )


	local characterA = display.newRect( groupLevel, display.contentCenterX +200, display.contentCenterY, 55, 55 )
	characterA:setFillColor( 1, 0, 1, 1 )
	physics.addBody( characterA, "static",
		{radius = characterA.width*0.5},
		{radius = characterA.width*2, isSensor=true}

	)
	characterA.id = "characterName1"


	sceneGroup:insert( groupLevel)
	sceneGroup:insert( groupUI)

	camera.init( player, groupLevel )
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