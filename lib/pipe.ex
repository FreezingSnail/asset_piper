defmodule Pipe do
  def pipe() do
    original_raw = File.read!("priv/testSideProfile.jpeg")
    {:ok, original} = Image.from_binary(original_raw)
    {:ok, thumbnail} = Image.thumbnail(original, 128)

    thumbnail
    |> Image.reduce_colors(colors: 4)
    |> Image.write("out/thumbnail.png")
  end
end
