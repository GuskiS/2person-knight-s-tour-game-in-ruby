class Game
  attr_accessor :board, :tree, :human, :current_move, :file_name

  def initialize
    reset_game
  end

  def play_game
    # Shows GUI
    @gui ||= GUI.new(self)
    @gui.show_gui
    generate_tree if self.tree == []

    @gui.print_current_location
    @gui.print_grid(board.grid)

    make_move
  end

  # Sets default values
  def reset_game
    self.tree = []
    self.human = 0
    self.current_move = nil
    self.file_name = 'default.txt'
    self.board = nil
  end

  # Generates tree
  def generate_tree
    make_array
    self.tree = GameTree.new.generate(board.grid, board.player_info(0), board.player_info(1))
  end

  # Get array from file and makes it 2D
  def make_array
    startup = read_file.split.map(&:to_i)
    make_2d_array(startup)
  end

  # Makes next move, recursively
  def make_move
    x = []
    y = []
    value = []
    puts ''

    if(board.current_player == self.human)
      # Player move
      array = make_2d_coords(get_player_move)
      x = array[0]
      y = array[1]
      value = board.current_index+2
      board.grid[x][y] = value
      value = [value, [x, y]]
    else
      # Computer move
      current = self.current_move.nil? ? self.tree : self.current_move

      next_move = current.best_way
      board.grid = next_move.grid
      value = next_move.player_info(board.current_player)

      @gui.print_move_computer(value[1])
    end

    # Update game
    current = self.current_move.nil? ? self.tree.moves : self.current_move.moves
    index = current.collect{ |i| i.grid }.index(board.grid)
    self.current_move = current[index]

    # Game condition check
    if self.current_move.moves.empty?
      play_again = @gui.print_finish(board.current_player)
      make_move if play_again == 1
    else
      board.current_player_set(value)
      @gui.print_grid(board.grid)
      make_move
    end
  end

  private

  # Reads from file
  def read_file
    file = open(self.file_name)
    startup = file.read
    file.close
    startup
  end

  # Converts 1D array to 2D
  def make_2d_array(array)
    grid = Array.new(4) { Array.new(4) }
    players = [[0, 0], [0, 0]]
    count = 0

    grid.each_index do |i|
      grid[i].each_index do |j|
        grid[i][j] = array[count]
        # Finds starting location
        if array[count] > 0
          temp = array[count].odd? ? 0 : 1
          players[temp] = [array[count], [i, j]] if players[temp][0] < array[count]
        end
        count = count + 1
      end
    end

    # Creates game grid
    self.board = Grid.new(grid, players[0], players[1])
  end

  # Converts 1D coordinate to 2D
  def make_2d_coords(move)
    array = []
    array[0] = move/4
    array[1] = move%4
    array
  end

  # Checks for if move is invalid
  def invalid_move?(move)
    array = make_2d_coords(move)
    x = array[0]
    y = array[1]

    !Grid.find_valid_movement(board.grid, board.current_x, board.current_y).include?([x, y])
  end

  # Player input for next move
  def get_player_move
    input = -1111
    while input > 16 || input < 0 || invalid_move?(input)
      @gui.print_wrong_move unless input == -1111
      print "Your next move: ".pink
      input = gets.chomp
      input.upcase!
      input = input.ord - 65
    end
    input
  end
end
