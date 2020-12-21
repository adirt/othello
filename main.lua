-----------------------------
-- Othello by Adir Tzuberi --
--    First Love2D Game    --
--        19/12/2020       --
-----------------------------

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
  -- textPad = {
  --   [player1] = .05 * screenHeight,
  --   [player2] = boardPad + 1.05 * screenHeight
  -- }
  textPad = {
    [player1] = 0,
    [player2] = boardPad + screenHeight
  }

  colors = {
    black     = { 0,  0, 0 },
    white     = { 1,  1, 1 },
    green     = { 0, .5, 0 }
  }

  function reset()
    currentPlayer = player1
    otherPlayer   = player2
    board = {}
    for x = 1, cellsInRow do
      board[x] = {}
    end
    board[cellsInRow/2+1][cellsInRow / 2] = player1
    board[cellsInRow / 2][cellsInRow/2+1] = player1
    board[cellsInRow / 2][cellsInRow / 2] = player2
    board[cellsInRow/2+1][cellsInRow/2+1] = player2
    scoreBoard = { [player1] = 2, [player2] = 2 }
    winner = nil
    loser = nil
  end

  reset()
end


function love.draw()
  -- draw background
  love.graphics.setColor(unpack(colors.white))
  love.graphics.rectangle('fill',
      screenWidth - boardPad,
      0,
      boardPad,
      screenHeight)

  -- draw board
  love.graphics.setColor(unpack(colors.green))
  for x = 1, cellsInRow do
    for y = 1, cellsInRow do
      love.graphics.rectangle('fill',
          boardPad + (x - 1) * cellSize + rectanglePad,
          (y - 1) * cellSize + rectanglePad,
          cellSize - 2 * rectanglePad,
          cellSize - 2 * rectanglePad)
    end
  end

  -- draw disks
  for x = 1, cellsInRow do
    for y = 1, cellsInRow do
      if board[x][y] then
        love.graphics.setColor(unpack(colors[board[x][y]]))
        love.graphics.circle('fill',
                             boardPad + (x - 0.5) * cellSize,
                             (y - 0.5) * cellSize,
                             cellSize / 2 - circlePad)
      end
    end
  end

  -- draw game text
  local function printText(text, color, row, pad)
    love.graphics.printf({ color, text }, pad, row * cellSize, boardPad, 'center')
  end

  love.graphics.setColor(unpack(colors.white))
  printText(engToHeb[currentPlayer], colors[otherPlayer], 2, textPad[currentPlayer])
  printText(tostring(scoreBoard[currentPlayer]), colors[otherPlayer], 5, textPad[currentPlayer])
  printText(engToHeb[otherPlayer], colors[currentPlayer], 2, textPad[otherPlayer])
  printText(tostring(scoreBoard[otherPlayer]), colors[currentPlayer], 5, textPad[otherPlayer])
  if winner then
    printText(engToHeb.won, colors[loser], 3, textPad[winner])
    printText(engToHeb.lost, colors[winner], 3, textPad[loser])
  else
    printText(engToHeb.turn, colors[otherPlayer], 3, textPad[currentPlayer])
  end
end


function love.mousereleased(x, y, button, istouch, presses)
  if button ~= 1 then return end  -- only left clicks are registered
  if winner then
    if presses == 2 then  -- double-left-click once game is over resets the game
      reset()
    end
    return
  end

  -- map (x, y) click coordinates to (x, y) squares on the board
  x = math.floor((x - boardPad) / cellSize) + 1
  y = math.floor(y / cellSize) + 1
  if not board[x] or board[x][y] then return end  -- click outside the board or on a disk does nothing

  function move(x, y, justCheck)
    local score = 0

    -- check disks right
    if board[x+1] and board[x+1][y] == otherPlayer then
      for nextX = x + 2, cellsInRow do
        if not board[nextX][y] then break end
        if board[nextX][y] == currentPlayer then
          if justCheck then return true end
          for xToFlip = x + 1, nextX - 1 do
            board[xToFlip][y] = currentPlayer
            score = score + 1
          end
          break
        end
      end
    end

    -- check disks left
    if board[x-1] and board[x-1][y] == otherPlayer then
      for prevX = x - 2, 1, -1 do
        if not board[prevX][y] then break end
        if board[prevX][y] == currentPlayer then
          if justCheck then return true end
          for xToFlip = x - 1, prevX + 1, -1 do
            board[xToFlip][y] = currentPlayer
            score = score + 1
          end
          break
        end
      end
    end

    -- check disks down
    if board[x] and board[x][y+1] == otherPlayer then
      for nextY = y + 2, cellsInRow do
        if not board[x][nextY] then break end
        if board[x][nextY] == currentPlayer then
          if justCheck then return true end
          for yToFlip = y + 1, nextY - 1 do
            board[x][yToFlip] = currentPlayer
            score = score + 1
          end
          break
        end
      end
    end

    -- check disks up
    if board[x] and board[x][y-1] == otherPlayer then
      for prevY = y - 2, 1, -1 do
        if not board[x][prevY] then break end
        if board[x][prevY] == currentPlayer then
          if justCheck then return true end
          for yToFlip = y - 1, prevY + 1, -1 do
            board[x][yToFlip] = currentPlayer
            score = score + 1
          end
          break
        end
      end
    end

    -- check disks down-right
    if board[x+1] and board[x+1][y+1] == otherPlayer then
      local nextX, nextY = x + 2, y + 2
      while board[nextX] and board[nextX][nextY] do
        if board[nextX][nextY] == currentPlayer then
          if justCheck then return true end
          local xToFlip, yToFlip = x + 1, y + 1
          while xToFlip < nextX do
            board[xToFlip][yToFlip] = currentPlayer
            score = score + 1
            xToFlip, yToFlip = xToFlip + 1, yToFlip + 1
          end
          break
        end
        nextX, nextY = nextX + 1, nextY + 1
      end
    end

    -- check disks down-left
    if board[x-1] and board[x-1][y+1] == otherPlayer then
      local prevX, nextY = x - 2, y + 2
      while board[prevX] and board[prevX][nextY] do
        if board[prevX][nextY] == currentPlayer then
          if justCheck then return true end
          local xToFlip, yToFlip = x - 1, y + 1
          while xToFlip > prevX do
            board[xToFlip][yToFlip] = currentPlayer
            score = score + 1
            xToFlip, yToFlip = xToFlip - 1, yToFlip + 1
          end
          break
        end
        prevX, nextY = prevX - 1, nextY + 1
      end
    end

    -- check disks up-right
    if board[x+1] and board[x+1][y-1] == otherPlayer then
      local nextX, prevY = x + 2, y - 2
      while board[nextX] and board[nextX][prevY] do
        if board[nextX][prevY] == currentPlayer then
          if justCheck then return true end
          local xToFlip, yToFlip = x + 1, y - 1
          while xToFlip < nextX do
            board[xToFlip][yToFlip] = currentPlayer
            score = score + 1
            xToFlip, yToFlip = xToFlip + 1, yToFlip - 1
          end
          break
        end
        nextX, prevY = nextX + 1, prevY - 1
      end
    end

    -- check disks up-left
    if board[x-1] and board[x-1][y-1] == otherPlayer then
      local prevX, prevY = x - 2, y - 2
      while board[prevX] and board[prevX][prevY] do
        if board[prevX][prevY] == currentPlayer then
          if justCheck then return true end
          local xToFlip, yToFlip = x - 1, y - 1
          while xToFlip > prevX do
            board[xToFlip][yToFlip] = currentPlayer
            score = score + 1
            xToFlip, yToFlip = xToFlip - 1, yToFlip - 1
          end
          break
        end
        prevX, prevY = prevX - 1, prevY - 1
      end
    end

    if score > 0 then
      board[x][y] = currentPlayer
      scoreBoard[currentPlayer] = scoreBoard[currentPlayer] + score + 1
      scoreBoard[otherPlayer] = scoreBoard[otherPlayer] - score
    end

    return score > 0
  end

  local function legalMovesAvailable()
    for x = 1, cellsInRow do
      for y = 1, cellsInRow do
        if not board[x][y] then
          local legalMove = move(x, y, true)
          if legalMove then return true end
        end
      end
    end
    return false
  end

  -- active player makes a move
  local flipped = move(x, y)
  log(x, y)
  if flipped then
    currentPlayer, otherPlayer = otherPlayer, currentPlayer    -- swap to end turn
    if not legalMovesAvailable() then
      print(currentPlayer.." can't move, back to "..otherPlayer)
      currentPlayer, otherPlayer = otherPlayer, currentPlayer  -- opponent can't move, back to active player
      if not legalMovesAvailable() then
        -- active player can't move either, game over
        if     scoreBoard[player1] > scoreBoard[player2] then winner, loser = player1, player2
        elseif scoreBoard[player2] > scoreBoard[player1] then winner, loser = player2, player1
        else   winner, loser = tie, tie end
        print("Game over, result: "..winner)
      end
    end
  end
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
