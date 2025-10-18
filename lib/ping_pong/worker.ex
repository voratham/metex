defmodule PingPong.Worker do
  def loop do
    receive do
      {sender_pid, _} ->
        send(sender_pid, "Pong message")
    end

    loop()
  end
end
