defmodule AssetPiper.FileServer do
  use GenServer
  require Logger

  # Client API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def stop do
    GenServer.cast(__MODULE__, :stop)
  end

  # Server Callbacks

  @impl true
  def init(opts) do
    Logger.info("FileServer started with options: #{inspect(opts)}")
    # Default to 5 seconds if not specified
    interval = Keyword.get(opts, :interval, 5000)
    directory = Keyword.get(opts, :directory, "priv")
    schedule_tick(interval)
    {:ok, %{interval: interval, directory: directory, proccessed: []}}
  end

  @impl true
  def handle_info(:tick, state) do
    new_files = perform_tick(state)
    schedule_tick(state.interval)

    # add new files to processed
    merged_files = new_files ++ state.proccessed
    {:noreply, %{state | proccessed: merged_files}}
  end

  @impl true
  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  # Private Functions

  defp schedule_tick(interval) do
    Process.send_after(self(), :tick, interval)
  end

  defp perform_tick(state) do
    Logger.info("Tick occurred at #{DateTime.utc_now()}")
    # Add your file scanning or other periodic tasks here
    new_files =
      AssetPiper.Core.FileWatcher.scan_directory(state.directory)
      |> AssetPiper.Core.FileWatcher.filter_files(state.proccessed)

    Logger.info("New files: #{inspect(new_files)}")
    AssetPiper.BroadcastProducer.add_events(new_files)
    new_files
  end
end
