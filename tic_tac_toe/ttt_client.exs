defmodule TTT.Client do
  def start(server_pid, port) do
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    game_loop(server_pid, socket)
  end

  def game_loop(server_pid, socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    spawn(fn -> register(server_pid, client) end)
    game_loop(server_pid, socket)
  end

  def register(server_pid, socket) do
    IO.puts("registering")
    send(server_pid, {self(), :register})

    puts("Waiting for other player...", socket)

    receive do
      {:your_turn, board} ->
        puts("Got :your_turn from server", socket)
        play(server_pid, board, socket)

      {:error, :game_full} ->
        puts("Game is full :(", socket)
    end

    :gen_tcp.close(socket)
  end

  defp play(server_pid, board, socket) do
    print_board(board, socket)
    position = ask_for_position(socket)
    send(server_pid, {self(), {:play, position - 1}})

    receive do
      {:error, error} ->
        print_error(error, socket)
        play(server_pid, board, socket)

      {:accepted, board} ->
        print_board(board, socket)
        puts("Waiting for other player...", socket)

        receive do
          {:your_turn, board} ->
            play(server_pid, board, socket)

          {:game_complete, board} ->
            print_board(board, socket)
            puts("Game complete!", socket)
        end
    end
  end

  defp ask_for_position(socket) do
    gets("Play at position (1-9): ", socket)
    |> String.trim()
    |> Integer.parse()
    |> case do
      {number, ""} ->
        number

      _ ->
        puts("Not a valid number", socket)
        ask_for_position(socket)
    end
  end

  defp print_error(error, socket) do
    case error do
      :not_your_turn -> "Weird, it wasn't my turn."
      :invalid_position -> "That's not a valid position."
      :cell_not_empty -> "That cell is not empty."
      error -> "Error '#{error}' occurred."
    end
    |> puts(socket)
  end

  defp print_board(board, socket) do
    board
    |> Enum.map(fn
      nil -> " "
      0 -> "X"
      1 -> "O"
    end)
    |> Enum.chunk_every(3)
    |> Enum.map(&Enum.join(&1, " | "))
    |> Enum.intersperse("---------")
    |> Enum.join("\n")
    |> then(&"\n#{&1}\n")
    |> puts(socket)
  end

  defp gets(prompt, socket) do
    print(prompt, socket)
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end

  defp puts(line, socket) do
    print("#{line}\n", socket)
  end

  defp print(line, socket) do
    :gen_tcp.send(socket, line)
  end
end

defmodule TTT.Server do
  @cell_count 9

  @initial_state %{
    player_one: nil,
    player_two: nil,
    current_player: nil,
    board: List.duplicate(nil, @cell_count)
  }

  @winning_arrangement [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6]
  ]

  def start() do
    spawn(fn -> game_loop(@initial_state) end)
  end

  defp game_loop(state) do
    receive do
      {sender_pid, :register} ->
        case state do
          %{player_one: nil} ->
            game_loop(%{state | player_one: sender_pid})

          %{player_two: nil} ->
            send(sender_pid, {:your_turn, state.board})

            game_loop(%{state | player_two: sender_pid, current_player: :player_two})

          %{player_one: pid_1, player_two: pid_2} ->
            send(sender_pid, {:error, :game_full})
        end

      {sender_pid, {:play, position}} ->
        case play(state, position) do
          :complete -> nil
          state -> game_loop(state)
        end
    end
  end

  def send_to_player(player, state, message) do
    player_pid = Map.get(state, player)

    send(player_pid, message)
  end

  def play(state, position) do
    player = state.current_player
    next_player = opponent(player)

    with :ok <- validate_position_input(position),
         :ok <- validate_board_slot_open(state, position) do
      updated_board = mark_board_at_position(state.board, player, position)

      send_to_player(player, state, {:accepted, updated_board})

      if game_over?(updated_board) do
        send_to_player(player, state, {:game_complete, updated_board})
        send_to_player(next_player, state, {:game_complete, updated_board})
        :complete
      else
        send_to_player(next_player, state, {:your_turn, updated_board})
        %{state | board: updated_board, current_player: next_player}
      end
    else
      {:error, reason} ->
        send_to_player(player, state, {:error, reason})
        state
    end
  end

  def symbol_at_position(board, position) do
    Enum.at(board, position)
  end

  def game_over?(board) do
    Enum.any?(@winning_arrangement, fn positions ->
      positions
      |> Enum.map(&symbol_at_position(board, &1))
      |> winning_combo?()
    end)
  end

  defp winning_combo?([nil, nil, nil]), do: false
  defp winning_combo?([a, a, a]), do: true
  defp winning_combo?(_), do: false

  def mark_board_at_position(board, player, position) do
    List.replace_at(board, position, symbol_for_player(player))
  end

  defp symbol_for_player(:player_one), do: 0

  defp symbol_for_player(:player_two), do: 1

  defp opponent(:player_one), do: :player_two
  defp opponent(:player_two), do: :player_one

  defp validate_board_slot_open(state, position) do
    case Enum.fetch(Map.get(state, :board), position) do
      {:ok, nil} -> :ok
      _ -> {:error, :cell_not_empty}
    end
  end

  defp validate_position_input(position) do
    if Enum.member?(0..(@cell_count - 1), position) do
      :ok
    else
      {:error, :invalid_position}
    end
  end
end

server_pid = TTT.Server.start()
TTT.Client.start(server_pid, 6000)
