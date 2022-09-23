defmodule Wordle do
  def start() do
    {:ok, words} = File.read("/Users/josh/Downloads/words.txt")
    {:ok, all_words} = File.read("/Users/josh/Downloads/all_words.txt")

    words
    |> String.split()
    |> Enum.random()
    |> IO.inspect()
    |> game_loop(all_words, 7)

    # IO.puts("#{IO.ANSI.cyan()}#{random_input}")

    # IO.puts(IO.ANSI.format([:green, random_input]))
  end

  def prompt_user_for_guess() do
    IO.gets("Enter your guess: ")
    |> String.trim()
  end

  def game_loop(word, all_words, guesses_remaining) do
    guess = prompt_user_for_guess()

    with :ok <- validate_guess_length(guess),
         :ok <- validate_guess_is_word(guess, all_words) do
      guess
      |> IO.inspect()

      # check overlap of guess with word. This will return the word with appropraite colouring.
      # print the word to the console and start the process again.
    else
      {:error, reason} ->
        IO.puts("Things blew up becasue #{reason}")
        game_loop(word, all_words, guesses_remaining)
    end

    # if yes, check if letters are in word and print out their guess with letters in appropriate colors
    # Subtract one from guess count
    #  ask for input and restart the loop
  end

  def validate_guess_length(guess) do
    cond do
      String.length(guess) == 5 -> :ok
      String.length(guess) < 5 -> {:error, :guess_too_short}
      String.length(guess) > 5 -> {:error, :guess_too_long}
      true -> {:error, :invalid_guess}
    end
  end

  def validate_guess_is_word(guess, all_words) do
    word_list = String.split(all_words)

    if Enum.member?(word_list, guess) do
      :ok
    else
      {:error, :guess_not_valid_word}
    end
  end
end

Wordle.start()
