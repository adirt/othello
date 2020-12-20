-----------------------------
-- Othello by Adir Tzuberi --
--    First Love2D Game    --
--        19/12/2020       --
-----------------------------

function love.load()
  cellsInRow = 8
  cellSize = love.graphics.getHeight() / cellsInRow
  player1 = 'black'
  player2 = 'white'
  tie = 'tie'
  font = 'font/DejaVuSans.ttf'
  fontSize = math.floor(love.graphics.getHeight() / 15)
  love.graphics.setNewFont(font, fontSize)

  engToHeb = { turn = 'רות', score = 'דוקינ', won = '!חצינ' }
  engToHeb[player1] = 'רוחש'
  engToHeb[player2] = 'ןבל'
  engToHeb[tie] = '!וקית'

  function reset()
    currentPlayer = player1
    otherPlayer = player2
    board = {}
    for x = 1, cellsInRow do
      board[x] = {}
    end
    board[cellsInRow /2+1][cellsInRow /2]   = player1
    board[cellsInRow /2][cellsInRow /2+1]   = player1
    board[cellsInRow /2][cellsInRow /2]     = player2
    board[cellsInRow /2+1][cellsInRow /2+1] = player2
    scoreBoard = {}
    scoreBoard[player1] = 2
    scoreBoard[player2] = 2
  end

  reset()
end

function love.draw()
  local rectanglePad = 2
  local circlePad = 5
  local player1Color = { 0, 0, 0 }  -- black
  local player2Color = { 1, 1, 1 }  -- white
  local boardColor = { 0, .5, 0 }   -- dark green

  for x = 1, cellsInRow do
    for y = 1, cellsInRow do
      love.graphics.setColor(unpack(boardColor))
      love.graphics.rectangle('fill',
                              (x - 1) * cellSize + rectanglePad,
                              (y - 1) * cellSize + rectanglePad,
                              cellSize - 2 * rectanglePad,
                              cellSize - 2 * rectanglePad)
      if board[x][y] then
        if board[x][y] == player1 then
          love.graphics.setColor(unpack(player1Color))
        elseif board[x][y] == player2 then
          love.graphics.setColor(unpack(player2Color))
        end
        love.graphics.circle('fill',
                             (x - 0.5) * cellSize,
                             (y - 0.5) * cellSize,
                             cellSize / 2 - circlePad)
      end
    end
  end

  local function printText(text, row)
    love.graphics.print(text, love.graphics.getHeight() + 20, row * cellSize)
  end

  if winner then
    if winner ~= tie then
      printText(string.format("%s %s", engToHeb.won, engToHeb[winner]), 1)
    else
      printText(engToHeb.tie, 1)
    end
  else
    printText(string.format("%s %s", engToHeb[currentPlayer], engToHeb.turn), 1)
  end
  printText(engToHeb.score, 3)
  printText(string.format("%d :%s", scoreBoard[player1], engToHeb[player1]), 4)
  printText(string.format("%d :%s", scoreBoard[player2], engToHeb[player2]), 5)
end

function love.mousereleased(x, y, button, istouch, presses)
  local leftClick = 1
  if button ~= leftClick then return end
  if winner then return end
  x = math.floor(x / cellSize) + 1
  y = math.floor(y / cellSize) + 1
  if board[x] and board[x][y] then return end

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
        if not board[x][y] then  -- no continue statement :(
          local legalMove = move(x, y, true)
          if legalMove then return true end
        end
      end
    end
    return false
  end

  local flipped = move(x, y)
  log(x, y)
  if flipped then
    currentPlayer, otherPlayer = otherPlayer, currentPlayer  -- swap to end turn
    if not legalMovesAvailable() then
      print(currentPlayer.." can't move, back to "..otherPlayer)
      currentPlayer, otherPlayer = otherPlayer, currentPlayer  -- opponent can't move, back to active player
    end
    if not legalMovesAvailable() then
      if     scoreBoard[player1] > scoreBoard[player2] then winner = player1
      elseif scoreBoard[player2] > scoreBoard[player1] then winner = player2
      else   winner = tie end
      print("Game over, result: "..winner)
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