class CreateXlsJob < ApplicationJob
  queue_as :default

  def perform(data)
    Services::CreateXlsWithParams.new(data).call
  end
end
