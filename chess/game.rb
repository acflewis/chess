require './pieces.rb'
require './player.rb'
require './board.rb'
#require './pgn_parser.rb'
require 'yaml'
class Game
  #include PgnParser
  attr_accessor :type_of_game
  
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
        
    if d == "n"
      @type_of_game = :play
      puts "If you would like to quit the game, enter 'q' on a turn. If you would like to save a game, enter 's' on a turn."
      play_game_loop
    elsif d == "l"
      @type_of_game = :play
      puts "If you would like to quit the game, enter 'q' on a turn. If you would like to save a game, enter 's' on a turn."
      reload
      #reload game
    elsif d == "w"
      @type_of_game = :watch
      puts "Either download the PGN file of the game you would like to watch (from e.g. chessgames.com), or choose one of the files listed below."
      puts Dir.entries("./PGN_files")
      #Load example.pgn
      filename = load_famous_game
      puts "To reveal next turn, press enter. To quit, press q."
      watch_game_loop("./PGN_files/#{filename}")
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
        elsif input == "O-O"
          #King side castling
          good_move = @board.make_castling_move(:king, @current_player.color)
          if !good_move
            puts "That wasn't a valid move! Try again."
          end
        elsif input == "O-O-O"
          #Queen side castling
          good_move = @board.make_castling_move(:queen, @current_player.color)
          if !good_move
            puts "That wasn't a valid move! Try again."
          end
        else
          move = input.split(" ").map(&:to_i)
          good_move = @board.make_move(move, @current_player.color, @type_of_game)
          if !good_move
            puts "That wasn't a valid move! Try again."
          end
        end
      end
      @current_player  = (@current_player == @player2 ? @player1 : @player2)
    end
    p game_over(@current_player.color)
  end
  
  def watch_game_loop(filename)
    
    puts ""
    parse_header(filename)  
    row_from, col_from, row_to, col_to, castling, promotion, piece_type, check, capture, result = parse_file(filename)      
    
    piece_type.each_with_index do |piece_moved, index|
      
      if @board.turn % 2 == 1 
        puts "Turn number #{(@board.turn + 1)/2}, #{@current_player.color} to move" 
      else
        puts "#{@current_player.color} to move"
      end
      puts @board.to_s
      if gets.chomp == "q"
          puts "Goodbye!"
          return
      end
      if castling[index] == ["O-O-O"] 
        @board.make_castling_move(:queen, @current_player.color)
      elsif castling[index] == ["O-O"]
        @board.make_castling_move(:king, @current_player.color)
      else
        row_from_n, col_from_n, row_to_n, col_to_n = fill_in_input(row_from[index], col_from[index], row_to[index], col_to[index], piece_type[index])
        @board.make_move([row_from_n, col_from_n, row_to_n, col_to_n], @current_player.color, @type_of_game)
        if promotion[index] != nil
          p @board.grid[row_to_n][col_to_n]
          piece = @board.grid[row_to_n][col_to_n]
          @board.promote_pawn(@current_player.color, piece, promotion[index])
        end
      end
      
      @current_player  = (@current_player == @player2 ? @player1 : @player2)
      if capture[index] == true
        puts "Piece captured"
      end
      if check[index] == :check
        puts "#{@current_player.color} is in check"
      end
      if check[index] == :mate
        puts "#{@current_player.color} is in check-mate"
      end
    end
    puts @board.to_s
    #p game_over(@current_player == @player2 ? @player1 : @player2)
    puts "Result is #{result}"
  end
  
  def parse_header(filename)
    s = File.readlines(filename)
    all_moves = []
    info = []
    s.each do |line|
      line = line.chomp
      if line.include?("White ")
        x = line.split("\"")
        info << x[1] 
      end
      if line.include?("Black ")
        x = line.split("\"")
        info << x[1]
      end 
      if line.include?("EventDate ")
        x = line.split("\"")
        info << x[1]
      end
    end
    puts "#{info[1]} v #{info[2]}, #{info[0]}."
  end
  
  def fill_in_input(row_from, col_from, row_to, col_to, piece_type)
    piece_type_hash = {"P" => Pawn, "Q" => Queen, "R" => Rook, "K" => King, "B" => Bishop, "N" => Knight }
    #row_from, col_from, row_to, col_to = *input
    #Find row_from and col_from
    #Which piece of type_piece could have moved to this square?
    all_pieces = @board.find_pieces(@current_player.color)
    possibles = []
    
    all_pieces.each do |piece|    
      piece_t = piece_type_hash[piece_type]
      next if piece.is_a?(piece_t) == false
     
      if piece_t == Pawn
        valids = piece.valid_moves(@board)
        valid_xys, en_pass = valids.map(&:first), valids.map(&:last)
        possibles << [valid_xys, piece]
        #Need to keep track of en-passent
      else
        possibles << [piece.valid_moves(@board), piece]
      end
    end
    # p [row_to, col_to]
    # puts "heelo"
    #Filter possible moves based on 
    keep = []
    possibles.each do |possible|
      to_pos, piece_m = possible[0], possible[1]
      # p to_pos
      if to_pos.include?([row_to, col_to])
        keep << piece_m
      end
      keep
    end
    
    if row_from.nil? && col_from.nil? #Should also be that keep.length == 1
      row_from_n = keep[0].pos[0] #Fill in row
      col_from_n = keep[0].pos[1] #Fill in col
    else
      
      keep.each do |piece|
        #if row_from.nil?
        if row_from.nil?
          if piece.pos[1] == col_from
            col_from_n = col_from
            row_from_n = piece.pos[0]
            break
          end
        elsif col_from.nil?
          if piece.pos[0] == row_from
            col_from_n = piece.pos[1]
            row_from_n = row_from
            break
          end   
        else
          row_from_n = row_from
          col_from_n = col_from     
        end    
      end
    end
    [row_from_n, col_from_n, row_to, col_to] 
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
  
  def load_famous_game
    puts "Enter filename of game to watch (pgn format):"
    gets.chomp
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
  
  def parse_file(filename)

    s = File.readlines(filename)
    all_moves = []
    s.each do |line|
      next if line.include?("[")
      all_moves << line.chomp
    end
    moves = all_moves.join(" ").strip.split(".").join(" ").split(" ")
    result = moves.pop
    
    turns = []
    moves.each_with_index do |move, index|
      turns << move if index % 3 != 0
    end
    turns
    

    #Our board has white on rows 0 and 1, black on rows 6 and 7, cols numbered 0--7. ALgebriac notation
    row_hash = Hash.new
    nums = ["8", "7", "6", "5", "4", "3", "2", "1"]
    #nums = ["1", "2", "3", "4", "5", "6", "7", "8"]
    8.times do |i|
      row_hash[nums[i]] = i
    end
    alph = ("a".."h").to_a
    col_hash = Hash.new
    8.times do |i|
      col_hash[alph[i]] = i
    end

    to_row = Array.new(turns.length)
    to_col = Array.new(turns.length)
    promotion = Array.new(turns.length)
    check = Array.new(turns.length)
    capture = Array.new(turns.length)
    piece_type = Array.new(turns.length)
    left = Array.new(turns.length)
    from_col = Array.new(turns.length)
    from_row = Array.new(turns.length)
    castling = Array.new(turns.length)
    error = Array.new(turns.length)

    turns.each_with_index do |turn, index|
      #Check for king-side castling
      if turn == "O-O"
        castling[index] = [turn]
        error[index] = false
      #Check for queen-side castling
      elsif turn == "O-O-O"
        castling[index] = [turn]
        error[index] = false
      else
        turn_arr = turn.split("")
        #Check for pawn promotion =Q, =R, =B, =N
        if turn_arr.last == ("Q" || "R" || "B" || "N")
          promotion[index] = turn_arr.pop
          turn_arr.pop
        end
        #Store indicators for check and check mate
        if turn_arr.last == "#"
          check[index] = :mate
          turn_arr.pop
        end
        if turn_arr.last == "+"
          check[index] = :check
          turn_arr.pop
        end
        #Store to position
        to_row[index] = row_hash[turn_arr.pop]
        to_col[index] = col_hash[turn_arr.pop]
        #Store indicator for whether it is a capture
        if turn_arr[-1] == "x"
          turn_arr.pop
          capture[index] = true
        end
        if turn_arr[-1] == "Q" || turn_arr[-1] == "R" || turn_arr[-1] == "B" || turn_arr[-1] == "N" || turn_arr[-1] == "K"
          piece_type[index] = turn_arr.pop
        elsif turn_arr.empty?
          piece_type[index] = "P"
        end

        if turn_arr.length == 1 && alph.include?(turn_arr[0])
          #It is disambiguating a pawn move
          piece_type[index] = "P"
          from_col[index] = col_hash[turn_arr.pop]
        end
  
        if alph.include?(turn_arr.last)
          #It is col index
          from_col[index] = col_hash[turn_arr.pop]
        end
        if nums.to_a.include?(turn_arr.last)
          #It is row index
          from_row[index] = row_hash[turn_arr.pop]
        end
        if turn_arr[-1] == "Q" || turn_arr[-1] == "R" || turn_arr[-1] == "B" || turn_arr[-1] == "N" || turn_arr[-1] == "K"
          piece_type[index] = turn_arr.pop
        end
        #Anything else is an error
        left[index] = turn_arr
        error[index] = !turn_arr.empty?
      end
  
    end

    if error.include?(true)
      puts "Problem processing file."
    else
      [from_row, from_col, to_row, to_col, castling, promotion, piece_type, check, capture, result]
    end
  end

end

player1 = Player.new
player2 = Player.new
g = Game.new(player1, player2)
g.play_game
