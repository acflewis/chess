class Bishop < Piece
  include SlidingPiece

  def initialize(color, pos)
    super(color, pos)
    @sym = "\u2657" if color == :white
    @sym = "\u265D" if color == :black
  end

  def move_dirs
    [[1, 1], [1, -1], [-1, 1], [-1, -1]]
  end

end