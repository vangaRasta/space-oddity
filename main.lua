-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local widget = require "widget"
local gameStatus = 0

local yLand = display.actualContentHeight - display.actualContentHeight * 0.2
local hLand = display.actualContentHeight * 0.1
local xLand = display.contentCenterX

local xBuild = display.actualContentWidth + 30

local yBird = display.contentCenterY - 50
local xBird = 50

local wPipe = display.contentCenterX + 10
local yReady = display.contentCenterY - 100

local uBird = -200
local vBird = 0
local wBird = -320
local g = 800
local dt = 0.025

local score = 0
local bestScore = 0
local scoreStep = 5
local gameSpeed = 25
local gameLoopTimer

local bird
local land
local title
local getReady
local gameOver
local emitter
local city
local building1,building2,building3

local board
local scoreTitle
local bestTitle
local silver
local gold
local levelBar

local upBtn
local downBtn

local moveX
local moveY = -50

local difCount = 2

local pipes = {}
local awards = {}

local function loadSounds()
  dieSound = audio.loadSound("Sounds/sfx_die.mp3")
  hitSound = audio.loadSound("Sounds/sfx_hit.mp3")
  pointSound = audio.loadSound("Sounds/sfx_point.mp3")
  swooshingSound = audio.loadSound("Sounds/sfx_swooshing.mp3")
  wingSound = audio.loadSound("Sounds/sfx_wing.mp3")
  boomSound = audio.loadSound("Sounds/sfx_boom.mp3")
end

local function calcRandomHole(m, n)
  return m * math.random(n)
end

local function loadBestScore()
  local path = system.pathForFile("bestscore.txt", system.DocumentsDirectory)

  -- Open the file handle
  local file, errorString = io.open(path, "r")

  if not file then
    -- Error occurred; output the cause
    print("File error: " .. errorString)
  else
    -- Read data from file
    local contents = file:read("*a")
    -- Output the file contents
    bestScore = tonumber(contents)
    -- Close the file handle
    io.close(file)
  end

  file = nil
end

local function saveBestScore()
  -- Path for the file to write
  local path = system.pathForFile("bestscore.txt", system.DocumentsDirectory)
  local file, errorString = io.open(path, "w")
  if not file then
    -- Error occurred; output the cause
    print("File error: " .. errorString)
  else
    file:write(bestScore)
    io.close(file)
  end
  file = nil

  -- show appodeal ad
  --  appodeal.show()
end

local function setupBird()
  local options = {
    width = 70,
    height = 50,
    numFrames = 4,
    sheetContentWidth = 280, -- width of original 1x size of entire sheet
    sheetContentHeight = 50 -- height of original 1x size of entire sheet
  }
  local imageSheet = graphics.newImageSheet("Assets/bird.png", options)

  local sequenceData = {
    name = "walking",
    start = 1,
    count = 4,
    time = 800,
    loopCount = 0, -- Optional ; default is 0 (loop indefinitely)
    loopDirection = "bounce" -- Optional ; values include "forward" or "bounce"
  }
  bird = display.newSprite(imageSheet, sequenceData)
  bird.x = xBird
  bird.y = yBird
end

local function prompt(tempo)
  bird:play()
end

local function initGame()
  gameSpeed = 25
  difCount = 2
  --[[ if gameLoopTimer ~= nil then
    timer.cancel(gameLoopTimer)
    gameLoopTimer = timer.performWithDelay(gameSpeed, gameLoop, 0)
  end ]]
  
  score = 0
  scoreStep = 5
  title.text = score
  --  title.text = hLand

  for i = 1, 6 do
    pipes[i].x = 400 + display.contentCenterX * (i - 1)
    pipes[i].y = calcRandomHole(20, 10)
  end

  --[[ for i = 1, 2 do
    awards[i].x = 400 + display.contentCenterX * (i - 1)
    awards[i].y = calcRandomHole(30, 10)
  end ]]

  yBird = display.contentCenterY - 50
  xBird = 50
  getReady.y = 0
  getReady.alpha = 1
  gameOver.y = 0
  gameOver.alpha = 0
  board.y = 0
  board.alpha = 0
  audio.play(swooshingSound)
  transition.to(bird, {time = 300, x = xBird, y = yBird, rotation = 0})
  transition.to(getReady, {time = 600, y = yReady, transition = easing.outBounce, onComplete = prompt})
end

local onPressEventButtonUp = function(event)
  if (gameStatus == 1) then
    moveY = bird.y - 10
  end
end

local onPressEventButtonDown = function(event)
  if (gameStatus == 1) then
    moveY = bird.y + 10
  end
end

local function wing()
  if gameStatus == 0 then
    gameStatus = 1
    getReady.alpha = 0
  end

  if gameStatus == 1 then
    --vBird = wBird
    bird:play()
    audio.play(wingSound)
  end

  if gameStatus == 3 then
    gameStatus = 0
    initGame()
  end
end

local function setupExplosion()
  local dx = 31
  local p = "Assets/habra.png"
  local emitterParams = {
    startParticleSizeVariance = dx / 2,
    startColorAlpha = 0.61,
    startColorGreen = 0.3031555,
    startColorRed = 0.08373094,
    yCoordFlipped = 0,
    blendFuncSource = 770,
    blendFuncDestination = 1,
    rotatePerSecondVariance = 153.95,
    particleLifespan = 0.7237,
    tangentialAcceleration = -144.74,
    startParticleSize = dx,
    textureFileName = p,
    startColorVarianceAlpha = 1,
    maxParticles = 128,
    finishParticleSize = dx / 3,
    duration = 0.75,
    finishColorRed = 0.078,
    finishColorAlpha = 0.75,
    finishColorBlue = 0.3699196,
    finishColorGreen = 0.5443883,
    maxRadiusVariance = 172.63,
    finishParticleSizeVariance = dx / 2,
    gravityy = 220.0,
    speedVariance = 258.79,
    tangentialAccelVariance = -92.11,
    angleVariance = -300.0,
    angle = -900.11
  }
  emitter = display.newEmitter(emitterParams)
  emitter:stop()
end

local function explosion()
  emitter.x = bird.x
  emitter.y = bird.y
  emitter:start()
end

local function crash()
  gameStatus = 3
  audio.play(hitSound)
  gameOver.y = 0
  gameOver.alpha = 1
  transition.to(gameOver, {time = 600, y = yReady, transition = easing.outBounce})
  board.y = 0
  board.alpha = 1

  if score > bestScore then
    bestScore = score
    saveBestScore()
  end
  bestTitle.text = bestScore
  scoreTitle.text = score
  if score < 10 then
    silver.alpha = 0
    gold.alpha = 0
  elseif score < 50 then
    silver.alpha = 1
    gold.alpha = 0
  else
    silver.alpha = 0
    gold.alpha = 1
  end
  transition.to(board, {time = 600, y = yReady + 100, transition = easing.outBounce})
end

local function collision(obj)
  local eps = 10
  local dx = obj.width -- horizontal space of hole
  local dy = obj.height -- vertical space of hole
  local boom = 0
  local x = obj.x
  local y = obj.y

  local difx = xBird - x
  local dify = yBird - y

  if difx < 0 then
    difx = difx * -1
  end

  if dify < 0 then
    dify = dify * -1
  end

  if difx < dx and dify < dy then
    --obj:removeSelf()
    boom = 1
  end

  if yBird < -eps then
    boom = 1
  end

  if yBird > yLand - eps then
    boom = 1
  end

  return boom
end

local function gameLoop()
  local eps = 10
  local leftEdge = -60
  
  if gameStatus == 1 then
    xLand = xLand + dt * uBird        
    if xLand < 0 then
      xLand = display.contentCenterX * 2 + xLand
    end
    land.x = xLand
    
    xBuild = xBuild + dt * uBird
    building2.x = xBuild
    if building2.x < -328 then
      building2:translate( display.actualContentWidth*2, 0 )
      xBuild = display.actualContentWidth*2
    end

    for i = 1, difCount do      
      local xb = xBird - eps
      local xOld = pipes[i].x
      local x = xOld + dt * uBird * 1.5
      if x < leftEdge then
        x = wPipe * 3 + x
        pipes[i].y = calcRandomHole(25, 10)
      end
      if xOld > xb and x <= xb then
        score = score + 1
        title.text = score
      end
      pipes[i].x = x
      if collision(pipes[i]) == 1 then
        explosion()
        audio.play(dieSound)
        gameStatus = 2
        crash()
      end
    end

    --[[ for i = 1, 2 do
      local xb = xBird - eps
      local xOld = awards[i].x
      local x = xOld + dt * uBird
      if x < leftEdge then
        x = wPipe * 3 + x
        awards[i].y = calcRandomHole(20, 10)
      end
      awards[i].x = x
      if collision(awards[i]) == 1 then
        --score = score + 10
        audio.play(pointSound)
      end
    end ]]
    
    if score == 0 then
      gameSpeed = 25
      difCount = 3
      timer.cancel(gameLoopTimer)
      gameLoopTimer = timer.performWithDelay(gameSpeed, gameLoop, 0)      
    end
    

    if score == scoreStep then
      scoreStep = scoreStep + 5
      audio.play(pointSound)
      if gameSpeed > 5 then
        gameSpeed = gameSpeed - 2
        timer.cancel(gameLoopTimer)
        gameLoopTimer = timer.performWithDelay(gameSpeed, gameLoop, 0)        
      end

      if difCount < 6 then
        difCount = difCount + 1
      end

    end
  end
  
  if gameStatus == 1 --[[ or gameStatus == 2 ]] then
    --vBird = vBird + dt * g
    --yBird = yBird + dt * vBird

    if moveY ~= -50 then
      yBird = moveY
      moveY = -50
    end

    --[[ if yBird > yLand - eps then
      yBird = yLand - eps
      crash()
    end ]]
    bird.x = xBird
    bird.y = yBird
  --[[ if gameStatus == 1 then
      bird.rotation = -30 * math.atan(vBird / uBird)
    else
      bird.rotation = vBird / 8
    end ]]
  end
end

function drawLevelbar()
  local levelPosX = levelBar.x
  local levelPosY = levelBar.y
  levelBar = display.newImageRect("Assets/minus.png", 24, 24)
  levelBar.x = levelPosX + 5
  levelBar.y = levelPosY
end

local function setupLand()
  land = display.newImageRect("Assets/land.png", display.actualContentWidth * 2, 1)
  land.x = xLand
  land.y = yLand + hLand

  --Top button
  upBtn =
    widget.newButton {
    id = "btnUp",
    width = 50,
    height = 50,
    defaultFile = "Assets/up.png",
    overFile = "Assets/up.png",
    onPress = onPressEventButtonUp
  }
  upBtn.x = display.actualContentWidth - 80
  upBtn.y = display.actualContentHeight - 30
  --Down button
  downBtn =
    widget.newButton {
    id = "btnDown",
    width = 50,
    height = 50,
    defaultFile = "Assets/down.png",
    overFile = "Assets/down.png",
    onPress = onPressEventButtonDown
  }
  downBtn.x = 0
  downBtn.y = display.actualContentHeight - 30

  local txt = {
    x = display.contentCenterX,
    y =  display.actualContentHeight - 30,
    text = "Score: ",
    font = "Assets/troika.otf",
    fontSize = 35
  }

  title = display.newText(txt)
  title:setFillColor(1, 1, 1)

  
  --[[ levelBar = display.newImageRect("Assets/minus.png", 24, 24)
  levelBar.x = title.x - 50
  levelBar.y = display.actualContentHeight - 30 ]]
end

local function setupImages()
  local ground = display.newImageRect("Assets/ground.png", display.actualContentWidth, display.actualContentHeight)
  ground.x = display.contentCenterX
  ground.y = display.contentCenterY
  ground:addEventListener("tap", wing)
  
  city = display.newImageRect("Assets/city.png", display.actualContentWidth, display.actualContentHeight)
  city.x = display.contentCenterX
  city.y = display.contentCenterY
  
  building2 = display.newImageRect("Assets/building.png", display.actualContentWidth, display.actualContentHeight)
  building2.x = display.contentCenterX
  building2.y = display.contentCenterY

  local imageArray = {
    "Assets/currency.png",
    "Assets/bug.png",
    "Assets/security.png",
    "Assets/server-crash.png",
    "Assets/spam.png",
    "Assets/phishing.png"
  }

  for i = 1, 6 do
    pipes[i] = display.newImageRect(imageArray[i], 40, 40)
    pipes[i].x = 440 + wPipe * (i - 1)
    pipes[i].y = calcRandomHole(25, 10)
    transition.blink( pipes[i], { time=2500 } )   
  end

  --[[ for i = 1, 2 do
    awards[i] = display.newImageRect("Assets/gold.png", 40, 40)
    awards[i].x = calcRandomHole(30, 10)
    awards[i].y = calcRandomHole(30, 10)
  end ]]

  getReady = display.newImageRect("Assets/getready.png", 200, 60)
  getReady.x = display.contentCenterX
  getReady.y = yReady
  getReady.alpha = 0

  gameOver = display.newImageRect("Assets/gameover.png", 200, 60)
  gameOver.x = display.contentCenterX
  gameOver.y = 0
  gameOver.alpha = 0

  board = display.newGroup()
  local img = display.newImageRect(board, "Assets/board.png", 240, 140)

  scoreTitle = display.newText(board, score, 80, -18, "Assets/troika.otf", 21)
  scoreTitle:setFillColor(0.75, 0, 0)
  bestTitle = display.newText(board, bestScore, 80, 24, "Assets/troika.otf", 21)
  bestTitle:setFillColor(0.75, 0, 0)

  silver = display.newImageRect(board, "Assets/silver.png", 44, 44)
  silver.x = -64
  silver.y = 4

  gold = display.newImageRect("Assets/gold.png", 44, 44)
  gold.x = -164
  gold.y = 4

  board.x = display.contentCenterX
  board.y = 0
  board.alpha = 0  
end

-- Start application point
loadSounds()
setupImages()
setupBird()
setupExplosion()
setupLand()
initGame()
loadBestScore()
gameLoopTimer = timer.performWithDelay(gameSpeed, gameLoop, 0)
-- debug text line
--local loadingText = display.newText( "Debug info", display.contentCenterX, display.contentCenterY, nil, 20)

-- appodeal listener
local function adListener(event)
  if (event.phase == "init") then -- Successful initialization
    -- maybe set a flag that you can see in all scenes to know that initialization is complete
  elseif (event.phase == "failed") then -- The ad failed to load
    print(event.type)
    print(event.isError)
    print(event.response)
  end
end

display.setStatusBar(display.HiddenStatusBar)
