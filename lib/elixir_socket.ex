defmodule ElixirSocket do
  use Application

  def start(_type, _args) do
    :ranch.start_listener(make_ref(), :ranch_tcp, [{:port, 5555}], SocketChat.Handler, [])
    :ets.new(:chat_registry, [:set, :named_table, :public])
    {:ok, self()}
  end
end
