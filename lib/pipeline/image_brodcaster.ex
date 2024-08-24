defmodule AssetPiper.BroadcastProducer do
  use GenStage
  require Logger

  def start_link(initial_state) do
    GenStage.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def add_events(events) when is_list(events) do
    Logger.info("Adding events: #{inspect(events)}")
    GenStage.cast(__MODULE__, {:add_events, events})
  end

  def add_event(event) do
    GenStage.cast(__MODULE__, {:add_events, [event]})
  end

  @impl true
  def init(initial_state) do
    Logger.info("BroadcastProducer started with initial state: #{inspect(initial_state)}")
    {:producer, %{events: initial_state, demand: 0}}
  end

  @impl true
  def handle_demand(incoming_demand, %{events: events, demand: pending_demand} = state) do
    new_demand = pending_demand + incoming_demand
    {events_to_send, remaining_events} = Enum.split(events, new_demand)
    new_state = %{state | events: remaining_events, demand: new_demand - length(events_to_send)}

    {:noreply, events_to_send, new_state}
  end

  @impl true
  def handle_cast({:add_events, new_events}, %{events: events, demand: demand} = state) do
    new_events_list = events ++ new_events
    {events_to_send, remaining_events} = Enum.split(new_events_list, demand)
    new_state = %{state | events: remaining_events, demand: demand - length(events_to_send)}

    {:noreply, events_to_send, new_state}
  end

  @impl true
  def handle_info(:timeout, state) do
    Logger.info("BroadcastProducer timeout occurred. State: #{inspect(state)}")
    {:noreply, [], state}
  end
end
