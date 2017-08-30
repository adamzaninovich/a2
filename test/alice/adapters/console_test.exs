defmodule Alice.Adapters.ConsoleTest do
  use ExUnit.Case

  import ExUnit.CaptureIO
  alias Alice.Adapters.Console

  # test "console handles messages from the connection" do
  #   capture_io fn ->
  #     {:ok, adapter} = Alice.Adapter.start_link(Console, name: "alice", user: "testuser")
  #
  #     handle_connect()
  #     # Simulate an incoming message from the connection process
  #     msg = {:message, %{"text" => "ping", "user" => "testuser"}}
  #     send(adapter, msg)
  #     assert_receive {:"$gen_cast", {:handle_in, %Alice.Message{text: "ping", user: "testuser"}}}
  #   end
  # end

  # describe "sending messages to the connection process" do
  #   test "reply/2" do
  #     capture_io fn ->
  #       {:ok, adapter} = Alice.Adapter.start_link(Console, name: "alice", user: "testuser")
  #
  #       handle_connect()
  #       # replace the adapter's connection pid to the test process
  #       replace_connection_pid(adapter)
  #
  #       msg = %Alice.Message{text: "pong", user: "testuser"}
  #       Console.reply(adapter, msg)
  #
  #       assert_receive {:reply, ^msg}
  #     end
  #   end
  #
  #   test "reply/2 includes the reply user's name" do
  #     capture_io fn ->
  #       {:ok, adapter} = Alice.Adapter.start_link(Console, name: "alice", user: "testuser")
  #
  #       handle_connect()
  #       # replace the adapter's connection pid to the test process
  #       replace_connection_pid(adapter)
  #
  #       msg = %Alice.Message{text: "pong", user: "testuser"}
  #       Console.reply(adapter, msg)
  #
  #       assert_receive {:reply, %Alice.Message{text: "testuser: pong"}}
  #     end
  #   end
  #
  #   test "emote/2" do
  #     capture_io fn ->
  #       {:ok, adapter} = Alice.Adapter.start_link(Console, name: "alice", user: "testuser")
  #
  #       handle_connect()
  #       # replace the adapter's connection pid to the test process
  #       replace_connection_pid(adapter)
  #
  #       msg = %Alice.Message{text: "pong", user: "testuser"}
  #       Console.emote(adapter, msg)
  #
  #       assert_receive {:reply, ^msg}
  #     end
  #   end
  # end

  defp handle_connect do
    receive do
      {:"$gen_call", from, :handle_connect} ->
        GenServer.reply(from, :ok)
    end
  end

  defp replace_connection_pid(adapter) do
    test_process = self()
    :sys.replace_state(adapter, fn state -> %{state | conn: test_process} end)
  end
end
