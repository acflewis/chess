class Pawn < Piece

  def initialize(color, pos)
    super(color, pos)
    @sym = "\u2659" if color == :white
    @sym = "\u265F" if color == :black
  end

  def moves(board)
    row = self.pos[0]
    col = self.pos[1]
    possible_moves = []

    case @color
    when :white
      pawn_row = 1
      one_move_row = 2
      two_move_row = 3
      next_row = row+1
    when :black
      pawn_row = 6
      one_move_row = 5
      two_move_row = 4
      next_row = row-1
    end
    #Double move start
    possible_moves << [two_move_row, col] if row == pawn_row && board.grid[one_move_row][col].nil? && board.grid[two_move_row][col].nil?
    #Single move
    possible_moves << [one_move_row, col] if board.grid[one_move_row][col].nil?
    #Taking move
    possible_moves << [next_row, col+1] if !board.grid[next_row][col+1].nil? && board.grid[next_row][col+1].color == (@color == :black ? :white : :black)
    possible_moves << [next_row, col-1] if !board.grid[next_row][col-1].nil? && board.grid[next_row][col-1].color == (@color == :black ? :white : :black)
    possible_moves
  end

end
