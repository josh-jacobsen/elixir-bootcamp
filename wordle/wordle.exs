defmodule Wordle.Service do
  @guesses 6
  @all_valid_words_file_path "/Users/josh/Downloads/all_words.txt"
  @target_word_file_path "/Users/josh/Downloads/words.txt"

  def start() do
    target_word = load_target_word(@target_word_file_path)
    all_valid_words = load_all_valid_words(@all_valid_words_file_path)

    game_loop(target_word, all_valid_words, @guesses)
  end

  def game_loop(target_word, _all_words, 0) do
    Wordle.UI.inform_user_of_defeat(target_word)
  end

  def game_loop(target_word, all_words, guesses_remaining) do
    guess = Wordle.UI.prompt_user_for_guess(guesses_remaining)

    case Wordle.Validation.validate_guess(guess, all_words, target_word) do
      {:ok, guess} ->
        check_guess_against_target_word(guess, target_word)
        |> Wordle.UI.display_result()

        game_loop(target_word, all_words, guesses_remaining - 1)

      :won ->
        Wordle.UI.inform_user_of_victory(target_word)

      {:error, reason} ->
        Wordle.UI.inform_user_of_error(reason)
        game_loop(target_word, all_words, guesses_remaining)
    end
  end

  def check_guess_against_target_word(guess, target_word) do
    target_word_graphemes = String.graphemes(target_word)
    guess_graphemes = String.graphemes(guess)
    check_guess_against_target(guess_graphemes, target_word_graphemes, [])
  end

  defp compare_letters_guess_vs_target_word(element, element, _target_word_graphemes, acc) do
    [IO.ANSI.format([:green, element]) | acc]
  end

  defp compare_letters_guess_vs_target_word(first, element, target_word_graphemes, acc) do
    total_letters_in_word =
      Enum.count(target_word_graphemes, fn grapheme -> grapheme == first end)

    yellow_letters_in_acc =
      Enum.count(acc, fn grapheme ->
        grapheme == IO.ANSI.format([:yellow, first])
      end)

    green_letters_in_acc =
      Enum.count(acc, fn grapheme ->
        grapheme == IO.ANSI.format([:green, first])
      end)

    if yellow_letters_in_acc + green_letters_in_acc < total_letters_in_word do
      [IO.ANSI.format([:yellow, first]) | acc]
    else
      [IO.ANSI.format([:red, first]) | acc]
    end
  end

  def check_guess_against_target([], target_word_graphemes, acc) do
    acc
  end

  def check_guess_against_target(guess_graphemes, target_word_graphemes, acc) do
    [guess_letter | rest] = guess_graphemes

    if guess_letter in target_word_graphemes do
      case Enum.fetch(target_word_graphemes, length(acc)) do
        {:ok, target_word_letter} ->
          new_acc =
            compare_letters_guess_vs_target_word(
              guess_letter,
              target_word_letter,
              target_word_graphemes,
              acc
            )

          check_guess_against_target(rest, target_word_graphemes, new_acc)
      end
    else
      check_guess_against_target(rest, target_word_graphemes, [
        IO.ANSI.format([:red, guess_letter]) | acc
      ])
    end
  end

  defp load_target_word(path) do
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
         :in_progress <- has_guess_won(guess, target_word) do
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

  defp validate_guess_correct_length(guess), do: :ok

  defp validate_guess_is_in_all_words_list(guess, all_words) do
    if Enum.member?(all_words, guess) do
      :ok
    else
      {:error, :guess_not_valid_word}
    end
  end

  defp has_guess_won(target_word, target_word), do: :won
  defp has_guess_won(_, _), do: :in_progress
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
    |> Enum.reverse()
    |> IO.puts()
  end
end

Wordle.Service.start()
