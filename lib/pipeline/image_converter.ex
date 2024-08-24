defmodule AssetPiper.ImageConverter do
  use GenStage
  require Logger

  def start_link(_initial) do
    GenStage.start_link(__MODULE__, :state_doesnt_matter)
  end

  def init(state) do
    {:consumer, state, subscribe_to: [AssetPiper.BroadcastProducer]}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      Logger.info("Received event: #{inspect(event)}")
      convert_image(event)
    end

    # As a consumer we never emit events
    {:noreply, [], state}
  end

  def convert_image(filepath) do
    {:ok, thumb} =
      AssetPiper.Core.FileWatcher.read_file!(filepath)
      |> Image.thumbnail(128)

    sizes =
      Enum.map([24, 32, 48, 64], fn size ->
        thumb
        |> Image.thumbnail!(size)
      end)

    Enum.map(sizes, fn img ->
      Enum.map([2, 3, 4, 5], fn colors ->
        {:ok, grey} = Image.to_colorspace(img, :bw)

        path = "out/img_#{colors}.png"

        grey
        |> Image.reduce_colors!(colors: colors)
        |> Image.write!(path)
      end)
    end)
  end
end
