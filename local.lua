logic = require 'logic'


function load()
end


function draw()
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
        if newlyFlipped[x] and newlyFlipped[x][y] then
          love.graphics.setColor(unpack(colors[newlyFlipped[x][y]]))
          love.graphics.circle('line',
              boardPad + (x - 0.5) * cellSize,
              (y - 0.5) * cellSize,
              cellSize / 2 - circlePad)
        end
      end
    end
  end

  -- draw game text
  local function printText(t)
    local text, color, side, row = assert(t.text), assert(t.color), assert(t.side), assert(t.row)
    love.graphics.printf({ colors[color], text }, textPad[side], row * cellSize, boardPad, 'center')
  end

  love.graphics.setColor(unpack(colors.white))
  printText { text = engToHeb[currentPlayer], color = otherPlayer, side = currentPlayer, row = 2 }
  printText { text = scoreBoard[currentPlayer], color = otherPlayer, side = currentPlayer, row = 5 }
  printText { text = engToHeb[otherPlayer], color = currentPlayer, side = otherPlayer, row = 2 }
  printText { text = scoreBoard[otherPlayer], color = currentPlayer, side = otherPlayer, row = 5 }
  if winner then
    printText { text = engToHeb.won, color = loser, side = winner, row = 3 }
    printText { text = engToHeb.lost, color = winner, side = loser, row = 3 }
  else
    printText { text = engToHeb.turn, color = otherPlayer, side = currentPlayer, row = 3 }
  end
end


function mouseReleased(x, y, button, presses)
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

  -- active player makes a move
  newlyFlipped = {}
  local flipped = logic.move(x, y)
  log(x, y)
  if flipped then
    currentPlayer, otherPlayer = otherPlayer, currentPlayer    -- swap to end turn
    if not logic.legalMovesAvailable() then
      print(currentPlayer.." can't move, back to "..otherPlayer)
      currentPlayer, otherPlayer = otherPlayer, currentPlayer  -- opponent can't move, back to active player
      if not logic.legalMovesAvailable() then
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


return { load = load, draw = draw, mouseReleased = mouseReleased }
