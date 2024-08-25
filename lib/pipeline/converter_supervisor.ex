defmodule AssetPiper.ConverterSupervisor do
  use ConsumerSupervisor
  require Logger

  def start_link(_opts) do
    ConsumerSupervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      %{
        id: AssetPiper.ImageConverter,
        start: {AssetPiper.ImageConverter, :start_link, []},
        restart: :transient
      }
    ]

    opts = [strategy: :one_for_one, subscribe_to: [AssetPiper.BroadcastProducer]]

    ConsumerSupervisor.init(children, opts)
  end
end
