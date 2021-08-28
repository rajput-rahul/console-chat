defmodule Color do
  def green(text) do
    IO.ANSI.green() <> text <> IO.ANSI.reset()
  end

  def yellow(text) do
    IO.ANSI.yellow() <> text <> IO.ANSI.reset()
  end
end
