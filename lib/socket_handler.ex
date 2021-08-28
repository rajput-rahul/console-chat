defmodule SocketChat.Handler do
  use GenServer
  @behaviour :ranch_protocol

  def start_link(ref, socket, transport, _opts \\ []) do
    pid = :proc_lib.spawn_link(__MODULE__, :init, [ref, socket, transport])
    {:ok, pid}
  end

  def init(ref, socket, transport) do
    :ok = :ranch.accept_ack(ref)
    :ok = transport.setopts(socket, [{:active, true}])
    :gen_server.enter_loop(__MODULE__, [], %{socket: socket, transport: transport})
  end

  def handle_info(
        {:tcp, socket, "name: " <> name},
        state = %{socket: socket, transport: transport}
      ) do
    transport.send(socket, Color.green("Thanks for the intro\n"))
    :ets.insert(:chat_registry, {String.trim(name, "\r\n"), socket})
    {:noreply, Map.put(state, :name, String.trim(name, "\r\n"))}
  end

  def handle_info(
        {:tcp, socket, "message: " <> message},
        state = %{socket: socket, transport: transport, name: name}
      ) do
    arrays = :ets.tab2list(:chat_registry)

    arrays
    |> Enum.reject(fn {i_name, _} -> i_name == name end)
    |> Enum.each(fn {_, i_socket} -> transport.send(i_socket, Color.yellow("#{name}: " <> message)) end)

    transport.send(socket, "OK\n")
    {:noreply, Map.put(state, :name, name)}
  end

  def handle_info({:tcp, socket, data}, state = %{socket: socket, transport: transport}) do
    IO.inspect(data)
    transport.send(socket, "i didn't get that.\n")
    {:noreply, state}
  end

  def handle_info({:tcp_closed, socket}, state = %{socket: socket, transport: transport}) do
    IO.puts("Closing")
    :ets.delete(:chat_registry, Map.get(state, :name))
    transport.close(socket)
    {:stop, :normal, state}
  end
end
