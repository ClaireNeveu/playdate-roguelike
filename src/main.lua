import "CoreLibs/sprites"
import "CoreLibs/animation"
import "CoreLibs/graphics"
import "Fish/fish"
import "Ground/ground"
import "Seaweed/seaweed"
import "Score/score"

playdate.display.setRefreshRate(60)

local gfx = playdate.graphics
local spritelib = gfx.sprite
local screenWidth = playdate.display.getWidth()
local screenHeight = playdate.display.getHeight()

-- reset the screen to white
gfx.setBackgroundColor(gfx.kColorWhite)
gfx.setColor(gfx.kColorWhite)
gfx.fillRect(0, 0, screenWidth, screenHeight)


-- ! game states

local kGameState = {initial, ready, playing, paused, over}
local currentState = kGameState.initial

local kGameInitialState, kGameGetReadyState, kGamePlayingState, kGamePausedState, kGameOverState = 0, 1, 2, 3, 4
local gameState = kGameInitialState


local ticks = 0

local playerImage = gfx.image.new("images/player")
assert( playerImage ) -- make sure the image was where we thought

playerSprite = gfx.sprite.new( playerImage )
playerSprite:moveTo( 200, 220 ) -- this is where the center of the sprite is placed; (200,120) is the center of the Playdate screen
playerSprite:add()

local swordImage = gfx.image.new("images/sword")
assert( swordImage ) -- make sure the image was where we thought

swordSprite = gfx.sprite.new( swordImage )
swordSprite:setCenter(0.5, 1)
swordSprite:moveTo( 200, 215 ) -- this is where the center of the sprite is placed; (200,120) is the center of the Playdate screen
swordSprite:add()
swordSprite:setRotation(90)
swordSprite:setCollideRect(0, 0, 3, 58)

batImages = playdate.graphics.imagetable.new('images/bat_normal')
assert(batImages)
batLoop = gfx.animation.loop.new(200, batImages, true)
batSprite = gfx.sprite.new( batLoop:image() )
batSprite:moveTo( 60, 75 )
batSprite:add()
batSprite:setCollideRect(0, 0, 32, 32)

local titleSprite = spritelib.new()
titleSprite:setImage(gfx.image.new('images/gameOver'))
titleSprite:moveTo(screenWidth / 2, screenHeight / 2.5)
titleSprite:setZIndex(950)
titleSprite:addSprite()
titleSprite:setVisible(false)

batSprite.update = function()
    batSprite:setImage(batLoop:image())
    -- Optionally, removing the sprite when the animation finished
    if not batLoop:isValid() then
        batSprite:remove()
    end
end

local function gameOver()

	gameState = kGameOverState

	titleSprite:setImage(gfx.image.new('images/gameOver'))
	titleSprite:setVisible(true)
	
	ticks = 0
end

-- this function supplies an image to be displayed during the game when the player opens the system menu
function playdate.gameWillPause()

	local img = gfx.image.new('menuImage')

	gfx.lockFocus(img)
	gfx.setFont(score.scoreFont)
	gfx.drawTextAligned(score.score, 200, 6, kTextAlignment.right)
	gfx.unlockFocus()

	playdate.setMenuImage(img, 10)

end

-- this function supplies an image to be displayed during the game when the player opens the system menu
function playdate.gameWillPause()

	local img = gfx.image.new('menuImage')

	gfx.lockFocus(img)
	gfx.unlockFocus()

	playdate.setMenuImage(img, 10)

end

local batAngle = 90

function playdate.update()
	
	ticks = ticks + 1
	local screenWidth, screenHeight = playdate.display.getSize()

	if gameState == kGameInitialState then

		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(0, 0, screenWidth, screenHeight)
		local playButton = gfx.image.new('images/playButton')
		local y = screenHeight/2 - playButton.height/2
		titleSprite:setVisible(false)
		swordSprite:setVisible(true)
		playerSprite:setVisible(true)
		batSprite:setVisible(true)
		swordSprite:moveTo( 200, 215 )
		playerSprite:moveTo( 200, 220 )
		batSprite:moveTo( 60, 75 )
		if playdate.buttonIsPressed( playdate.kButtonA ) then
			gameState = kGamePlayingState
		end
		if playdate.buttonIsPressed( playdate.kButtonB ) then
			gameState = kGamePlayingState
		end
		playButton:draw(screenWidth/2 - playButton.width/2, y)

	elseif gameState == kGameOverState then
		titleSprite:setVisible(true)
		swordSprite:setVisible(false)
		playerSprite:setVisible(false)
		batSprite:setVisible(false)
		gfx.sprite.update()
		if playdate.buttonIsPressed( playdate.kButtonA ) then
			gameState = kGameInitialState
		end
		if playdate.buttonIsPressed( playdate.kButtonB ) then
			gameState = kGameInitialState
		end
	else
		if playdate.buttonIsPressed( playdate.kButtonRight ) then
			playerSprite:moveBy( 2, 0 )
			swordSprite:moveBy( 2, 0 )
		end
		if playdate.buttonIsPressed( playdate.kButtonLeft ) then
			playerSprite:moveBy( -2, 0 )
			swordSprite:moveBy( -2, 0 )
		end

		local angle = playdate.getCrankPosition()
		swordSprite:setRotation(angle)

		batAngle = batAngle + math.random(30) - 15
		if batAngle > 360 then
			batAngle -= 360
		elseif batAngle < 0 then
			batAngle += 360
		end

		batSprite:moveBy(2 * math.cos(math.rad(batAngle)), 2 * math.sin(math.rad(batAngle)))

		if batSprite.x > screenWidth then
			batSprite:moveBy(0 - 2 * (batSprite.x - screenWidth), 0)
			batAngle += 180
			if batAngle > 360 then
				batAngle -= 360
			elseif batAngle < 0 then
				batAngle += 360
			end
		end
		if batSprite.y > screenHeight then
			batSprite:moveBy(0, 0 - 2 * (batSprite.y - screenHeight))
			batAngle += 180
			if batAngle > 360 then
				batAngle -= 360
			elseif batAngle < 0 then
				batAngle += 360
			end
		end

		if batSprite.x < 0 then
			batSprite:moveBy(2 * (0 - batSprite.x), 0)
			batAngle += 180
			if batAngle > 360 then
				batAngle -= 360
			elseif batAngle < 0 then
				batAngle += 360
			end
		end
		if batSprite.y < 0 then
			batSprite:moveBy(0, 2 * (0 - batSprite.y))
			batAngle += 180
			if batAngle > 360 then
				batAngle -= 360
			elseif batAngle < 0 then
				batAngle += 360
			end
		end

		if #(batSprite:overlappingSprites()) > 0 then
			gameState = kGameOverState
		end
	
		-- Call the functions below in playdate.update() to draw sprites and keep
		-- timers updated. (We aren't using timers in this example, but in most
		-- average-complexity games, you will.)
	
		gfx.sprite.update()
	end

end