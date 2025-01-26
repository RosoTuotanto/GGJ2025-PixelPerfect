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
local startMessage
local action = {}
local character = {}
local moveSpeed = 10
local groupLevel = display.newGroup()
local gameState = "normal"
local targetID
local dialogueEndCount = 0

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

-- Kuinka lähellä hahmoa pitää olla, jotta se voi alkaa näkymään.
local characterDistanceInvisible = 128
-- Kuinka lähellä hahmoa pitää olla, jotta se näkyy täysin.
local characterDistanceFullyVisible = 90


local bgm = {
	audio.loadStream("assets/audio/biano1.ogg"),
	audio.loadStream("assets/audio/biano2.ogg"),
	audio.loadStream("assets/audio/biano3.ogg"),
	audio.loadStream("assets/audio/biano4.ogg"),
	audio.loadStream("assets/audio/biano5.ogg")
}

-- Testaillessa, aseta kaikki äänet pois:
--audio.setVolume( 0 )

-- Asetetaan taustamusiikin äänenvoimakkuus.
audio.setVolume( 0.2, { channel=1 } )
audio.setVolume( 0.2, { channel=2 } )
audio.setVolume( 0.2, { channel=3 } )
audio.setVolume( 0.2, { channel=4 } )
audio.setVolume( 0.2, { channel=5 } )
--audio.play( bgm[1] )



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

	for i = 1, #character do
		local distance = math.sqrt( (player.x-character[i].x)^2 + (player.y-character[i].y)^2 )

		if distance < characterDistanceFullyVisible then
			character[i].alpha = 1

		elseif distance < characterDistanceInvisible then
			local alpha = 1 - (distance-characterDistanceFullyVisible)/(characterDistanceInvisible-characterDistanceFullyVisible)

			character[i].alpha = alpha
		else
			character[i].alpha = 0

		end
	end
end

-- Stop and remove the view effects.
local function stopView()
	Runtime:removeEventListener( "enterFrame", updateView )
	display.remove( viewGreyscale )
	display.remove( viewNormal )

	for i = 1, #character do
		character[i].alpha = 0
	end
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


local function gameover()
	Runtime:removeEventListener("enterFrame", moveCharacter)
	gameState = "gameover"
	stopView()

	local imageloppu = display.newImageRect("assets/images/loppukuva.png", 1100, 700 )
		imageloppu.x = screen.centerX
		imageloppu.y = screen.centerY


end


local dialogueProgress = {}

local function dialogueStart()
	gameState = "dialogue"
	Runtime:removeEventListener("enterFrame", moveCharacter)


	local data = dialogueData[targetID]
	if not dialogueProgress[targetID] then
		dialogueProgress[targetID] = 0

		local availableChannel = audio.findFreeChannel( 10 )

		if targetID == "characterName1" then --eri hahmoille äänet aina dialogin alkuun.
			audio.play( sfxPappa, { channel=availableChannel } )
		end

		if targetID == "characterName2" then --eri hahmoille äänet aina dialogin alkuun.
			audio.play( sfxYhisa, { channel=availableChannel } )
		end

		if targetID == "characterName3" then --eri hahmoille äänet aina dialogin alkuun.
			audio.play( sfxLapsi, { channel=availableChannel } )
		end

		if targetID == "characterName4" then --eri hahmoille äänet aina dialogin alkuun.
			audio.play( sfxTeini, { channel=availableChannel } )
		end

		if targetID == "characterName5" then --eri hahmoille äänet aina dialogin alkuun.
			audio.play( sfxAikunen, { channel=availableChannel } )
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
	Runtime:addEventListener("enterFrame", moveCharacter)

	local availableChannel = audio.findFreeChannel( 10 )
	audio.play( sfxMeow, { channel=availableChannel } )

	-- Pidetään kirjaa siitä, kuinka monta dialogia on käyty läpi.
	dialogueEndCount = dialogueEndCount + 1

	local fadeTime = 3000

	-- print( dialogueEndCount )
	audio.fadeOut( { channel=dialogueEndCount, time=fadeTime } )

	greyscaleAlpha = greyscaleAlpha - 0.2
	if dialogueEndCount >= 5 then
		gameover()
	end

	-- Asetetaan seuraava taustamusiikki soimaan.
	audio.play( bgm[dialogueEndCount+1],{
		channel = dialogueEndCount+1, -- Määritetään erikseen taustamusiikin kanava.
		loops = -1, -- Laitetaan kappale soimaan ikuisesti.
		fadein = fadeTime, -- Nostetaan äänet 3s kuluessa nollasta halutulle tasolle.
		-- onComplete = callbackListener
	})
end


local function onKeyEvent( event )
	if event.phase == "down" then
		action[event.keyName] = true

		if startMessage then
			Runtime:addEventListener( "enterFrame", updateView )
			display.remove(startMessage)
			startMessage = nil
		end

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
	-- physics.setDrawMode( "hybrid" )

	local background = display.newImageRect( groupLevel,"assets/images/kartta.png", 1920, 1280 )

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

	player = display.newImageRect( groupLevel, "assets/images/kissaSEISOVA.png", 32, 32 )
	physics.addBody( player, "dynamic" )
	player.x = screen.centerX
	player.y = screen.centerY
	player.isFixedRotation = true

	player.collision = onLocalCollision
	player:addEventListener( "collision" )


	character[1] = display.newImageRect( groupLevel, "assets/images/vanhussprite.png", 32, 64 )
	--character[1]:setFillColor( 1, 0, 1, 1 )
	character[1].x = screen.centerX +200
	character[1].y = screen.centerY -200
	physics.addBody( character[1], "static",
		{radius = character[1].width*0.5},
		{radius = character[1].width*3, isSensor=true}

	)
	character[1].id = "characterName1"

	character[2] = display.newImageRect( groupLevel, "assets/images/isasprite.png", 32, 64 )
	--character[2]:setFillColor( 0.4, 1, 1, 1 )
	character[2].x = screen.centerX +300
	character[2].y = screen.centerY -650
	physics.addBody( character[2], "static",
		{radius = character[2].width*0.5},
		{radius = character[2].width*3, isSensor=true}

	)
	character[2].id = "characterName2"

	character[3] = display.newImageRect( groupLevel, "assets/images/lapsisprite.png", 32, 64 )
	--character[3]:setFillColor( 0.4, 1, 1, 1 )
	character[3].x = screen.centerX -1200
	character[3].y = screen.centerY -600
	physics.addBody( character[3], "static",
		{radius = character[3].width*0.5},
		{radius = character[3].width*3, isSensor=true}

	)
	character[3].id = "characterName3"


	character[5] = display.newImageRect( groupLevel,"assets/images/aikuinensprite.png", 32, 64 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	character[5].x = screen.centerX -1000
	character[5].y = screen.centerY -200
	physics.addBody( character[5], "static",
		{radius = character[5].width*0.5},
		{radius = character[5].width*3, isSensor=true}

	)
	character[5].id = "characterName5"


	local characterF = display.newImageRect( groupLevel,"assets/images/Vahtikoira.png", 38, 42 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	characterF.x = screen.centerX -800
	characterF.y = screen.centerY -850
	physics.addBody( characterF, "static",
		{radius = characterF.width*0.5}
	)

	local aita1 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Aita.png", 92, 42 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	aita1.x = screen.centerX -850
	aita1.y = screen.centerY -810
	physics.addBody( aita1, "static"
	)

	local aita2 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Aita.png", 92, 42 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	aita2.x = screen.centerX -750
	aita2.y = screen.centerY -810
	physics.addBody( aita2, "static"
	)

	local aita3 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Aita.png", 92, 42 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	aita3.x = screen.centerX -650
	aita3.y = screen.centerY -810
	physics.addBody( aita3, "static"
	)

	local aita4 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Aita.png", 92, 42 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	aita4.x = screen.centerX -550
	aita4.y = screen.centerY -810
	physics.addBody( aita4, "static"
	)

	local aita5 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Aita.png", 92, 42 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	aita5.x = screen.centerX -450
	aita5.y = screen.centerY -810
	physics.addBody( aita5, "static"
	)

	local tree1 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Puu.png", 64, 64 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	tree1.x = screen.centerX -700
	tree1.y = screen.centerY -900
	physics.addBody( tree1, "static",
		{radius = tree1.width*0.5}
	)

	local tree2 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Puu.png", 64, 64 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	tree2.x = screen.centerX -700
	tree2.y = screen.centerY +200
	physics.addBody( tree2, "static",
		{radius = tree2.width*0.5}
	)

	local tree3 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Puu.png", 64, 64 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	tree3.x = screen.centerX -600
	tree3.y = screen.centerY +250
	physics.addBody( tree3, "static",
		{radius = tree3.width*0.5}
	)

	local tree4 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Puu.png", 64, 64 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	tree4.x = screen.centerX -500
	tree4.y = screen.centerY +200
	physics.addBody( tree4, "static",
		{radius = tree4.width*0.5}
	)

	local tree5 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Puu.png", 64, 64 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	tree5.x = screen.centerX -400
	tree5.y = screen.centerY +250
	physics.addBody( tree5, "static",
		{radius = tree5.width*0.5}
	)

	local tree6 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Puu.png", 64, 64 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	tree6.x = screen.centerX -300
	tree6.y = screen.centerY +200
	physics.addBody( tree6, "static",
		{radius = tree6.width*0.5}
	)

	local tree7 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Puu.png", 64, 64 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	tree7.x = screen.centerX -500
	tree7.y = screen.centerY -890
	physics.addBody( tree7, "static",
		{radius = tree7.width*0.5}
	)

	local tree8 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Puu.png", 64, 64 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	tree8.x = screen.centerX -1100
	tree8.y = screen.centerY -600
	physics.addBody( tree8, "static",
		{radius = tree8.width*0.5}
	)

	local tree9 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Puu.png", 64, 64 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	tree9.x = screen.centerX -1200
	tree9.y = screen.centerY -350
	physics.addBody( tree9, "static",
		{radius = tree9.width*0.5}
	)

	local tree10 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Puu.png", 64, 64 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	tree10.x = screen.centerX -1300
	tree10.y = screen.centerY -400
	physics.addBody( tree10, "static",
		{radius = tree10.width*0.5}
	)

	local tree11 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Puu.png", 64, 64 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	tree11.x = screen.centerX -1050
	tree11.y = screen.centerY +100
	physics.addBody( tree11, "static",
		{radius = tree11.width*0.5}
	)

	local tree12 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Puu.png", 64, 64 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	tree12.x = screen.centerX -1000
	tree12.y = screen.centerY -50
	physics.addBody( tree12, "static",
		{radius = tree12.width*0.5}
	)

	local roskis1 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Roska-Astia.png", 33, 53 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	roskis1.x = screen.centerX -900
	roskis1.y = screen.centerY -530
	physics.addBody( roskis1, "static"
	)


	local roskis2 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Roska-Astia.png", 33, 53 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	roskis2.x = screen.centerX -1150
	roskis2.y = screen.centerY -260
	physics.addBody( roskis2, "static"
	)

	local penkki1 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Penkki.png", 70, 44 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	penkki1.x = screen.centerX -1000
	penkki1.y = screen.centerY -520
	physics.addBody( penkki1, "static"
	)

	local penkki2 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Penkki.png", 70, 44 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	penkki2.x = screen.centerX -1000
	penkki2.y = screen.centerY -250
	physics.addBody( penkki2, "static"
	)

	local penkki3 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Penkki.png", 70, 44 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	penkki3.x = screen.centerX -1300
	penkki3.y = screen.centerY -250
	physics.addBody( penkki3, "static"
	)

	local talo1 = display.newImageRect( groupLevel,"assets/images/fixedpictures/ORANSSItalo.png", 513, 256)
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	talo1.x = screen.centerX -1150
	talo1.y = screen.centerY -900
	physics.addBody( talo1, "static"
	)

	local talo2 = display.newImageRect( groupLevel,"assets/images/fixedpictures/VAALEEtalo.png", 513, 256)
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	talo2.x = screen.centerX -150
	talo2.y = screen.centerY -900
	physics.addBody( talo2, "static"
	)

	local talo3 = display.newImageRect( groupLevel,"assets/images/fixedpictures/VAALEEtalo.png", 513, 256)
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	talo3.x = screen.centerX +200
	talo3.y = screen.centerY
	physics.addBody( talo3, "static"
	)

	local talo4 = display.newImageRect( groupLevel,"assets/images/fixedpictures/ORANSSItalo.png", 513, 256)
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	talo4.x = screen.centerX +150
	talo4.y = screen.centerY -900
	physics.addBody( talo4, "static"
	)
	local talo6 = display.newImageRect( groupLevel,"assets/images/fixedpictures/VIHREEtalo.png", 513, 256)
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	talo6.x = screen.centerX -450
	talo6.y = screen.centerY -500
	physics.addBody( talo6, "static"
	)
	local talo5 = display.newImageRect( groupLevel,"assets/images/fixedpictures/VAALEEtalo.png", 513, 256)
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	talo5.x = screen.centerX -450
	talo5.y = screen.centerY -300
	physics.addBody( talo5, "static"
	)

	local talo7 = display.newImageRect( groupLevel,"assets/images/fixedpictures/simppelitaloSININEN.png", 336, 256)
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	talo7.x = screen.centerX +150
	talo7.y = screen.centerY -400
	physics.addBody( talo7, "static"
	)

	local talo8 = display.newImageRect( groupLevel,"assets/images/fixedpictures/simppelitaloSININEN.png", 336, 256)
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	talo8.x = screen.centerX -1250
	talo8.y = screen.centerY +50
	physics.addBody( talo8, "static"
	)

	local talo9 = display.newImageRect( groupLevel,"assets/images/fixedpictures/simppelitaloSININEN.png", 336, 256)
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	talo9.x = screen.centerX -1250
	talo9.y = screen.centerY +50
	physics.addBody( talo9, "static"
	)

	character[4] = display.newImageRect( groupLevel, "assets/images/teinisprite.png", 32, 64 )
	--character[4]:setFillColor( 0.4, 1, 1, 1 )
	--display.contentCenterX -1200, display.contentCenterY +200,
	character[4].x = screen.centerX -1200
	character[4].y = screen.centerY +200
	physics.addBody( character[4], "static",
		{radius = character[4].width*0.5},
		{radius = character[4].width*3, isSensor=true}

	)
	character[4].id = "characterName4"


	local lampi1 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Lampi_ISO.png", 272*2, 77*2)
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	lampi1.x = screen.centerX -520
	lampi1.y = screen.centerY +50
	physics.addBody( lampi1, "static"
	)

	local lampi2 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Lampi_PIENI.png", 125*2, 45*2)
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	lampi2.x = screen.centerX -1300
	lampi2.y = screen.centerY -500
	physics.addBody( lampi2, "static"
	)

	local kivi1 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Kivi.png", 32, 32 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	kivi1.x = screen.centerX -1400
	kivi1.y = screen.centerY -450
	physics.addBody( kivi1, "static"
	)

	local kivi2 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Kivi.png", 32, 32 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	kivi2.x = screen.centerX -1370
	kivi2.y = screen.centerY -440
	physics.addBody( kivi2, "static"
	)

	local lyhtypylvas1 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Lyhtypylvas.png", 27, 64 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	lyhtypylvas1.x = screen.centerX -1170
	lyhtypylvas1.y = screen.centerY -450
	physics.addBody( lyhtypylvas1, "static"
	)

	local lyhtypylvas2 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Lyhtypylvas.png", 27, 64 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	lyhtypylvas2.x = screen.centerX -900
	lyhtypylvas2.y = screen.centerY -270
	physics.addBody( lyhtypylvas2, "static"
	)

	local lyhtypylvas3 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Lyhtypylvas.png", 27, 64 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	lyhtypylvas3.x = screen.centerX -800
	lyhtypylvas3.y = screen.centerY -160
	physics.addBody( lyhtypylvas3, "static"
	)

	local lyhtypylvas4 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Lyhtypylvas.png", 27, 64 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	lyhtypylvas4.x = screen.centerX -500
	lyhtypylvas4.y = screen.centerY -160
	physics.addBody( lyhtypylvas4, "static"
	)


	local lyhtypylvas5 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Lyhtypylvas.png", 27, 64 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	lyhtypylvas5.x = screen.centerX -200
	lyhtypylvas5.y = screen.centerY -160
	physics.addBody( lyhtypylvas5, "static"
	)

	local lyhtypylvas6 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Lyhtypylvas.png", 27, 64 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	lyhtypylvas6.x = screen.centerX -50
	lyhtypylvas6.y = screen.centerY -260
	physics.addBody( lyhtypylvas6, "static"
	)

	local lyhtypylvas7 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Lyhtypylvas.png", 27, 64 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	lyhtypylvas7.x = screen.centerX -950
	lyhtypylvas7.y = screen.centerY +150
	physics.addBody( lyhtypylvas7, "static"
	)

	local lyhtypylvas8 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Lyhtypylvas.png", 27, 64 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	lyhtypylvas8.x = screen.centerX -200
	lyhtypylvas8.y = screen.centerY -780
	physics.addBody( lyhtypylvas8, "static"
	)

	local penkki4 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Penkki.png", 70, 44 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	penkki4.x = screen.centerX -550
	penkki4.y = screen.centerY -150
	physics.addBody( penkki4, "static"
	)

	local penkki5 = display.newImageRect( groupLevel,"assets/images/fixedpictures/Penkki.png", 70, 44 )
	--character[5]:setFillColor( 0.4, 1, 1, 1 )
	penkki5.x = screen.centerX -150
	penkki5.y = screen.centerY -770
	physics.addBody( penkki5, "static"
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
		local tree = display.newImageRect("assets/images/fixedpictures/Puu.png",x, y, 64, 64 )
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

	camera.init( player, groupLevel )

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

		audio.play( bgm[1],{
			channel = 1, -- Määritetään erikseen taustamusiikin kanava.
			loops = -1, -- Laitetaan kappale soimaan ikuisesti.
			fadein = 3000, -- Nostetaan äänet 3s kuluessa nollasta halutulle tasolle.
			--  onComplete = callbackListener
		})

		startMessage = display.newImageRect("assets/images/kansikuva.png", 1100, 700 )
		startMessage.x = screen.centerX
		startMessage.y = screen.centerY
	end
end

---------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )

---------------------------------------------------------------------------

return scene