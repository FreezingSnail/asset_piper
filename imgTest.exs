original_raw = File.read!("priv/testSideProfile.jpeg");
{:ok, original} = Image.from_binary(original_raw)
{:ok, thumb} = Image.thumbnail(original, 128)


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
