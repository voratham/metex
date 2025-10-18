defmodule PingPong.Client do
  def ping do
    ping_pid =
      spawn(
        PingPong.Worker,
        :loop,
        []
      )

    send(ping_pid, {self(), "Ping message"})
  end
end
