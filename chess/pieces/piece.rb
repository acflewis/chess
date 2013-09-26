class Piece
  attr_accessor :color, :sym, :pos, :no_times_moved, :last_to_move

  def initialize(color, pos)
    @color = color
    @pos = pos
    @no_times_moved = 0
    @last_to_move = nil
  end

  def on_board?(row, col)
    [row, col].all? { |coord| coord.between?(0, 7) }
  end

  def valid_moves(board)
    possible_moves = moves(board)
    valid_moves = []
    possible_moves.each do |poss_move|
      poss_move_xy = poss_move[0].is_a?(Array) ? poss_move[0] : poss_move
      valid_moves << poss_move if valid_move?(poss_move_xy, board)
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