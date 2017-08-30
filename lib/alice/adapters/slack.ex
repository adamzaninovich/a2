defmodule Alice.Adapters.Slack do
  @moduledoc """
  Alice Slack Adapter

  This adapter lets you connect Alice to Slack

      config :my_app, MyApp.Bot,
        adapter: Alice.Adapters.Slack,
        slack_token: System.get_env("SLACK_TOKEN")
        ...

  Start your application with `mix run --no-halt` and you will have a console
  interface to your bot.
  """

  use Alice.Adapter
  alias Alice.Adapters.Slack.Connection

  def init({bot, opts}) do
    {:ok, conn} = Connection.start_link(opts)
    send(self(), :connected)
    {:ok, %{conn: conn, opts: opts, bot: bot}}
  end

  def handle_cast({:reply, msg}, %{conn: conn} = state) do
    send(conn, {:reply, msg})
    {:noreply, state}
  end

  def handle_info(:connected, %{bot: bot} = state) do
    :ok = Alice.Bot.handle_connect(bot)
    {:noreply, state}
  end
  def handle_info({:message, message}, %{bot: bot} = state) do
    Alice.Bot.handle_in(bot, make_msg(bot, message))
    {:noreply, state}
  end

  defp make_msg(bot, %{message: msg, slack: slack}) do
    msg = sanitize_message(msg, bot, slack.me.id)
    %{user: user_id, channel: room, text: text} = msg
    %Alice.Message{
      ref: make_ref(),
      bot: bot,
      room: room,
      text: text,
      type: "message",
      user: %Alice.User{
        id: user_id,
        name: slack.users[user_id].name
      },
      private: %{
        slack_message: msg,
        slack: slack
      }
    }
  end

  defp sanitize_message(msg, bot, bot_id) do
    msg
    |> Map.put(:original_text, msg.text)
    |> Map.put(:text, sanitize_text(msg.text, bot, bot_id))
  end

  defp sanitize_text(text, bot, bot_id) do
    text
    |> replace_botname(bot, bot_id)
    |> remove_smart_quotes()
    |> remove_formatted_emails()
    |> remove_formatted_urls()
  end

  defp replace_botname(text, bot, bot_id) do
    botname = Alice.Bot.name(bot)
    String.replace(text, "<@#{bot_id}>", botname)
  end

  defp remove_smart_quotes(text) do
    text
    |> String.replace(~s(“), ~s("))
    |> String.replace(~s(”), ~s("))
    |> String.replace(~s(’), ~s('))
  end

  defp remove_formatted_emails(text) do
    String.replace(text, ~r/<mailto:([^|]+)[^\s]*>/i, "\\1")
  end

  defp remove_formatted_urls(text) do
    String.replace(text, ~r/<([^|@]+)([^\s]*)?>/, "\\1")
  end
end
