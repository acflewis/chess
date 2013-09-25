class Knight < Piece
  include SteppingPiece

  def initialize(color, pos)
    super(color, pos)
    @sym = "\u2658" if color == :white
    @sym = "\u265E" if color == :black
  end

  def move_dirs
    [[1, 2], [1, -2], [-1, 2], [-1, -2], [2, 1], [2, -1], [-2, 1], [-2, -1]]
  end

end