class Grid
  attr_accessor :grid, :moves, :state, :rank

  def initialize(new_grid, player1_info, player2_info)
    self.grid = Marshal.load(Marshal.dump(new_grid))
    self.moves = []
    self.state = ''
    self.rank = -1

    @players = [player1_info, player2_info]
    self.grid[player1_info[1][0]][player1_info[1][1]] = player1_info[0]
    self.grid[player2_info[1][0]][player2_info[1][1]] = player2_info[0]
  end

  # Get player info - [index, [x, y]]
  def player_info(player)
    @players[player]
  end

  # Finds who's move it is
  def current_player
    @players[0][0] < @players[1][0] ? 0 : 1
  end

  # Changes current players info
  def current_player_set(array)
    @players[current_player] = array
  end

  # Finds current players index
  def current_index
    @players[current_player][0]
  end

  # Finds current players x
  def current_x
    @players[current_player][1][0]
  end

  # Finds current players y
  def current_y
    @players[current_player][1][1]
  end

  # Determines best next move for computer
  def best_way
    if self.state == 'max'
      way = moves.max{ |a, b| a.rank <=> b.rank }
    elsif self.state == 'min'
      way = moves.min{ |a, b| a.rank <=> b.rank }
    end
  end

  # Sets state based on previous state
  def set_state(prev_state)
    if prev_state == 'max'
      self.state = 'min'
    elsif prev_state == 'min'
      self.state = 'max'
    end
  end

  # Sets rank based on current state
  def set_rank
    ranks = self.moves.collect{ |x| x.rank }
    if self.state == 'max'
      self.rank = ranks.max
    elsif self.state == 'min'
      self.rank = ranks.min
    end
  end

  # Finds all possible moves from current move in specific grid
  def self.find_valid_movement(grid, x, y)
    valid_coordinates = [
      [-2,-1],[-1,-2],[ 1,-2],[ 2,-1],
      [-2, 1],[-1, 2],[ 1, 2],[ 2, 1]
    ]
    move_to = []

    valid_coordinates.each do |array|
      x_coordinate = array[0] + x
      y_coordinate = array[1] + y
      next if outside_area?(x_coordinate, y_coordinate)
      move_to << [x_coordinate, y_coordinate] if grid[x_coordinate][y_coordinate] == 0
    end

    move_to
  end

  # Helper method to check coords
  def self.outside_area?(x, y)
    x < 0 || y < 0 || x > 3 || y > 3
  end
end