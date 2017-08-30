defmodule Alice.Adapters.Slack.Connection do
  use Slack
  alias Alice.Message

  def start_link(opts) do
    botname = Keyword.get(opts, :name)
    Slack.Bot.start_link(__MODULE__, {self(), botname}, opts[:slack_token])
  end

  def handle_connect(slack, state) do
    IO.puts "Connected to Slack as #{slack.me.name}"
    {:ok, state}
  end

  def handle_event(%{subtype: "bot_message"}, _slack, state), do: {:ok, state}
  def handle_event(%{type: "message"} = msg, slack, {owner, _botname}=state) do
    send(owner, {:message, %{message: msg, slack: slack}})
    {:ok, state}
  end
  def handle_event(_message, _slack, state), do: {:ok, state}

  def handle_info({:reply, %Message{room: channel, text: text}}, slack, state) do
    send_message(text, channel, slack)
    {:ok, state}
  end
  def handle_info(_, _, state), do: {:ok, state}
end
