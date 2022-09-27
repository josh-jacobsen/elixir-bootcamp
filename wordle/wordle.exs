defmodule Wordle.Service do
  @guesses 6
  @all_valid_words_file_path "/Users/josh/Downloads/all_words.txt"
  @target_word_file_path "/Users/josh/Downloads/words.txt"

  def start() do
    #  Abstraction level
    # Module extraction
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
        apply_colors(guess, target_word)
        |> Enum.reverse()
        |> IO.puts()

        game_loop(target_word, all_words, guesses_remaining - 1)

      :won ->
        Wordle.UI.inform_user_of_victory(target_word)

      {:error, reason} ->
        Wordle.UI.inform_user_of_error(reason)
        game_loop(target_word, all_words, guesses_remaining)
    end
  end

  defp apply_colors(guess, word) do
    word_graphemes = String.graphemes(word)

    # No more than 3 layers deep
    Enum.reduce(String.graphemes(guess), [], fn value, acc ->
      if value in word_graphemes do
        case Enum.fetch(word_graphemes, length(acc)) do
          {:ok, element} ->
            if element == value do
              [IO.ANSI.format([:green, value]) | acc]
            else
              total_letters_in_word =
                Enum.count(word_graphemes, fn grapheme -> grapheme == value end)

              yellow_letters_in_acc =
                Enum.count(acc, fn grapheme -> grapheme == IO.ANSI.format([:yellow, value]) end)

              green_letters_in_acc =
                Enum.count(acc, fn grapheme -> grapheme == IO.ANSI.format([:green, value]) end)

              if yellow_letters_in_acc + green_letters_in_acc < total_letters_in_word do
                [IO.ANSI.format([:yellow, value]) | acc]
              else
                [IO.ANSI.format([:red, value]) | acc]
              end
            end
        end
      else
        [IO.ANSI.format([:red, value]) | acc]
      end
    end)
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
    # make this better
    cond do
      String.length(guess) == 5 -> :ok
      String.length(guess) < 5 -> {:error, :guess_too_short}
      String.length(guess) > 5 -> {:error, :guess_too_long}
      true -> {:error, :invalid_guess}
    end
  end

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
end

Wordle.Service.start()
