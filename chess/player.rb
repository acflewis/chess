class Player
  attr_accessor :color

  def initialize
    @color = ""
  end

  def get_move
    puts "It is #{@color}'s turn, please enter your move: row_from col_from row_to col_to"
    gets.chomp.split(" ").map(&:to_i)
  end

end