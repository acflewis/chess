class King < Piece
  include SteppingPiece

  def initialize(color, pos)
    super(color, pos)
    @sym = "\u2654" if color == :white
    @sym = "\u265A" if color == :black
  end

  def move_dirs
    [[0, 1], [0, -1], [-1, 0], [1, 0], [1, 1], [1, -1], [-1, 1], [-1, -1]]
  end

end