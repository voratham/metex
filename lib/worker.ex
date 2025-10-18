defmodule Metex.Worker do
  def loop do
    receive do
      {sender_pid, location} -> send(sender_pid, {:ok, temperature_of(location)})
      _ -> IO.puts("Unknown message")
    end

    loop()
  end

  def temperature_of(location) do
    result = get_base_url(location) |> HTTPoison.get() |> parse_resp

    case result do
      {:ok, temp} ->
        "#{location}: #{temp}°C"

      :error ->
        "#{location} not found"
    end
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
    "00b76f527833334d4c2bd94f0f64294a"
  end
end
