class GUI < Game
  attr_accessor :file

  def initialize(game)
    @game = game
    self.file = nil
  end

  def show_gui
    clear_screen
    puts 'By Edvards Lazdāns, LDI, 121RDB742'.green
    puts 'Press 1 to start, else exit.'.green
    input = gets.chomp

    if input == '1'
      clear_screen
      puts 'Game started!'.yellow
      start_game
    else
      exit_screen
    end
  end

  def print_grid(grid)
    letters = get_letter_array
    letter = 0

    grid.each do |i|
      val = ''
      i.each do |j|
        val = val + (j == 0 ? format_colors(letters[letter]) : format_colors(j))
        letter = letter+1
      end
      puts val
    end
    ''
  end

  def print_wrong_move
    puts 'That is wrong move, please select again from grid!'.red
  end

  def print_move_computer(array)
    number = @game.board.grid[array[0]][array[1]]
    print "Computers next move: ".pink + "#{get_letter_array[get_flat_array.index(number)]}\n"
  end

  def print_finish(player)
    puts ''
    if player == @game.human
      if OS.windows?
        Sound.beep(600, 600)
        sleep 1/2
        Sound.beep(600, 300)
        sleep 1/2
        Sound.beep(600, 600)
      end
      puts 'Congratulations, you won!'.green
    else
      Sound.beep(600, 300) if OS.windows?
      puts 'Sadly, computer won!'.red
    end

    puts 'Would you like to play again? (y/n)'.pink
    input = gets.chomp.upcase
    if input == 'Y'
      @game.reset_game
      @game.play_game
      return 1
    else
      exit_screen
    end
  end

  def print_current_location
    puts "You are playing as player #{get_right_color(@game.human+1, (@game.human+1).to_s)}" + print_player_location
  end

  private

  def start_game
    puts "Grid file name: #{get_right_color(@game.human+1, @game.file_name)}"
    print_current_location
    print_grid(@game.board.grid) unless @game.board.nil?

    puts ''

    puts '1)'.red + ' Select grid files'.yellow
    puts '2)'.red + ' Select player order'.yellow
    puts '3)'.red + ' Print tree'.yellow
    puts '4)'.red + ' Play the game!'.yellow

    input = gets.chomp
    if input == '1'
      select_grid
    elsif input == '2'
      select_players
    elsif input == '3'
      select_tree
    else
      clear_screen
    end 
  end

  def select_grid
    clear_screen
    puts '1)'
    @game.file_name = 'default.txt'
    @game.make_array
    print_grid(@game.board.grid)

    puts '2)'
    @game.file_name = 'default_2.txt'
    @game.make_array
    print_grid(@game.board.grid)

    puts '3)'
    @game.file_name = 'default_3.txt'
    @game.make_array
    print_grid(@game.board.grid)

    input = gets.chomp
    if input == '3'
      @game.file_name = 'default_3.txt'
    elsif input == '2'
      @game.file_name = 'default_2.txt'
    else
      @game.file_name = 'default.txt'
    end

    clear_screen
    @game.make_array
    start_game
  end

  def select_players
    puts 'Press 1 to play as first or 2 to play as second!'.pink
    @game.human = gets.chomp == '1' ? 0 : 1

    clear_screen
    start_game
  end

  def select_tree
    if @game.tree == [] || @game.file_name != @gui_file_name
      puts "Tree isn't generated or isn't up-to-date, would you like to generate it? (y/n)".pink
      input = gets.chomp.upcase
      if input == 'Y'
        @game.generate_tree
        @gui_file_name = @game.file_name
      else
        clear_screen
        start_game
        return
      end
    end

    manage_tree(@game.tree, 0)
    puts 'Would you like to write tree to the file? (y/n)'.pink
    input = gets.chomp.upcase
    if input == 'Y'
      self.file = open('output.txt', 'w')
      manage_tree(@game.tree, 1)
      self.file.close

      clear_screen
      puts 'Tree successfully written to "output.txt" file!'.pink
    else
      clear_screen
    end
    start_game
  end

  def print_player_location
    if @game.board.nil?
      "!"
    else
      location = @game.board.player_info(@game.human)[0]
      ", your current position is #{get_right_color(location, location.to_s)}!"
    end
  end

  def manage_node(print_moves, type, space)
    letters = get_letter_array
    letter = 0
    little_grid = print_moves.grid.flatten

    p_state = ''
    print_moves.grid.each do |i|
      p_grid = ''
      p_state = ''
      i.each do |j|
        if type == 1
          p_grid = space + p_grid + (j == 0 ? letters[letter] : "#{j}").rjust(2, ' ').ljust(3, ' ')
        else
          p_grid = space + p_grid + (j == 0 ? format_colors(letters[letter], little_grid) : format_colors(j, little_grid))
        end
        p_state = space + p_state
        letter = letter+1
      end

      if type == 1
        self.file.write(p_grid + "\n")
      else
        puts p_grid
      end
    end

    if type == 1
      self.file.write(p_state + " #{print_moves.state*3} === #{print_moves.rank}\n")
    else
      puts (p_state + " #{print_moves.state*3} === #{print_moves.rank}")
    end
    return ''
  end

  def manage_tree(print_moves, type = 0, space = '')
    print_moves.moves.each do |i|
      manage_node(i, type, space)
      manage_tree(i, type, space+' ') unless i.moves.empty?
    end
    return ''
  end

  def format_colors(j, array = get_flat_array)
    if j.class == Fixnum
      last = array.max
      pre_last = last-1

      if j.odd?
        if j == last || j == pre_last
          "#{j}".rjust(2, ' ').ljust(3, ' ').red_back
        else
          "#{j}".rjust(2, ' ').ljust(3, ' ').red
        end
      else
        if j == last || j == pre_last
          "#{j}".rjust(2, ' ').ljust(3, ' ').green_back
        else
          "#{j}".rjust(2, ' ').ljust(3, ' ').green
        end
      end
    else
      j.rjust(2, ' ').ljust(3, ' ').yellow
    end
  end

  def get_right_color(value, string)
    if value.odd?
      string.red
    else
      string.green
    end
  end

  def get_letter_array
    @letters ||= ('A'..'P').to_a
  end

  def get_flat_array
    @game.board.grid.flatten
  end

  def clear_screen
    system 'clear' or system 'cls'
  end

  def exit_screen
    clear_screen
    puts 'Bye!'.yellow
    Kernel.exit
  end
end

class String
  # colorization
  def colorize(color_code)
    if OS.windows?
      "\e[#{color_code}m#{self}\e[0m"
    else
      self
    end
  end

  def colorize_back(color_code)
    "\e[#{color_code};47m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def pink
    colorize(35)
  end

  def red_back
    colorize_back(31)
  end

  def green_back
    colorize_back(32)
  end
end
