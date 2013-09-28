module SteppingPiece

  def moves(board)
    row = self.pos[0]
    col = self.pos[1]
    possible_moves = []
    move_dirs.each do |(dx, dy)|
      new_row = row + dx
      new_col = col + dy
      if on_board?(new_row, new_col) && board.grid[new_row][new_col].nil?
           possible_moves << [new_row, new_col]
      elsif on_board?(new_row, new_col) && board.grid[new_row][new_col].color != self.color
         possible_moves << [new_row, new_col]
      end
    end
    possible_moves
 end

end
