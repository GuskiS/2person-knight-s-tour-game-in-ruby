module OS
  def OS.windows?
    (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  end

  def OS.mac?
   (/darwin/ =~ RUBY_PLATFORM) != nil
  end

  def OS.unix?
    !OS.windows?
  end

  def OS.linux?
    OS.unix? and not OS.mac?
  end
end

require 'pry'
if OS.windows?
  require 'win32/sound'
  include Win32
end

require_relative 'game'
require_relative 'gui'
require_relative 'gametree'
require_relative 'grid'

game = Game.new
game.play_game