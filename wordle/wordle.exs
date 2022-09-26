defmodule Wordle do
  @guesses 6
  def start() do
    {:ok, words} = File.read("/Users/josh/Downloads/words.txt")
    {:ok, all_words} = File.read("/Users/josh/Downloads/all_words.txt")

    words
    |> String.split()
    |> Enum.random()
    # |> IO.inspect()
    |> game_loop(all_words, @guesses)
  end

  def game_loop(word, _all_words, 0) do
    IO.puts("You lost")
    IO.puts("The word was #{word}")
  end

  def game_loop(word, all_words, guesses_remaining) do
    IO.puts("You have #{guesses_remaining} guesses remaining")
    guess = prompt_user_for_guess()

    with :ok <- validate_guess_length(guess),
         :ok <- validate_guess_is_in_all_words_list(guess, all_words),
         :ok <-
           validate_has_guess_won(guess, word) do
      guess
      |> apply_colors(word)
      |> Enum.reverse()
      |> IO.puts()

      game_loop(word, all_words, guesses_remaining - 1)
    else
      {:ok, :won} ->
        IO.puts("Congrats!! You won -- the word was #{IO.ANSI.format([:green, word])}")

      {:error, reason} ->
        IO.puts("Things blew up becasue #{reason}")
        game_loop(word, all_words, guesses_remaining)
    end
  end

  defp apply_colors(guess, word) do
    word_graphemes = String.graphemes(word)

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
                [IO.ANSI.format([:black, value]) | acc]
              end
            end
        end
      else
        [IO.ANSI.format([:black, value]) | acc]
      end
    end)
  end

  defp prompt_user_for_guess() do
    IO.gets("Enter your guess: ")
    |> String.trim()
    |> String.downcase()
  end

  defp validate_has_guess_won(guess, word) do
    if guess == word do
      {:ok, :won}
    else
      :ok
    end
  end

  # Tried a few different approaches to writing this validation function. Since String.length can't be used in a guard,
  # and pattern matching on the input list would get verbose, this was the most elegant implementation I could come up with
  defp validate_guess_length(guess) do
    cond do
      String.length(guess) == 5 -> :ok
      String.length(guess) < 5 -> {:error, :guess_too_short}
      String.length(guess) > 5 -> {:error, :guess_too_long}
      true -> {:error, :invalid_guess}
    end
  end

  # defp validate_guess_length(guess) when String.length(guess) < 5 do
  #   {:error, :guess_too_short}
  # end

  # defp validate_guess_length([x1, x2, x3, x4, x5] = guess) do
  #   :ok
  # end

  # defp validate_guess_length(guess) do
  #   {:error, :guess_length_not_valid}
  # end

  defp validate_guess_is_in_all_words_list(guess, all_words) do
    word_list = String.split(all_words)

    if Enum.member?(word_list, guess) do
      :ok
    else
      {:error, :guess_not_valid_word}
    end
  end
end

Wordle.start()
