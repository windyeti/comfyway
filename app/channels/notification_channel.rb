class NotificationChannel < ApplicationCable::Channel
  def follow
    stream_from "status_process"
  end
end
