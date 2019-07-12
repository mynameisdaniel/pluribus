Dir.glob('sample_game_*.log').each do |file|
# debug file
# Dir.glob('sample_hands.txt').each do |file|
  puts file

  File.open(file).each do |line|
    next unless line[0..4] == "STATE"
    def action_parser(street:, board:, players:, actions:)
      puts "\n\n"
      puts street.upcase
      puts board if board

      if @last_aggressor
        puts "#{@last_aggressor} was last aggressor"
      elsif street != 'preflop'
        puts "No aggressor"
      end

      @active_players = players.dup
      first_preflop_action = true if street == 'preflop'

      return if actions.nil?
      previous_action = street == 'preflop'
      @everyone_check_this_street = actions.all?{|a| a == 'c'} 
      @last_aggressor_checked = false
      while actions.size > 0
        @active_players.each do |player|
          # sb and bb are not the first to act preflop
          next if first_preflop_action && [players[0], player[1]].include?(player)
          case actions.shift

          when "f"
            puts "#{player} folds"
            players.delete(player)

          when "r"
            if previous_action
              puts "#{player} raises #{actions.shift}"
              previous_action = true
              @last_aggressor = player
            else
              puts "#{player} bets #{actions.shift}"
              previous_action = true
              if @last_aggressor && @last_aggressor != 'Pluribus' && player == 'Pluribus' && @last_aggressor_checked == false
                puts 'Real Pluribus donks!!'
              elsif @last_aggressor.nil? && player == 'Pluribus'
                puts 'Last street checked through - Pluribus bets!!'
              end
              @last_aggressor = player
            end

          when "c"
            if previous_action
              puts "#{player} calls"
            else
              puts "#{player} checks"
              if !@last_aggressor.nil? && @last_aggressor == player
                @last_aggressor_checked = true
              end
            end
          end
        end
        @active_players = players.dup
        first_action = false
      end
      if @everyone_check_this_street
        @last_aggressor = nil 
      end
    end

    puts "\n"
    puts "\n"

    line = line.gsub("\n", '')
    args = line.split(":")

    puts "Hand ##{args[1]}"

    players = args.last.split("|")
    @active_players = players.dup
    @last_aggressor = nil
    hands = args[3].split("|")
    board = hands.last.split("/")[1..-1]
    hands[-1] = hands.last.split("/").first if hands[-1].include?("/")

    puts "#{players[0]} -  #{hands[0]} - SB"
    puts "#{players[1]} - #{hands[1]} - BB"
    puts "#{players[2]} - #{hands[2]} - UTG"
    puts "#{players[3]} - #{hands[3]} - Highjack"
    puts "#{players[4]} - #{hands[4]} - Cutoff"
    puts "#{players[5]} - #{hands[5]} - Button"


    #preflop
    actions = args[2].split("/")
    preflop = actions[0]
    preflop_actions = preflop.scan(/\d+|[a-z]/)
    action_parser(street: "preflop", board: nil, players: @active_players, actions: preflop_actions)

    #flop
    if board[0]
      flop_actions = actions[1]
      flop_actions = flop_actions.scan(/\d+|[a-z]/) unless flop_actions.nil?
      action_parser(street: "flop", board: board[0], players: @active_players, actions: flop_actions)
    end

    #turn
    if board[1]
      turn_actions = actions[2]
      turn_actions = turn_actions.scan(/\d+|[a-z]/) unless turn_actions.nil?
      action_parser(street: "turn", board: board[0] + board[1], players: @active_players, actions: turn_actions)
    end

    #river
    if board[2]
      river_actions = actions[3]
      river_actions = river_actions.scan(/\d+|[a-z]/) unless river_actions.nil?
      action_parser(street: "river", board: board[0] + board[1] + board[2], players: @active_players, actions: river_actions)
    end

    puts "Final Results"
    puts "\n"
    results = args[-2].split("|")
    puts "#{players[0]} - SB #{results[0]}"
    puts "#{players[1]} - BB #{results[1]}"
    puts "#{players[2]} - UTG #{results[2]}"
    puts "#{players[3]} - Highjack #{results[3]}"
    puts "#{players[4]} - Cutoff #{results[4]}"
    puts "#{players[5]} - Button #{results[5]}"
  end
end