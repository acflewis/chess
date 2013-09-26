class Board
  attr_accessor :grid, :turn

  def initialize
    @grid = Array.new(8) { Array.new(8) {} }
    @turn = 1
    [:black, :white].each do |color|
      other_pieces = [Rook, Knight, Bishop, King, Queen, Bishop, Knight, Rook]
      case color
      when :white
        pawn_row = 1
        other_row = 0
      when :black
        pawn_row = 6
        other_row = 7
      end

      8.times do |col|
        @grid[pawn_row][col] = Pawn.new(color, [pawn_row, col] )
        @grid[other_row][col] = other_pieces[col].new(color, [other_row, col] )
      end



    end

  end

  def is_check?(color)
    k_row, k_col = find_king(color)
    opp_pieces = find_pieces(color==:black ? :white : :black)
    #for each opponent piece, ask if it has a possible move that can take the king
    opp_pieces.each do |piece|
      poss_moves_piece = piece.moves(self)
      poss_moves_piece.each do |move|
        return true if move == [k_row, k_col]
      end
     end
     false
  end

  def find_pieces(color)
    opp_pieces = []
    @grid.each_with_index do |row|
      row.each_with_index do |square|
        opp_pieces << square if !square.nil? && square.color == color
      end
    end
    opp_pieces
  end

  def find_king(color)
    @grid.each_with_index do |row, index_row|
      row.each_with_index do |square, index_col|
        return [index_row, index_col] if square.is_a?(King) && square.color == color
      end
    end
  end

  def is_check_mate?(color)
    #Ask if color is in check
    return false if !is_check?(color)
    #If it is, iterate through all pieces. If no pieces have valid moves, check_mate? = true
    our_pieces = find_pieces(color)
    our_pieces.each do |piece|
      return false if !piece.valid_moves(self).empty?
    end
    true
  end

  def to_s
    board_string = ""

    count = 0
    board_string << "    "
    8.times do
      board_string << count.to_s
      board_string << "   "
      count += 1
    end

    board_string << "\n"
    count = 0
    @grid.each do |row|
      board_string << count.to_s
      row.each do |col|
        #Print status of tile at pos row, col
        board_string << "   "
        if col.class == NilClass
          board_string << "-"
        else
          board_string << col.sym.encode('utf-8')
        end
      end
      board_string << "\n"
      count += 1
    end
    board_string
  end

  def dup_board
    new_board = Board.new
    new_board.grid = Array.new
    @grid.each { |row| new_board.grid.push(row.dup) }
    return new_board
    #Marshal.load(Marshal.dump(self))
  end

  def make_move(input, color)
    from_row, from_column, to_row, to_column = input
    piece = @grid[from_row][from_column]
    valids = piece.valid_moves(self)

    if piece.nil?
      return false
    end
    if piece.color != color
      return false
    end

    if  !piece.is_a?(Pawn) && valids.include?([to_row, to_column])
      update_board(piece, from_row, from_column, to_row, to_column)
      return true
    end

    if piece.is_a?(Pawn)
      valid_xys, en_pass = valids.map(&:first), valids.map(&:last)

      if valid_xys.include?([to_row, to_column])

        if en_pass[valid_xys.index([to_row, to_column])]
          update_en_passant(piece, from_row, from_column, to_row, to_column)
          return true
        else
          update_board(piece, from_row, from_column, to_row, to_column)
          #Check for pawn promotion
          if (piece.color == :white && piece.pos[0] == 7) || (piece.color == :black && piece.pos[0] == 0)
            puts "The pawn gets promoted! Choose a promotion (Queen, Bishop, Knight, Rook)."
            type = gets.chomp
            @grid[piece.pos[0]][piece.pos[1]] = case type
            when "Queen" then Queen.new(color, piece.pos)
            when "Rook" then Rook.new(color, piece.pos)
            when "Bishop" then Bishop.new(color, piece.pos)
            when "Knight" then Knight.new(color, piece.pos)
            end
          end
          return true
        end
      end
    end
    false
  end

  def update_en_passant(piece, from_row, from_column, to_row, to_column)
    @grid[from_row][from_column] = nil
    @grid[to_row][to_column]= piece
    @grid[from_row][to_column] = nil #Delete pawn in passing
    piece.pos = [to_row, to_column]
    piece.no_times_moved += 1
    piece.last_to_move = @turn
    @turn += 1
  end

  def update_board(piece, from_row, from_column, to_row, to_column)
    @grid[from_row][from_column] = nil
    @grid[to_row][to_column]= piece
    piece.pos = [to_row, to_column]
    piece.last_to_move = @turn
    piece.no_times_moved += 1
    @turn += 1
  end

  def make_castling_move(side, color)
    #black king [7,3]
    #white king [0,3]
    case color
    when :black then king = @grid[7][3]
      case side
      when :king
        rook = @grid[7][0]
        between_squares = [[7,2], [7,1]]
        #rook_end_pos = [7,2]
      when :queen
        rook = @grid[7][7]
        between_squares = [[7,4], [7,5], [7,6]]
        #rook_end_pos = [7,5]
      end
    when :white then king = @grid[0][3]
      case side
      when :king
        rook = @grid[0][0]
        between_squares = [[0,2], [0,1]]
        #rook_end_pos = [0,2]
      when :queen
        rook = @grid[0][7]
        between_squares = [[0,4], [0,5], [0,6]]
        #rook_end_pos = [0,5]
      end
    end
    rook_end_pos = between_squares[-2]

    return nil if !(king.is_a?(King) && rook.is_a?(Rook) )
    #Check neither have moved
    return nil if king.no_times_moved != 0 || rook.no_times_moved != 0
    #Check no pieces between them
    between_squares.each do |square|
      return nil if !@grid[square[0]][square[1]].nil?
    end
    #Check king is not in check
    return nil if is_check?(color)
    #Check the king does not pass through a square that is under enemy attack, and whether king would end up in check
    between_squares.each { |square| return nil if !king.valid_move?(square, self) }

    king_move = [king.pos[0], king.pos[1], between_squares.last[0], between_squares.last[1]]
    rook_move = [rook.pos[0], rook.pos[1], rook_end_pos[0], rook_end_pos[1]]
    update_board(king, *king_move)
    update_board(rook, *rook_move)
    true
  end

end
