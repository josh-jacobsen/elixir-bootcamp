defmodule Surdle.Server do
  @word_length 5

  @target_word_file_path "/Users/josh/cogo/elixir/bootcamp/surdle/words.txt"
  @all_valid_words_file_path "/Users/josh/cogo/elixir/bootcamp/surdle/all_words.txt"

  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{target_word: nil}, name: __MODULE__)
  end

  def init(state) do
    case File.read(@all_valid_words_file_path) do
      {:ok, words} ->
        all_words = String.split(words)
        {:ok, Map.put(state, :all_words, all_words)}

      error ->
        error
    end
  end

  def handle_call(:pick_random_word, __from, state) do
    {:ok, words} = File.read(@target_word_file_path)

    target_word =
      words
      |> String.split()
      |> Enum.random()

    IO.inspect(state, label: "state")
    {:reply, target_word, %{state | target_word: target_word}}
  end

  def handle_call({:validate_guess, guess, target_word}, _from, state) do
    IO.inspect(state, label: "state")

    validation_result = validate(state.all_words, guess, state.target_word)

    case validation_result do
      {:ok, guess} ->
        {:reply, {:ok, guess}, state}

      :won ->
        {:reply, :won, state}

      {:error, reason} ->
        {:reply, {:failed_validation, reason}, state}
    end
  end

  def handle_call({:score, guess, target_word}, _from, state) do
    result = score_game(guess, target_word)
    # IO.inspect(result, label: "result server side")
    {:reply, result, state}
  end

  def pick_random_word(pid \\ __MODULE__) do
    GenServer.call(pid, :pick_random_word)
  end

  def validate_guess(pid \\ __MODULE__, guess, target_word) do
    GenServer.call(pid, {:validate_guess, guess, target_word})
  end

  def score(pid \\ __MODULE__, guess, target_word) do
    GenServer.call(pid, {:score, guess, target_word})
  end

  defp score_game(guess, target_word) do
    target_word_graphemes = String.graphemes(target_word)
    guess_graphemes = String.graphemes(guess)
    recurse(guess_graphemes, target_word_graphemes, [])
  end

  defp recurse([], _target_word_graphemes, acc), do: acc

  defp recurse([guess_letter | rest], target_word_graphemes, acc) do
    if guess_letter in target_word_graphemes do
      target_word_letter = Enum.at(target_word_graphemes, length(acc))

      new_acc =
        compare_letters(
          guess_letter,
          target_word_letter,
          target_word_graphemes,
          acc
        )

      recurse(rest, target_word_graphemes, new_acc)
    else
      recurse(rest, target_word_graphemes, [{:wrong, guess_letter} | acc])
    end
  end

  defp compare_letters(
         letter,
         letter,
         _target_word_graphemes,
         acc
       ) do
    [{:correct, letter} | acc]
  end

  defp compare_letters(
         letter,
         _element,
         target_word_graphemes,
         acc
       ) do
    total_letters_in_word = Enum.count(target_word_graphemes, &(&1 == letter))
    yellow_letters_in_acc = Enum.count(acc, &(&1 == {:wrong_place, letter}))
    green_letters_in_acc = Enum.count(acc, &(&1 == {:correct, letter}))

    if yellow_letters_in_acc + green_letters_in_acc < total_letters_in_word do
      [{:wrong_place, letter} | acc]
    else
      [{:wrong, letter} | acc]
    end
  end

  defp validate(all_words, guess, target_word) do
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
