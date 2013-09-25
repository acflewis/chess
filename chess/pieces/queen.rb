class Queen < Piece
  include SlidingPiece

  def initialize(color, pos)
    super(color, pos)
    @sym = "\u2655" if color == :white
    @sym = "\u265B" if color == :black
  end

  def move_dirs
    [[0, 1], [0, -1], [-1, 0], [1, 0], [1, 1], [1, -1], [-1, 1], [-1, -1]]
  end

end