require 'yaml'
require_relative "limerick"

class GameData
  attr_reader :players, :limericks, :group_size, :group_name,
              :player_name, :gamefile_path, :current_line, :mute

  def initialize(player_name, gamefile_path, mute=false)
    @gamefile_path = gamefile_path

    gamefile_data = YAML.load_file(@gamefile_path)
    @player_name = player_name
    @group_name = gamefile_data[:group_name]
    @group_size = gamefile_data[:group_size]
    @players = gamefile_data[:players]
    @limericks = gamefile_data[:limericks]
    @current_line = gamefile_data[:current_line]
    @mute = mute

    @game_data = { group_name: @group_name,
                   group_size: @group_size,
                   players: @players,
                   limericks: @limericks,
                   current_line: @current_line }
  end

  def write_to_gamefile
    formatted_data = YAML.dump(@game_data)
    File.write(@gamefile_path, formatted_data)
  end

  def cycle_limericks
    @game_data[:current_line] += 1
    @limericks.unshift(@limericks.pop)

    write_to_gamefile
  end

  def all_player_lines_submitted?
    refresh
    @limericks.all? { |limerick| limerick.size == @current_line }
  end

  def current_line_not_submitted?
    current_limerick.size < @current_line
  end

  def current_limerick
    index = @players.index(@player_name)

    @limericks[index]
  end

  def all_limericks_complete?
    @limericks.all?(&:complete?)
  end

  def toggle_mute
    @mute = !@mute
  end

  def add_player
    refresh
    @players << @player_name

    write_to_gamefile
  end

  def add_line(line)
    refresh
    current_limerick << line

    write_to_gamefile
  end

  def refresh
    initialize(@player_name, @gamefile_path, @mute)
  end

  # For in app debugging
  def to_s
    "<strong>Group Name:</strong> #{@group_name}<br><strong>Group"\
    "Size:</strong> #{@group_size}<br><strong>Players:</strong> #{@players}"\
    "<br><strong>Limericks:</strong> #{@limericks}<br>"\
    "<strong>File Path:</strong>#{@gamefile_path}<br>"\
    "<strong>Current Line:</strong>#{@current_line}"
  end
end
