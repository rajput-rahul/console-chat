defmodule ElixirSocketTest do
  use ExUnit.Case
  doctest ElixirSocket

  test "greets the world" do
    assert ElixirSocket.hello() == :world
  end
end
