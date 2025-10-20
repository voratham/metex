defmodule Metex.Worker do
  use GenServer

  @name MW

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: MW])
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def get_temperature(location) do
    GenServer.call(@name, {:location, location})
  end

  def get_states() do
    GenServer.call(@name, :get_states)
  end

  # Async response
  def reset_states() do
    GenServer.cast(@name, :reset_states)
  end

  def stop() do
    GenServer.cast(@name, :stop)
  end

  def handle_cast(:reset_states, _states) do
    {:noreply, %{}}
  end

  def handle_cast(:stop, stats) do
    # how to response stop process GenServer
    # NOTE: if return wrong format, will error but it will stop process
    # {:stop, :normal, :ok, stats}
    {:stop, :normal, stats}
  end

  # hook of GenServer terminate
  def terminate(reason, states) do
    IO.puts("server terminated because of #{inspect(reason)}")
    inspect(states)
    :ok
  end

  def handle_call(:get_states, _form, states) do
    {:reply, states, states}
  end

  def handle_call({:location, location}, _form, states) do
    case temperature_of(location) do
      {:ok, temp} ->
        new_states = update_states(states, location)
        {:reply, "#{temp}°C", new_states}

      _ ->
        {:reply, :error, states}
    end
  end

  def handle_info(msg, states) do
    IO.puts("received #{inspect(msg)}")
    {:noreply, states}
  end

  @spec update_states(map(), any()) :: map()
  def update_states(old_states, location) do
    case Map.has_key?(old_states, location) do
      true -> Map.update!(old_states, location, fn old_value_of_key -> old_value_of_key + 1 end)
      false -> Map.put_new(old_states, location, 1)
    end
  end

  # def loop do
  #   receive do
  #     {sender_pid, location} -> send(sender_pid, {:ok, temperature_of(location)})
  #     _ -> IO.puts("Unknown message")
  #   end

  #   loop()
  # end

  def temperature_of(location) do
    get_base_url(location) |> HTTPoison.get() |> parse_resp

    # case result do
    #   {:ok, temp} ->
    #     "#{location}: #{temp}°C"

    #   :error ->
    #     "#{location} not found"
    # end
  end

  # status 200
  defp parse_resp({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    body |> JSON.decode!() |> compute_temperature
  end

  defp parse_resp(_) do
    :error
  end

  defp compute_temperature(json) do
    try do
      temp = (json["main"]["temp"] - 273.15) |> Float.round(1)
      {:ok, temp}
    rescue
      _ -> :error
    end
  end

  defp get_base_url(location) do
    location = URI.encode(location)

    base_url = "http://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{api_key()}"

    base_url
  end

  defp api_key do
    "API_TOKEN"
  end
end
