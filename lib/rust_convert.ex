defmodule ImageCrusher do
  use Rustler, otp_app: :asset_piper, crate: "imagecrusher"

  # When your NIF is loaded, it will override this function.
  def convert_to_4_color_grayscale(filepath), do: :erlang.nif_error(:nif_not_loaded)
end
