class Board
  attr_accessor :grid

  def initialize
    @grid = Array.new(8) { Array.new(8) {} }

    [:black, :white].each do |color|
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
        @grid[other_row] = [Rook, Knight, Bishop, King, Queen, Bishop, Knight, Rook].map do |klass|
          klass.new(color, [other_row, col] )
        end
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

  def make_move(input, color, player)
    from_row, from_column, to_row, to_column = input
    piece = @grid[from_row][from_column]
    if piece.nil? == false && piece.color == color && piece.valid_moves(self).include?([to_row, to_column])
      @grid[from_row][from_column] = nil
      @grid[to_row][to_column]= piece
      piece.pos = [to_row, to_column]
      return true
    else
      return false
    end
  end

end
