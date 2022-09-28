defmodule Surdle.Server do
  @word_length 5

  @target_word_file_path "/Users/josh/cogo/elixir/bootcamp/surdle/words.txt"
  @all_valid_words_file_path "/Users/josh/cogo/elixir/bootcamp/surdle/all_words.txt"

  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(state) do
    IO.puts("hello world")
    {:ok, state}
  end

  def echo(pid \\ __MODULE__, data) do
    GenServer.call(pid, {:data, data})
  end

  def handle_call({:data, data}, _from, state) do
    {:reply, state, data}
  end

  def handle_call(:pick_random_word, __from, state) do
    {:ok, words} = File.read(@target_word_file_path)

    target_word =
      words
      |> String.split()
      |> Enum.random()

    {:reply, target_word, state}
  end

  def handle_call({:validate_guess, guess, target_word}, _from, state) do
    IO.puts("Validating guess: #{guess}")
    IO.puts("target word is #{target_word}")
    {:ok, words} = File.read(@all_valid_words_file_path)

    all_words = String.split(words)
    validation_result = validate(all_words, guess, target_word)

    case validation_result do
      {:ok, guess} ->
        {:reply, :ok, state}

      :won ->
        {:reply, :won, state}

      {:error, reason} ->
        {:reply, {:failed_validation, reason}, state}
    end
  end

  def pick_random_word(pid \\ __MODULE__) do
    GenServer.call(pid, :pick_random_word)
  end

  def validate_guess(pid \\ __MODULE__, guess, target_word) do
    IO.puts("got here")
    GenServer.call(pid, {:validate_guess, guess, target_word})
  end

  def validate(all_words, guess, target_word) do
    with :ok <- validate_guess_length(guess),
         :ok <- validate_guess_is_in_all_words_list(guess, all_words),
         :in_progress <- guess_won(guess, target_word) do
      {:ok, guess}
    else
      :won ->
        :won

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp validate_guess_length(guess) do
    validate_guess_correct_length(String.length(guess))
  end

  defp validate_guess_correct_length(guess) when guess < @word_length,
    do: {:error, :guess_too_short}

  defp validate_guess_correct_length(guess) when guess > @word_length,
    do: {:error, :guess_too_long}

  defp validate_guess_correct_length(_guess), do: :ok

  defp validate_guess_is_in_all_words_list(guess, all_words) do
    if Enum.member?(all_words, guess) do
      :ok
    else
      {:error, :guess_not_valid_word}
    end
  end

  defp guess_won(target_word, target_word), do: :won
  defp guess_won(_, _), do: :in_progress
end
