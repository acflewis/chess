class Rook < Piece
  include SlidingPiece

  def initialize(color, pos)
    super(color, pos)
    @sym = "\u2656" if color == :white
    @sym = "\u265C" if color == :black
  end

  def move_dirs
    [[0, 1], [0, -1], [-1, 0], [1, 0]]
  end
end
