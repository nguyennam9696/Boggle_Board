TEST_BOARD = [['E', 'T', 'A', 'Q'], ['A', 'I', 'E', 'T'], ['R', 'L', 'T', 'N'], ['I', 'A', 'T', 'O']]
ENGLISH = File.readlines('words').map { |w| w.downcase.chomp }

class DiceGroup
  attr_reader :dice
  def initialize
    @dice = [
      'AAEEGN',
      'ELRTTY',
      'AOOTTW',
      'ABBJOO',
      'EHRTVW',
      'CIMOTU',
      'DISTTY',
      'EIOSST',
      'DELRVY',
      'ACHOPS',
      'HIMNQU',
      'EEINSU',
      'EEGHNW',
      'AFFKPS',
      'HLNNRZ',
      'DEILRX' ]
  end
  def roll
    this_die = @dice.sample
    @dice.delete(this_die)
    this_die[rand(0..5)]
  end
end

class Coordinate
  attr_accessor :x, :y
  def initialize(x, y)
    @x = x
    @y = y
  end

  def to_s
    "(#{x}, #{y})"
  end

  def same_as?(coord)
    (self.x - coord.x) == 0 && (self.y - coord.y) == 0
  end

  def adjacent?(coord)
    return false if self.same_as?(coord)
    (self.x - coord.x).abs <= 1 && (self.y - coord.y).abs <= 1
  end

  def adjacents
    all = [0, 1, 2, 3].permutation(2).map { |pair| Coordinate.new(pair[0], pair[1]) }
    (0..3).each { |i| all << Coordinate.new(i, i) }
    all.select! { |coord1| coord1.adjacent?(self) }
    # returns array of adjacent coordinates
  end

end

class BoggleBoard
  attr_reader :board, :points, :words
  def initialize
    @board = Array.new(4) { (0..3).map { '-' } }
    @points = 0
    @words = []
  end

  def test
    @board = TEST_BOARD
  end

  def shake!
    @points = 0
    @words = []
    dice = DiceGroup.new
    @board = Array.new(4) { (0..3).map { dice.roll } }
  end

  def to_s
    string = <<-BOARD
      +--------------+
      |  X  X  X  X  |
      |  X  X  X  X  |
      |  X  X  X  X  |
      |  X  X  X  X  |
      +--------------+
    BOARD
    board.each { |row|
      row.each { |let| string.sub!(/X/, let) }
    }
    string.gsub(/Q /, 'Qu')
  end

  def include?(word)
    word.upcase!.gsub!(/QU/, 'Q')
    start_points = get_coords(word.slice!(0))
    path_found = false
    start_points.each { |start|
      temp_array = Marshal.load(Marshal.dump(board))  #clones the nested array
      temp_array[start.y][start.x] = ' '              #removes the letter so it doesn't get used twice
      path_found ||= find_path(start, word, temp_array)
    }
    path_found
  end

  def find_path(coord, wordpath, board)
    return true if wordpath == ""
    adjacents = coord.adjacents
    path_found = false
    adjacents.each { |new_coord|
      if check_this_coord(new_coord, board) == wordpath[0]
        board[new_coord.y][new_coord.x] = ' '                #removes the letter so it doesn't get used twice
        temp_array = Marshal.load(Marshal.dump(board))       #clones the nested array
        path_found ||= find_path(new_coord, wordpath.slice(1, wordpath.length), temp_array)
      end
    }
    path_found
  end

  def get_coords(let)
    coords = []
    board.each_with_index { |row, ind_y|
      row.each_with_index { |letter, ind_x|
        coords << Coordinate.new(ind_x, ind_y) if letter == let
      }
    }
    coords
  end

  def check_this_coord(coord, board)
    board[coord.y][coord.x]
  end

  def enter(word)
    word_path = word.clone
    return 'must be at least 3 letters' if word.length < 3
    return 'not an english word' if !ENGLISH.include?(word.downcase) && !ENGLISH.include?(word.downcase.chomp('s'))
    return 'not found on board' if !self.include?(word_path)
    return 'word already entered' if @words.include?(word.downcase)
    @words << word.downcase
    @points += [1, 1, 2, 3, 5][word.length - 3] || 11
  end

  def enter!(word)
    word_path = word.clone
    return 'must be at least 3 letters' if word.length < 3
    return 'not found on board' if !self.include?(word_path)
    return 'word already entered' if @words.include?(word.downcase)
    @words << word.downcase
    @points += [1, 1, 2, 3, 5][word.length - 3] || 11
  end
end


# Driver test code

game = BoggleBoard.new
dice = DiceGroup.new
puts game
puts "SHAKING!"
game.test
puts game


coord1 = Coordinate.new(0,2)
coord2 = Coordinate.new(0,1)
%w{aietno earil rlto quate ttie ttontq eliato alien}.each { |word| p game.include?(word) }
%w{lro eitr non werthterh qeatq}.each { |word| p game.include?(word) == false }

