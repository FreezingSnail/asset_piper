defmodule AssetPiper.Core.FileWatcher do
  require Logger

  def scan_directory(directory) do
    case File.ls(directory) do
      {:ok, files} ->
        files
        |> Enum.map(fn file -> Path.join(directory, file) end)
        |> Enum.filter(&File.regular?/1)

      {:error, reason} ->
        IO.puts("Error scanning directory: #{reason}")
        []
    end
  end

  def filter_files(file_list, exclude_set) do
    Enum.filter(file_list, fn file ->
      not MapSet.member?(MapSet.new(exclude_set), file)
    end)
  end

  def read_file!(file_path) do
    File.read!(file_path)
    |> Image.from_binary!()
  end
end
