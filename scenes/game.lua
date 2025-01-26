local composer = require("composer")
local scene = composer.newScene()

---------------------------------------------------------------------------

-- Common plugins, modules, libraries & classes.
local screen = require("classes.screen")
local camera = require("classes.camera")
local physics = require( "physics" )
local dialogueData = require("data.dialogue")
local environmentData = require("data.environment")
local loadsave, savedata

---------------------------------------------------------------------------

-- Forward declarations & variables.

local player
local dialogueImage, dialogueText, dialogueBox
local action = {}
local moveSpeed = 10
local groupLevel = display.newGroup()
local groupUI = display.newGroup()
local gameState = "normal"
local targetID

-------------------------------------------------
--MUSAT

local sfxMeow = audio.loadSound("assets/audio/mjay.wav" )
local sfxPappa = audio.loadSound("assets/audio/vanamees.wav" )
local sfxLapsi = audio.loadSound("assets/audio/lappso.wav" )
local sfxTeini = audio.loadSound("assets/audio/teini.wav" )
local sfxYhisa = audio.loadSound("assets/audio/yh_dadi.wav" )
local sfxAikunen = audio.loadSound("assets/audio/erotyty.wav" )

-- Filtering/effect/masking variables.
local viewNormal, viewGreyscale
local viewMask = graphics.newMask( "assets/images/mask.png" )
local viewMaskScale = 2
local greyscaleAlpha = 1

local backgroundMusic1 = audio.loadStream("assets/audio/biano1.ogg")
local backgroundMusic2 = audio.loadStream("assets/audio/biano2.ogg")
local backgroundMusic3 = audio.loadStream("assets/audio/biano3.ogg")
local backgroundMusic4 = audio.loadStream("assets/audio/biano4.ogg")
local backgroundMusic5 = audio.loadStream("assets/audio/biano5.ogg")

audio.setVolume( 0.2, { channel=1 } )
audio.setVolume( 0.0, { channel=2 } )
audio.setVolume( 0.0, { channel=3 } )
audio.setVolume( 0.0, { channel=4 } )
audio.setVolume( 0.0, { channel=5 } )
--audio.play( backgroundMusic1 )

--[[
audio.play( backgroundMusic1,{
	channel = 1, -- Määritetään erikseen taustamusiikin kanava.
	loops = -1, -- Laitetaan kappale soimaan ikuisesti.
	fadein = 3000, -- Nostetaan äänet 3s kuluessa nollasta halutulle tasolle.
	 onComplete = callbackListener
})

audio.play( backgroundMusic2,{
	channel = 2, -- Määritetään erikseen taustamusiikin kanava.
	loops = -1, -- Laitetaan kappale soimaan ikuisesti.
	fadein = 3000, -- Nostetaan äänet 3s kuluessa nollasta halutulle tasolle.
	-- onComplete = callbackListener
})

audio.play( backgroundMusic3,{
	channel = 3, -- Määritetään erikseen taustamusiikin kanava.
	loops = -1, -- Laitetaan kappale soimaan ikuisesti.
	fadein = 3000, -- Nostetaan äänet 3s kuluessa nollasta halutulle tasolle.
	-- onComplete = callbackListener
})

audio.play( backgroundMusic4,{
	channel = 4, -- Määritetään erikseen taustamusiikin kanava.
	loops = -1, -- Laitetaan kappale soimaan ikuisesti.
	fadein = 3000, -- Nostetaan äänet 3s kuluessa nollasta halutulle tasolle.
	-- onComplete = callbackListener
})


audio.play( backgroundMusic5,{
	channel = 5, -- Määritetään erikseen taustamusiikin kanava.
	loops = -1, -- Laitetaan kappale soimaan ikuisesti.
	fadein = 3000, -- Nostetaan äänet 3s kuluessa nollasta halutulle tasolle.
	-- onComplete = callbackListener
})

--]]





---------------------------------------------------------------------------

-- Functions.

-- Apply a grayscale effect to the screen and reveal a small
-- masked area around the player character normally.
local function updateView()
	-- Remove old views.
	display.remove( viewGreyscale )
	display.remove( viewNormal )

	-- Hide the dialogue UI so that they won't be affected by the view effects.
	if dialogueImage then
		dialogueImage.isVisible = false
		dialogueBox.isVisible = false
		dialogueText.isVisible = false
	end

	-- Create the greyscale view first so that it'll be behind the normal view,
	-- but don't apply the effect until the view has been copied/captured.
	viewGreyscale = display.captureScreen( groupLevel )
	viewGreyscale.x, viewGreyscale.y = screen.centerX, screen.centerY

	viewNormal = display.captureScreen( groupLevel )
	viewNormal.x, viewNormal.y = screen.centerX, screen.centerY

	viewGreyscale.fill.effect = "filter.grayscale"

	if dialogueImage then
		dialogueImage.isVisible = true
		dialogueBox.isVisible = true
		dialogueText.isVisible = true
		dialogueImage:toFront()
		dialogueBox:toFront()
		dialogueText:toFront()
	end

	-- Hide most of the "normal view" behind a mask.
	local scaleOffset = math.random( 100, 103 )*0.01
	viewNormal:setMask( viewMask )
	viewNormal.maskScaleX = viewMaskScale*scaleOffset
	viewNormal.maskScaleY = viewMaskScale*scaleOffset
	viewGreyscale.alpha = greyscaleAlpha
end

-- Stop and remove the view effects.
local function stopView()
	Runtime:removeEventListener( "enterFrame", updateView )
	display.remove( viewGreyscale )
	display.remove( viewNormal )
end


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

local dialogueProgress = {}

local function dialogueStart()
	gameState = "dialogue"
	Runtime:removeEventListener("enterFrame", moveCharacter)


	local data = dialogueData[targetID]
	if not dialogueProgress[targetID] then
		dialogueProgress[targetID] = 0
		if targetID == "characterName1" then --eri hahmoille äänet aina dialogin alkuun.
			audio.play( sfxPappa )
		end

		if targetID == "characterName2" then --eri hahmoille äänet aina dialogin alkuun.
			audio.play( sfxYhisa )
		end

		if targetID == "characterName3" then --eri hahmoille äänet aina dialogin alkuun.
			audio.play( sfxLapsi )
		end

		if targetID == "characterName4" then --eri hahmoille äänet aina dialogin alkuun.
			audio.play( sfxTeini )
		end

		if targetID == "characterName5" then --eri hahmoille äänet aina dialogin alkuun.
			audio.play( sfxAikunen )
		end

	end
	dialogueProgress[targetID] = dialogueProgress[targetID] +1

	-- Dialogue objects aren't inserted into any group due to view effect and draw order issues.
	dialogueImage = display.newImageRect( data.image, 960, 640 )
	dialogueImage.x = screen.centerX +300
	dialogueImage.y = screen.centerY

	dialogueBox = display.newImageRect( "assets/images/ui/puhekupla_sininen.png", 937, 695 )
	dialogueBox.x = screen.centerX
	dialogueBox.y = screen.centerY

	dialogueText = display.newText({
		text = data.text[dialogueProgress[targetID]],
		x = screen.centerX,
		y = screen.centerY +200,
		width = screen.width - 60,
		font = "assets/fonts/MedodicaRegular.otf",
		fontSize = 30,
		align = "center"
	})
	dialogueText:setFillColor(25/255, 30/255, 49/255)
end

local function dialogueEnd()
	gameState = "normal"
	audio.play( sfxMeow )
	Runtime:addEventListener("enterFrame", moveCharacter)


end


local function onKeyEvent( event )
	if event.phase == "down" then
		action[event.keyName] = true


		if event.keyName == "space" then
			if targetID then
				local gotDialogue = dialogueData[targetID]

				if gotDialogue and dialogueProgress[targetID] then
					gotDialogue = gotDialogue.text[dialogueProgress[targetID]+1]

				end

				display.remove(dialogueImage)
				display.remove(dialogueText)
				display.remove(dialogueBox)
				dialogueImage = nil
				dialogueText = nil
				dialogueBox = nil

				if (gameState == "normal" or gameState == "dialogue") and gotDialogue then
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

	local background = display.newImageRect( groupLevel,"assets/images/kartta.PNG", 1920, 1280 )

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

	player = display.newImageRect( groupLevel, "assets/images/kissaSEISOVA.PNG", 32, 32 )
	physics.addBody( player, "dynamic" )
	player.x = screen.centerX
	player.y = screen.centerY
	player.isFixedRotation = true

	player.collision = onLocalCollision
	player:addEventListener( "collision" )


	local characterA = display.newImageRect( groupLevel, "assets/images/vanhussprite.PNG", 32, 64 )
	--characterA:setFillColor( 1, 0, 1, 1 )
	characterA.x = screen.centerX -200
	characterA.y = screen.centerY
	physics.addBody( characterA, "static",
		{radius = characterA.width*0.5},
		{radius = characterA.width*3, isSensor=true}

	)
	characterA.id = "characterName1"

	local characterB = display.newImageRect( groupLevel, "assets/images/isasprite.PNG", 32, 64 )
	--characterB:setFillColor( 0.4, 1, 1, 1 )
	characterB.x = screen.centerX +200
	characterB.y = screen.centerY -550
	physics.addBody( characterB, "static",
		{radius = characterB.width*0.5},
		{radius = characterB.width*3, isSensor=true}

	)
	characterB.id = "characterName2"

	local characterC = display.newImageRect( groupLevel, "assets/images/lapsisprite.PNG", 32, 64 )
	--characterC:setFillColor( 0.4, 1, 1, 1 )
	characterC.x = screen.centerX -1200
	characterC.y = screen.centerY -600
	physics.addBody( characterC, "static",
		{radius = characterC.width*0.5},
		{radius = characterC.width*3, isSensor=true}

	)
	characterC.id = "characterName3"



	local characterE = display.newImageRect( groupLevel,"assets/images/aikuinensprite.PNG", 32, 64 )
	--characterE:setFillColor( 0.4, 1, 1, 1 )
	characterE.x = screen.centerX -1000
	characterE.y = screen.centerY -200
	physics.addBody( characterE, "static",
		{radius = characterE.width*0.5},
		{radius = characterE.width*3, isSensor=true}

	)
	characterE.id = "characterName5"


	local characterF = display.newImageRect( groupLevel,"assets/images/Vahtikoira.PNG", 38, 42 )
	--characterE:setFillColor( 0.4, 1, 1, 1 )
	characterF.x = screen.centerX -800
	characterF.y = screen.centerY -800
	physics.addBody( characterF, "static",
		{radius = characterF.width*0.5}
	)

	local tree1 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Puu.PNG", 64, 64 )
	--characterE:setFillColor( 0.4, 1, 1, 1 )
	tree1.x = screen.centerX -700
	tree1.y = screen.centerY -800
	physics.addBody( tree1, "static",
		{radius = tree1.width*0.5}
	)

	local talo1 = display.newImageRect( groupLevel,"assets/images/fixedpictures/ORANSSItalo.PNG", 513, 256)
	--characterE:setFillColor( 0.4, 1, 1, 1 )
	talo1.x = screen.centerX -1150
	talo1.y = screen.centerY -900
	physics.addBody( talo1, "static"
	)

	local talo2 = display.newImageRect( groupLevel,"assets/images/fixedpictures/VAALEEtalo.PNG", 513, 256)
	--characterE:setFillColor( 0.4, 1, 1, 1 )
	talo2.x = screen.centerX -150
	talo2.y = screen.centerY -900
	physics.addBody( talo2, "static"
	)

	local talo3 = display.newImageRect( groupLevel,"assets/images/fixedpictures/VAALEEtalo.PNG", 513, 256)
	--characterE:setFillColor( 0.4, 1, 1, 1 )
	talo3.x = screen.centerX +200
	talo3.y = screen.centerY
	physics.addBody( talo3, "static"
	)

	local talo4 = display.newImageRect( groupLevel,"assets/images/fixedpictures/ORANSSItalo.PNG", 513, 256)
	--characterE:setFillColor( 0.4, 1, 1, 1 )
	talo4.x = screen.centerX +150
	talo4.y = screen.centerY -900
	physics.addBody( talo4, "static"
	)
	local talo6 = display.newImageRect( groupLevel,"assets/images/fixedpictures/VIHREEtalo.PNG", 513, 256)
	--characterE:setFillColor( 0.4, 1, 1, 1 )
	talo6.x = screen.centerX -450
	talo6.y = screen.centerY -500
	physics.addBody( talo6, "static"
	)
	local talo5 = display.newImageRect( groupLevel,"assets/images/fixedpictures/VAALEEtalo.PNG", 513, 256)
	--characterE:setFillColor( 0.4, 1, 1, 1 )
	talo5.x = screen.centerX -450
	talo5.y = screen.centerY -300
	physics.addBody( talo5, "static"
	)

	local talo7 = display.newImageRect( groupLevel,"assets/images/fixedpictures/simppelitaloSININEN.PNG", 336, 256)
	--characterE:setFillColor( 0.4, 1, 1, 1 )
	talo7.x = screen.centerX +150
	talo7.y = screen.centerY -400
	physics.addBody( talo7, "static"
	)

	local talo7 = display.newImageRect( groupLevel,"assets/images/fixedpictures/simppelitaloSININEN.PNG", 336, 256)
	--characterE:setFillColor( 0.4, 1, 1, 1 )
	talo7.x = screen.centerX -1250
	talo7.y = screen.centerY +50
	physics.addBody( talo7, "static"
	)

	local talo7 = display.newImageRect( groupLevel,"assets/images/fixedpictures/simppelitaloSININEN.png", 336, 256)
	--characterE:setFillColor( 0.4, 1, 1, 1 )
	talo7.x = screen.centerX -1250
	talo7.y = screen.centerY +50
	physics.addBody( talo7, "static"
	)

		local characterD = display.newImageRect( groupLevel, "assets/images/teinisprite.png", 32, 64 )
	--characterD:setFillColor( 0.4, 1, 1, 1 )
	--display.contentCenterX -1200, display.contentCenterY +200,
	characterD.x = screen.centerX -1200
	characterD.y = screen.centerY +200
	physics.addBody( characterD, "static",
		{radius = characterD.width*0.5},
		{radius = characterD.width*3, isSensor=true}

	)
	characterD.id = "characterName4"

	
	local lampi1 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Lampi_ISO.png", 272*2, 77*2)
	--characterE:setFillColor( 0.4, 1, 1, 1 )
	lampi1.x = screen.centerX -520
	lampi1.y = screen.centerY +50
	physics.addBody( lampi1, "static"
	)

	local lampi2 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Lampi_PIENI.png", 272*2, 77*2)
	--characterE:setFillColor( 0.4, 1, 1, 1 )
	lampi2.x = screen.centerX -520
	lampi2.y = screen.centerY +50
	physics.addBody( lampi2, "static"
	)


	--characterF.id = "characterName6"
	-------------------------
	--fixed objects



	--[[ 	local tree = {}

	local treeData = {
	{ x=40, y=20 },
	{ x=80, y=30 },
	{ x=20, y=30 },
	}

	local function createTree( x, y )
		local tree = display.newImageRect("assets/images/fixedpictures/Puu.PNG",x, y, 64, 64 )
		tree.x = screen.centerX -400
		tree.y = screen.centerY -500
		physics.addBody( tree, "static",
		{radius = tree.width*0.5},
		{radius = tree.width*1, isSensor=true}

	)
		return tree
	end

	for i = 1, #treeData do
		tree[i] = createTree( treeData[i].x, treeData[i].y )
	end 
	]]--



	sceneGroup:insert( groupLevel)
	sceneGroup:insert( groupUI)

	camera.init( player, groupLevel )
	Runtime:addEventListener( "enterFrame", updateView )
	-- stopView()
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