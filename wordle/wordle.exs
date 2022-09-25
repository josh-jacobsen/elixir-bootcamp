defmodule Wordle do
  @guesses 6
  def start() do
    {:ok, words} = File.read("/Users/josh/Downloads/words.txt")
    {:ok, all_words} = File.read("/Users/josh/Downloads/all_words.txt")

    words
    |> String.split()
    |> Enum.random()
    |> IO.inspect()
    |> game_loop(all_words, @guesses)
  end

  def game_loop(word, all_words, 0) do
    IO.puts("You lost")
    IO.puts("The word was #{word}")
  end

  def game_loop(word, all_words, guesses_remaining) do
    IO.puts("You have #{guesses_remaining} guesses remaining")
    guess = prompt_user_for_guess()

    with :ok <- validate_guess_length(guess),
         :ok <- validate_guess_is_word(guess, all_words) do
      guess
      |> IO.inspect()
      |> apply_colors(word)
      |> Enum.reverse()
      |> IO.puts()

      game_loop(word, all_words, guesses_remaining - 1)
    else
      {:error, reason} ->
        IO.puts("Things blew up becasue #{reason}")
        game_loop(word, all_words, guesses_remaining)
    end
  end

  defp apply_colors(guess, word) do
    # Need to not apply colors twice if there are multiple letters in the word
    word_graphemes = String.graphemes(word)

    Enum.reduce(String.graphemes(guess), [], fn value, acc ->
      if value in word_graphemes do
        case Enum.fetch(word_graphemes, length(acc)) do
          {:ok, element} ->
            if element == value do
              [IO.ANSI.format([:green, value]) | acc]
            else
              my_count = Enum.count(word_graphemes, fn grapheme -> grapheme == value end)

              acc_count_yellow =
                Enum.count(acc, fn grapheme -> grapheme == IO.ANSI.format([:yellow, value]) end)

              acc_count_green =
                Enum.count(acc, fn grapheme -> grapheme == IO.ANSI.format([:green, value]) end)

              total_count = acc_count_yellow + acc_count_green

              if total_count < my_count do
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
  end

  defp validate_guess_length(guess) do
    cond do
      String.length(guess) == 5 -> :ok
      String.length(guess) < 5 -> {:error, :guess_too_short}
      String.length(guess) > 5 -> {:error, :guess_too_long}
      true -> {:error, :invalid_guess}
    end
  end

  defp validate_guess_is_word(guess, all_words) do
    word_list = String.split(all_words)

    if Enum.member?(word_list, guess) do
      :ok
    else
      {:error, :guess_not_valid_word}
    end
  end
end

Wordle.start()
