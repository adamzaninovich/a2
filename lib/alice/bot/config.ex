defmodule Alice.Bot.Config do
  defstruct [:otp_app, :adapter, :bot_config]

  def config(bot, otp_app, opts) do
    if bot_config = Application.get_env(otp_app, bot) do
      bot_config
      |> Keyword.put(:otp_app, otp_app)
      |> Keyword.put(:bot, bot)
      |> Keyword.merge(opts)
    else
      raise ArgumentError, "no config found"
    end
  end

  def init_config(bot, opts) do
    otp_app = opts[:otp_app]
    bot_config = Application.get_env(otp_app, bot)
    adapter = opts[:adapter] || bot_config[:adapter]

    unless adapter, do: raise ArgumentError, "please configure an adapter"

    new(otp_app, adapter, bot_config)
  end

  def new(otp_app, adapter, bot_config) do
    %__MODULE__{otp_app: otp_app, adapter: adapter, bot_config: bot_config}
  end
end
