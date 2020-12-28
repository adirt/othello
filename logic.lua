function flip(t)
  local score = 0
  local fixedX, fromX, toX, stepX = t.fixedX, t.fromX, t.toX, t.stepX or 1
  local fixedY, fromY, toY, stepY = t.fixedY, t.fromY, t.toY, t.stepY or 1
  if fromX and fromY then
    -- diagonal flip
    local x, y = fromX, fromY
    while true do
      board[x][y] = currentPlayer
      score = score + 1
      if x == toX then break end
      x, y = x + stepX, y + stepY
    end
  elseif fromX then
    -- horizontal flip
    for x = fromX, toX, stepX do
      board[x][fixedY] = currentPlayer
      score = score + 1
    end
  else
    -- vertical flip
    for y = fromY, toY, stepY do
      board[fixedX][y] = currentPlayer
      score = score + 1
    end
  end
  return score
end


function move(x, y, justCheck)
  local score = 0

  -- check disks right
  if board[x+1] and board[x+1][y] == otherPlayer then
    for nextX = x + 2, cellsInRow do
      if not board[nextX][y] then break end
      if board[nextX][y] == currentPlayer then
        if justCheck then return true end
        score = score + flip{ fromX = x + 1, toX = nextX - 1, fixedY = y }
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
        score = score + flip{ fromX = x - 1, toX = prevX + 1, stepX = -1, fixedY = y }
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
        score = score + flip{ fromY = y + 1, toY = nextY - 1, fixedX = x }
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
        score = score + flip{ fromY = y - 1, toY = prevY + 1, stepY = -1, fixedX = x }
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
        score = score + flip{ fromX = x + 1, toX = nextX - 1, fromY = y + 1 }
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
        score = score + flip{ fromX = x - 1, toX = prevX + 1, stepX = -1, fromY = y + 1 }
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
        score = score + flip{ fromX = x + 1, toX = nextX - 1, fromY = y - 1, stepY = -1 }
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
        score = score + flip{ fromX = x - 1, toX = prevX + 1, stepX = -1, fromY = y - 1, stepY = -1 }
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


function legalMovesAvailable()
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


return { move = move, legalMovesAvailable = legalMovesAvailable }
