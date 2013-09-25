require './pieces.rb'
require './player.rb'
require './board.rb'
class Game

  def initialize(player1, player2)
    @board = Board.new
    @player1 = player1
    @player2 = player2
    @player1.color = :white
    @player2.color = :black
    @current_player = player1
  end

  def play_game

    until @board.is_check_mate?(:black) || @board.is_check_mate?(:white)
      puts @board.to_s
      good_move = false
      until good_move
        input = @current_player.get_move
        good_move = @board.make_move(input, @current_player.color, @current_player)
        if !good_move
          puts "That wasn't a valid move! Try again."
        end
      end
      @current_player  = (@current_player == @player2 ? @player1 : @player2)
    end
    @current_player  = (@current_player == @player2 ? @player1 : @player2)
    puts "#{@current_player.color} wins!"
  end


end

player1 = Player.new
player2 = Player.new
g = Game.new(player1, player2)
g.play_game