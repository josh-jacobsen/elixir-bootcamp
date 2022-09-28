defmodule SurdleTest do
  use ExUnit.Case
  doctest Surdle

  test "greets the world" do
    assert Surdle.hello() == :world
  end
end
