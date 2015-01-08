class GameTree < Game
  # Generates tree from given grid and locations, first state is max
  def generate(grid, player_1, player_2)
    grid = Grid.new(grid, player_1.dup, player_2.dup)
    grid.set_state('max')
    generate_moves(grid)
    grid
  end

  # Recursive function
  def generate_moves(grid_object)
    # Finds all possible moves based on current grid
    move_to = Grid.find_valid_movement(grid_object.grid, grid_object.current_x, grid_object.current_y)

    # Iterates through all possible next moves
    move_to.each_index do |i|
      # Determines where to put next move
      movement_index = grid_object.current_index+2
      player_1 = movement_index.odd? ? [movement_index, move_to[i]] : grid_object.player_info(0)
      player_2 = movement_index.odd? ? grid_object.player_info(1) : [movement_index, move_to[i]]

      # Creates new possible grid, adds it to moves array, sets state based on previous state, call function again,
      # when it comes back - sets it rank
      grid = Grid.new(grid_object.grid, player_1, player_2)
      grid_object.moves << grid
      grid.set_state(grid_object.state)
      generate_moves(grid)
      grid_object.set_rank
    end

    # When reached deepes level of tree, sets first rank based on state
    if move_to.empty?
      if grid_object.state == 'min'
        grid_object.rank = 1
      else grid_object.state == 'max'
        grid_object.rank = 0
      end
    end
  end
end