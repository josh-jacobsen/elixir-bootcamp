defmodule Wordle.Service do
  alias Wordle.{UI, Validation}
  @guesses 6
  @all_valid_words_file_path "./all_words.txt"
  @target_word_file_path "./words.txt"

  def start() do
    target_word = pick_random_word(@target_word_file_path)
    all_valid_words = load_all_valid_words(@all_valid_words_file_path)

    game_loop(target_word, all_valid_words, @guesses)
  end

  def game_loop(target_word, _all_words, 0) do
    UI.inform_user_of_defeat(target_word)
  end

  def game_loop(target_word, all_words, guesses_remaining) do
    guess = UI.prompt_user_for_guess(guesses_remaining)

    case Validation.validate_guess(guess, all_words, target_word) do
      {:ok, guess} ->
        score(guess, target_word)
        |> UI.display_result()

        game_loop(target_word, all_words, guesses_remaining - 1)

      :won ->
        UI.inform_user_of_victory(target_word)

      {:error, reason} ->
        UI.inform_user_of_error(reason)
        game_loop(target_word, all_words, guesses_remaining)
    end
  end

  def score(guess, target_word) do
    target_word_graphemes = String.graphemes(target_word)
    guess_graphemes = String.graphemes(guess)
    recurse(guess_graphemes, target_word_graphemes, [])
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

  def recurse([], _target_word_graphemes, acc), do: acc

  def recurse([guess_letter | rest], target_word_graphemes, acc) do
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

  defp pick_random_word(path) do
    {:ok, words} = File.read(path)

    words
    |> String.split()
    |> Enum.random()
    |> IO.inspect()
  end

  defp load_all_valid_words(path) do
    {:ok, words} = File.read(path)
    String.split(words)
  end
end

defmodule Wordle.Validation do
  @word_length 5

  def validate_guess(guess, all_words, target_word) do
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

defmodule Wordle.UI do
  def inform_user_of_defeat(target_word) do
    IO.puts("You lost")
    IO.puts("The word was #{target_word}")
  end

  def inform_user_of_victory(target_word) do
    IO.puts("Congrats!! You won -- the word was #{IO.ANSI.format([:green, target_word])}")
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
end

Wordle.Service.start()
