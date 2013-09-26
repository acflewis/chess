require './pieces.rb'
require './player.rb'
require './board.rb'
require 'yaml'
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
    puts "Welcome to Yu and Annas' chess game!"

    d = @current_player.get_first_instruction
        puts "If you would like to quit the game, enter 'q' on a turn. If you would like to save a game, enter 's' on a turn."
    if d == "n"
      play_game_loop
    elsif d == "l"
      reload
      #reload game
    else
      puts "Invalid choice, exiting."
      return
    end

  end

  def play_game_loop

    until game_over(@current_player.color) != false
      puts @board.to_s
      good_move = false
      until good_move
        input = @current_player.get_move
        if input == "s"
          save
          puts "File saved. Play again soon!"
          return
        elsif input == "q"
          puts "Goodbye!"
          return
        elsif input == "0-0"
          #King side castling
          good_move = @board.make_castling_move(:king, @current_player.color)
          if !good_move
            puts "That wasn't a valid move! Try again."
          end
        elsif input == "0-0-0"
          #Queen side castling
          good_move = @board.make_castling_move(:queen, @current_player.color)
          if !good_move
            puts "That wasn't a valid move! Try again."
          end
        else
          move = input.split(" ").map(&:to_i)
          good_move = @board.make_move(move, @current_player.color)
          if !good_move
            puts "That wasn't a valid move! Try again."
          end
        end
      end
      @current_player  = (@current_player == @player2 ? @player1 : @player2)
    end
    p game_over(@current_player.color)
  end

  def save
    puts "Enter filename to save at:"
    filename = gets.chomp

    File.write(filename, YAML.dump(self))
  end

  def reload
    puts "Enter filename to reload:"
    filename = gets.chomp

    YAML.load_file(filename).play_game_loop
  end

  def game_over(color)
    return "White wins!" if @board.is_check_mate?(:black)
    return "Black wins!" if @board.is_check_mate?(:white)
    return "Draw: Stalemate" if stale_mate(color)
    false
  end

  def stale_mate(color)
    #Color has no legal move, and is not in check
    pieces = @board.find_pieces(color)
    pieces.each do |piece|
      return false if !piece.valid_moves(@board).empty?
    end
    return false if @board.is_check?(color)
    true
  end

end

player1 = Player.new
player2 = Player.new
g = Game.new(player1, player2)
g.play_game