module SlidingPiece

  def moves(board)
    row, col = pos
    possible_moves = []
    move_dirs.each do |(dx, dy)|
      no_squares = 1
      while true
        new_row = row + dx * no_squares
        new_col = col + dy * no_squares
        if on_board?(new_row, new_col) && board.grid[new_row][new_col].nil?
             possible_moves << [new_row, new_col]
        elsif on_board?(new_row, new_col) && board.grid[new_row][new_col].color != self.color
           possible_moves << [new_row, new_col]
           break
        else
           break
        end
        no_squares += 1
      end
    end
    possible_moves
  end

end