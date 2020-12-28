-----------------------------
-- Othello by Adir Tzuberi --
--    First Love2D Game    --
--        19/12/2020       --
-----------------------------

local localGame = require 'local'
local remoteGame = require 'remote'
local enet = assert(require 'enet')

game = localGame


function love.load()
  screenWidth  = love.graphics.getWidth()
  screenHeight = love.graphics.getHeight()
  cellsInRow   = 8
  cellSize     = screenHeight / cellsInRow

  player1 = 'black'
  player2 = 'white'
  tie     = 'tie'

  local font = 'font/DejaVuSans.ttf'
  local fontSize = math.floor(screenHeight / 10)
  love.graphics.setNewFont(font, fontSize)

  engToHeb = {
    turn      = 'ךרות',
    score     = 'דוקינ',
    won       = '!תחצינ',
    lost      = 'תדספה',
    [player1] = 'רוחש',
    [player2] = 'ןבל',
    [tie]     = '!וקית'
  }

  boardPad     = (screenWidth - screenHeight) / 2
  rectanglePad = screenHeight / 540
  circlePad    = screenHeight / 216
  textPad = {
    [player1] = 0,
    [player2] = boardPad + screenHeight
  }

  colors = {
    black = { 0,  0, 0 },
    white = { 1,  1, 1 },
    green = { 0, .5, 0 }
  }

  function reset()
    currentPlayer = player1
    otherPlayer = player2
    board = {}
    for x = 1, cellsInRow do
      board[x] = {}
    end
    board[cellsInRow/2+1][cellsInRow / 2] = player1
    board[cellsInRow / 2][cellsInRow/2+1] = player1
    board[cellsInRow / 2][cellsInRow / 2] = player2
    board[cellsInRow/2+1][cellsInRow/2+1] = player2
    scoreBoard = { [player1] = 2, [player2] = 2 }
    newlyFlipped = {}
    winner = nil
    loser = nil
  end

  reset()
  game.load()
end


function love.draw()
  game.draw()
end


function love.mousereleased(x, y, button, istouch, presses)
  game.mouseReleased(x, y, button, presses)
end

function log(x, y)
  for y = 1, cellsInRow do
    for _ = 1, cellsInRow * 2 + 1 do io.write('-') end
    print()
    for x = 1, cellsInRow do
      io.write('|')
      if not board[x][y] then io.write(' ')
      elseif board[x][y] == player1 then io.write('b')
      elseif board[x][y] == player2 then io.write('w') end
    end
    print('|')
  end
  for _ = 1, cellsInRow * 2 + 1 do io.write('-') end
  print()
  print(currentPlayer.." played: x = "..x.."; y = "..y)
end
