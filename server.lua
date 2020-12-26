function main()
  local board = initSomeBoard()
  -- boardStr = getBoardString(board)
  local boardEncoded = encodeBoard(board)
  -- boardEncoded = 2621697937018856448
  -- 00,10,01,00,01,10,00,10;00,10,01,00,01,10,00,10;00,10,01,00,01,10,00,10;00,10,01,00,00,00,00,00
  -- 64 bit integer, need two of these since our encoding requires 128 bits
  -- why are the 4 lowest bit-pairs zeros instead of 01,10,00,10?
  local boardDecoded = decodeBoard(boardEncoded)
  print(boardDecoded == board)
  -- board2 = getBoard(boardStr)
  -- print(board == board2)
end

function initSomeBoard()
  board = {}
  for i = 1, 8 do
    board[i] = {}
  end
  for i = 1, 8 do
    for j = 1, 8, 2 do
      board[i][j] = 'black'
    end
    for j = 2, 8, 2 do
      board[i][j] = 'white'
    end
    for j = 1, 8, 3 do
      board[i][j] = nil
    end
  end
  return board
end

function getBoardString(board)
  boardStr = ''
  for i = 1, 8 do
    for j = 1, 8 do
      if board[i][j] then
        char = board[i][j]:sub(1, 1)
        boardStr = boardStr..char
      else
        boardStr = boardStr..' '
      end
    end
  end
  return boardStr
end

function getBoard(boardStr)
  board = {}
  for i = 1, 8 do
    board[i] = {}
  end
  for i = 1, boardStr:len() do
    char = boardStr:sub(i, i)
    assert(char == 'b' or char == 'w' or char == ' ')
    x = (i - 1) % 8 + 1
    y = math.floor(i / 8)
    if char == 'b' then board[x][y] = 'black'
    elseif char == 'w' then board[x][y] = 'white' end
  end
  return board
end

function encodeBoard(board)
  local code = 0
  local boardCodes = {}
  local map = {
    black = 1,
    white = 2
  }
  for x = 1, 8 do
    assert(board[x])
    for y = 1, 8 do
      assert(not board[x][y] or board[x][y] == 'black' or board[x][y] == 'white')
      code = code << 2
      if board[x][y] then
        code = code | map[board[x][y]]
      end
    end
    if x % 2 == 0 then
      table.insert(boardCodes, code)
      code = 0
    end
  end
  return string.pack('i4i4i4i4', table.unpack(boardCodes))
end

function decodeBoard(boardEncoded)
  local boardDecoded = {}
  local boardCodes = table.pack(string.unpack('i4i4i4i4', boardEncoded))
  local code
  local mask
  local map = { 'black', 'white' }
  for x = 1, 8 do
    if x % 2 == 1 then
      code = boardCodes[math.ceil(x / 2)]
      mask = 3 << 30
    end
    boardDecoded[x] = {}
    for y = 1, 8 do
      boardDecoded[x][y] = map[code & mask]
      mask = mask >> 2
    end
  end
  return boardDecoded
end

main()