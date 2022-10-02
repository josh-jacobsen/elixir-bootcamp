defmodule Surdle.Client do
  @guesses 6
  use Task

  alias Surdle.Server

  def start_link(arg) do
    Task.start_link(__MODULE__, :run, [arg])
  end

  def run(_arg) do
    target_word = Server.pick_random_word()
    game_loop(target_word, @guesses)
  end

  def game_loop(target_word, 0) do
    IO.puts("You lost. The word was: #{target_word}")
  end

  def game_loop(target_word, remaining_guesses) do
    IO.inspect(target_word, label: "client target word")
    guess = prompt_user_for_guess(remaining_guesses)

    case Server.validate_guess(guess, target_word) do
      {:ok, guess} ->
        guess
        |> Server.score(target_word)
        |> display_result()

        game_loop(target_word, remaining_guesses - 1)

      :won ->
        IO.puts("You won")

      {:failed_validation, reason} ->
        inform_user_of_error(reason)
        game_loop(target_word, remaining_guesses)
    end
  end

  def prompt_user_for_guess(guesses_remaining) do
    IO.puts("You have #{guesses_remaining} guesses remaining")

    IO.gets("Enter your guess: ")
    |> String.trim()
    |> String.downcase()
  end

  def display_result(result) do
    result
    |> colorize()
    |> Enum.reverse()
    |> IO.puts()
  end

  defp colorize(result) do
    Enum.map(result, fn
      {:correct, letter} -> IO.ANSI.format([:green, letter])
      {:wrong_place, letter} -> IO.ANSI.format([:yellow, letter])
      {:wrong, letter} -> IO.ANSI.format([:red, letter])
    end)
  end

  def inform_user_of_error(reason) do
    case reason do
      :guess_too_short ->
        IO.puts("The guess was too short")

      :guess_too_long ->
        IO.puts("The guess was too long")

      :guess_not_valid_word ->
        IO.puts("That isn't a valid word")

      _ ->
        IO.puts("There was an issue with your guess. Please check the input and try again")
    end
  end
end
