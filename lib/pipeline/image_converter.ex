defmodule AssetPiper.ImageConverter do
  require Logger

  def start_link(event) do
    Logger.info("ImageConverter started with event: #{inspect(event)}")
    Task.start_link(fn -> convert_image(event) end)
  end

  def convert_image(filepath) do
    Logger.info("Converting image: #{filepath}")

    ImageCrusher.convert_to_4_color_grayscale(filepath)

    Logger.info("Converted image: #{filepath}")
  end
end
