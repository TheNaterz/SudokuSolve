require_relative 'sudoku_def'

class Main
  sudoku = Sudoku.new
  sudoku.print_message
  sudoku.create_board
  sudoku.get_starting_numbers
  sudoku.solve
  sudoku.solve
  sudoku.solve
end