class Board

  attr_accessor :board

  def initialize
    @board = Array.new(9)
  end
    
end

class Cell

  attr_accessor :value, :notes

  def initialize(value)
    @value = value
    @notes = Array.new
  end

  def to_s
    "(value: #{@value}, notes: #{@notes})"
  end

end

class Sudoku

  def print_message
    puts "Sudoku Solver!"
  end

  def create_board
    @@board = Board.new().board
    @@log_file = File.open("log.txt", "w")
  end

  def get_starting_numbers
    board = @@board
    row = 0
    puts "Enter starting numbers. Seperate entries by periods."
    puts "Enter 0 for unknown values."
    until row == 9 do
      print "Row #{row+1}: "
      row_numbers = gets.chomp!
      row_array = row_numbers.split(".")
      cell_array = []
      row_array.each do |x|
        cell = Cell.new(x)
        cell_array << cell
      end
      board[row] = cell_array
      row += 1
    end
    @@board = board
  end

  def solve
    @@log_file.puts "-----Scanning empty spaces-----"
    scan_empty_spaces
    @@log_file.puts "-----Beginning note reduction-----"
    while reduce_notes do
      @@log_file.puts "-----Reducing notes again-----"
    end
    i = 0
    j = 0
    @@board.each do |row|
      i += 1
      if i == 4 || i == 7
        puts "============="
      end
      row.each do |cell|
        j += 1
        print cell.value
        if j == 3 || j == 6
          print "||"
        end
        @@log_file.print cell.value
      end
      j = 0
      puts ""
      @@log_file.puts ""
    end
  end

  def scan_empty_spaces
    board = @@board
    board.each_with_index do |row, rIndex|
      row.each_with_index do |space, sIndex|
        if space.value == "0"
          @@log_file.puts "Looking at space [#{rIndex+1},#{sIndex+1}]"
          scan_row_add_notes space.notes, rIndex
          scan_col_add_notes space.notes, sIndex
          scan_square_add_notes space.notes, rIndex, sIndex

          space.notes.uniq!.delete("0")
          space.notes = ["1", "2", "3", "4", "5", "6", "7", "8", "9"] - space.notes

          @@log_file.puts "Space [#{rIndex+1},#{sIndex+1}] has notes #{space.notes}"

          if space.notes.length == 1
            @@log_file.puts "Space [#{rIndex+1},#{sIndex+1}] has one note"
            space.value = space.notes.first
            @@log_file.puts "Space [#{rIndex+1},#{sIndex+1}] has value #{space.value}"
            space.notes.clear
            @@log_file.puts "Deleting notes around [#{rIndex+1},#{sIndex+1}]"
            scan_row_del_notes space.value, rIndex
            scan_col_del_notes space.value, sIndex
            scan_square_del_notes space.value, rIndex, sIndex
          end
        end
      end
    end
    @@board = board
  end

  def reduce_notes
    board = @@board
    flag = false
    board.each_with_index do |row, rIndex|
      row.each_with_index do |space, sIndex|
        if space.value == "0"
          @@log_file.puts "Looking at space [#{rIndex+1},#{sIndex+1}]"
          @@log_file.puts "Space [#{rIndex+1},#{sIndex+1}] has notes #{space.notes}"
          if space.notes.length == 1
            @@log_file.puts "Space [#{rIndex+1},#{sIndex+1}] has one note"
            space.value = space.notes.first
            @@log_file.puts "Space [#{rIndex+1},#{sIndex+1}] has value #{space.value}"
            space.notes.clear
            @@log_file.puts "Deleting notes around [#{rIndex+1},#{sIndex+1}]"
            scan_row_del_notes space.value, rIndex
            scan_col_del_notes space.value, sIndex
            scan_square_del_notes space.value, rIndex, sIndex
          else
            # scan row, col, square for uniqueness of a note
            @@log_file.puts "Space [#{rIndex+1},#{sIndex+1}] has #{space.notes.length} notes"
            space.notes.each do |x|
              @@log_file.puts "Looking at note #{x}"
              uniq_flag1 = scan_row_uniq_notes x, rIndex, sIndex
              @@log_file.puts "Row unique? #{!uniq_flag1}"
              uniq_flag2 = scan_col_uniq_notes x, rIndex, sIndex
              @@log_file.puts "Col unique? #{!uniq_flag2}"
              uniq_flag3 = scan_square_uniq_notes x, rIndex, sIndex
              @@log_file.puts "Square unique? #{!uniq_flag3}"

              if !(uniq_flag1 && uniq_flag2 && uniq_flag3)
                @@log_file.puts "Note #{x} is unique for space [#{rIndex+1},#{sIndex+1}]"
                flag = true
                space.value = x
                space.notes.clear
                @@log_file.puts "Deleting notes around [#{rIndex+1},#{sIndex+1}]"
                scan_row_del_notes x, rIndex
                scan_col_del_notes x, sIndex
                scan_square_del_notes x, rIndex, sIndex
              end
            end
          end
        end
      end
    end
    @@board = board
    return flag
  end

  def scan_row_add_notes (notes, index)
    @@board[index].each do |space|
      notes << space.value
    end
  end

  def scan_row_del_notes (value, index)
    @@board[index].each do |space|
      space.notes.delete(value)
    end
  end

  def scan_row_uniq_notes (value, row, col)
    @@board[row].each_with_index do |space, index|
      if space.notes.include?(value) && index != col
        return true
      end
    end
    return false
  end

  def scan_col_add_notes (notes, index)
    @@board.each do |row|
      notes << row[index].value
    end
  end

  def scan_col_del_notes (value, index)
    @@board.each do |row|
      row[index].notes.delete(value)
    end
  end

  def scan_col_uniq_notes (value, row, col)
    @@board.each_with_index do |r, index|
      if r[col].notes.include?(value) && index != row
        return true
      end
    end
    return false
  end

  def scan_square_add_notes (notes, row, col)
    square_x = row/3 + 1
    square_y = col/3 + 1

    square_row = [square_x*3-2, square_x*3-1, square_x*3]
    square_col = [square_y*3-2, square_y*3-1, square_y*3]

    square_row.each do |x|
      square_col.each do |y|
        notes << @@board[x-1][y-1].value
      end
    end
  end

  def scan_square_del_notes (value, row, col)
    square_x = row/3 + 1
    square_y = col/3 + 1

    square_row = [square_x*3-2, square_x*3-1, square_x*3]
    square_col = [square_y*3-2, square_y*3-1, square_y*3]

    square_row.each do |x|
      square_col.each do |y|
        @@board[x-1][y-1].notes.delete(value)
      end
    end
  end

  def scan_square_uniq_notes (value, row, col) # 7, 0, 1
    square_x = row/3 + 1
    square_y = col/3 + 1

    square_row = [square_x*3-3, square_x*3-2, square_x*3-1]
    square_col = [square_y*3-3, square_y*3-2, square_y*3-1]

    square_row.each do |x|
      square_col.each do |y|
        if @@board[x][y].notes.include?(value) && (x != row || y != col)
          return true
        end
      end
    end
    return false
  end


end

=begin
  Completing the puzzle by only using notes is successful!

  Medium level puzzles can now be completed entirely.

  Hard level puzzles do not provide enough information to solve with only notes.

  Future work: Research more methods of solving Sudoku. Have code
  make initial guesses based on notes and running them through to
  completion.
=end