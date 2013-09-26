class Player
  attr_accessor :color

  def initialize
    @color = ""
  end

  def get_first_instruction
    puts "Would you like to start a new game (n) or load a saved game (l)?"
    gets.chomp
  end

  def get_move
    puts "It is #{@color}'s turn, please enter your move: row_from col_from row_to col_to"
    gets.chomp
  end

end