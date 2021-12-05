class NotificationChannel < ApplicationCable::Channel
  def follow
    stream_from "state_process"
  end
end
