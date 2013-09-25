class Piece
  attr_accessor :color, :sym, :pos

  def initialize(color, pos)
    @color = color
    @pos = pos
  end

  def on_board?(row, col)
    [row, col].all? { |coord| coord.between?(0, 7) }
  end

  def valid_moves(board)
    possible_moves = moves(board)
    valid_moves = []
    possible_moves.each do |poss_move|
      valid_moves << poss_move if valid_move?(poss_move, board)
    end
    valid_moves
  end

  def valid_move?(pos_move, board)
    #deep dup the board
    trial_board = board.dup_board
    #make the move on the dup
    trial_board.grid[@pos[0]][@pos[1]] = nil
    trial_board.grid[pos_move[0]][pos_move[1]] = self
    #Then ask if the move leaves player in check
    !trial_board.is_check?(self.color)
  end

end

module SlidingPiece

  def moves(board)
    row, col = pos
    # row = self.pos[0]
    # col = self.pos[1]
     [].tap do |possible_moves|
       move_dirs.each do |(dx, dy)|
        no_squares = 1
         while true

          new_row = row + dx * no_squares

          new_col = col + dy * no_squares
          if on_board?(new_row, new_col) && board.grid[new_row][new_col] == nil
               possible_moves << [new_row, new_col]
          elsif on_board?(new_row, new_col) && board.grid[new_row][new_col].color != self.color
             possible_moves << [new_row, new_col]
             break
          else
             break
          end
          no_squares += 1
         end

      end
    end
  end



end

module SteppingPiece

  def moves(board)
    row = self.pos[0]
    col = self.pos[1]
     [].tap do |possible_moves|
       move_dirs.each do |(dx, dy)|
          new_row = row + dx
          new_col = col + dy
          if on_board?(new_row, new_col) && board.grid[new_row][new_col] == nil
               possible_moves << [new_row, new_col]
          elsif on_board?(new_row, new_col) && board.grid[new_row][new_col].color != self.color
             possible_moves << [new_row, new_col]
          end
        end
      end
    end

end

class Rook < Piece
  include SlidingPiece

  def initialize(color, pos)
    super(color, pos)
    @sym = "\u2656" if color == "white"
    @sym = "\u265C" if color == "black"
  end

  def move_dirs
    [[0, 1], [0, -1], [-1, 0], [1, 0]]
  end
end

class Bishop < Piece
  include SlidingPiece

  def initialize(color, pos)
    super(color, pos)
    @sym = "\u2657" if color == "white"
    @sym = "\u265D" if color == "black"
  end

  def move_dirs
    [[1, 1], [1, -1], [-1, 1], [-1, -1]]
  end

end

class Queen < Piece
  include SlidingPiece

  def initialize(color, pos)
    super(color, pos)
    @sym = "\u2655" if color == "white"
    @sym = "\u265B" if color == "black"
  end

  def move_dirs
    [[0, 1], [0, -1], [-1, 0], [1, 0], [1, 1], [1, -1], [-1, 1], [-1, -1]]
  end

end

class King < Piece
  include SteppingPiece

  def initialize(color, pos)
    super(color, pos)
    @sym = "\u2654" if color == "white"
    @sym = "\u265A" if color == "black"
  end

  def move_dirs
    [[0, 1], [0, -1], [-1, 0], [1, 0], [1, 1], [1, -1], [-1, 1], [-1, -1]]
  end

end

class Knight < Piece
  include SteppingPiece

  def initialize(color, pos)
    super(color, pos)
    @sym = "\u2658" if color == "white"
    @sym = "\u265E" if color == "black"
  end

  def move_dirs
    [[1, 2], [1, -2], [-1, 2], [-1, -2], [2, 1], [2, -1], [-2, 1], [-2, -1]]
  end

end

class Pawn < Piece

  def initialize(color, pos)
    super(color, pos)
    @sym = "\u2659" if color == "white"
    @sym = "\u265F" if color == "black"
  end

  def moves(board)
    row = self.pos[0]
    col = self.pos[1]
    possible_moves = []
    if color == "white"
      #Double move start
      possible_moves << [row+2, col] if row == 1 && board.grid[row+1][col] == nil && board.grid[row+2][col] == nil
      #Single move
      possible_moves << [row+1, col] if board.grid[row+1][col] == nil
      #Taking move
      possible_moves << [row+1, col+1] if board.grid[row+1][col+1] != nil && board.grid[row+1][col+1].color == "black"
      possible_moves << [row+1, col-1] if board.grid[row+1][col-1] != nil && board.grid[row+1][col-1].color == "black"
    end

    if color == "black"

      #Double move start
      possible_moves << [row-2, col] if row == 6 && board.grid[row-1][col] == nil && board.grid[row-2][col] == nil
      #Single move
      possible_moves << [row-1, col] if board.grid[row-1][col] == nil
      #Taking move
      possible_moves << [row-1, col+1] if board.grid[row-1][col+1] != nil && board.grid[row-1][col+1].color == "white"
      possible_moves << [row-1, col-1] if board.grid[row-1][col-1] != nil && board.grid[row-1][col-1].color == "white"
    end
    possible_moves
  end




end



class Board
  attr_accessor :grid

  def initialize
    @grid = Array.new(8) { Array.new(8) {} }

    count = -1
    @grid[0] = [Rook, Knight, Bishop, King, Queen, Bishop, Knight, Rook].map do |klass|
       count += 1
       klass.new("white", [0, count] )
       end

     count = -1
     @grid[7] = [Rook, Knight, Bishop, King, Queen, Bishop, Knight, Rook].map do |klass|
        count += 1
        klass.new("black", [7, count] )
        end

    count = -1
    pawn_array = [Pawn] * 8
    @grid[6] =  pawn_array.map do |klass|
             count += 1
       klass.new("black", [6, count] )
       end

   count = -1
   pawn_array = [Pawn] * 8
   @grid[1] =  pawn_array.map do |klass|
      count += 1
      klass.new("white", [1, count] )
      end

     # 1,3 to 3,3 white pawn
  #    6,3 to 4,3 black pawn
  #    0,4 to 4,0 white queen
  #    7,1 to 5,2 black knight
  #    0,2 to 3,5 white bishop
  #    7,6 to 5,5 black knight
  #    4,0 to 6,2 white queen

     # @grid[1][3] = nil
     # @grid[3][3]= Pawn.new('white', [3,3])
     # @grid[6][3] = nil
     # @grid[4][3]= Pawn.new('black', [4,3])
     # @grid[0][4] = nil
     # @grid[4][0]= Queen.new('white', [4,0])
     # @grid[7][1] = nil
     # @grid[5][2]= Knight.new('black', [5,2])
     # @grid[0][2] = nil
     # @grid[3][5]= Bishop.new('white', [3,5])
     # @grid[7][6] = nil
     # @grid[5][5]= Knight.new('black', [5,5])
     # @grid[4][0] = nil
     # @grid[6][2]= Queen.new('white', [6,2])






  end


  def is_check?(color)
    k_row, k_col = find_king(color)
    opp_pieces = find_pieces(color=="black" ? "white" : "black")
    #for each opponent piece, ask if it has a possible move that can take the king
    opp_pieces.each do |piece|
      poss_moves_piece = piece.moves(self)
      poss_moves_piece.each do |move|
        return true if move == [k_row, k_col]
      end
     end
     return false
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
        return [index_row, index_col] if square.class == King && square.color == color
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

  def print_board
    count = 0
    print "    "
    8.times do
      print count
      print "   "
      count += 1
    end

    puts "\n"
    count = 0
    @grid.each do |row|
      print count
      row.each do |col|
        #Print status of tile at pos row, col
        print "   "
        if col.class == NilClass
          print "-"
        else
          print col.sym.encode('utf-8')
        end
      end
      puts "\n"
      count += 1
    end
  end

  def dup_board
    Marshal.load(Marshal.dump(self))
  end

  def make_move(input, color, player)
    from_row, from_column, to_row, to_column = input
    piece = @grid[from_row][from_column]
    if piece.valid_moves(self).include?([to_row, to_column])

      @grid[from_row][from_column] = nil
      @grid[to_row][to_column]= piece #Pawn.new(color, [to_row,to_column])
      piece.pos = [to_row, to_column]
      return true
    else
      return false
    end
  end

end

class Player
  attr_accessor :color

  def initialize(color)
    @color = color
  end

  def get_move
    puts "Please enter your move: row_from col_from row_to col_to"
    gets.chomp.split(" ").map(&:to_i)
  end

end

class Game
  b = Board.new
  white = Player.new("white")
  black = Player.new("black")
  player = white
  color = "white"
  until b.is_check_mate?("black") || b.is_check_mate?("white")
    b.print_board
    good_move = false
    until good_move == true
    input = player.get_move
    good_move = b.make_move(input, color, player)
    if good_move == false
      puts "That wasn't a valid move! Try again."
    end
    end
    color = (color == "black" ? "white" : "black")
    player  = (player == black ? white : black)
  end
  player  = (player == black ? white : black)
  puts "#{player.color} wins!"


end

#
