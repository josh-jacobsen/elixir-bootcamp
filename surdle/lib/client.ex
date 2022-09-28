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
      :ok ->
        game_loop(target_word, remaining_guesses - 1)

      :won ->
        IO.puts("You won")

      {:failed_validation, reason} ->
        IO.puts("Validation failed because: #{reason}")
        game_loop(target_word, remaining_guesses)
    end
  end

  def prompt_user_for_guess(guesses_remaining) do
    IO.puts("You have #{guesses_remaining} guesses remaining")

    IO.gets("Enter your guess: ")
    |> String.trim()
    |> String.downcase()
  end
end
