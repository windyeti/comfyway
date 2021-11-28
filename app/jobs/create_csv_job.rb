class CreateCsvJob < ApplicationJob
  queue_as :default

  def perform
    Services::CreateCsvWithParams.call
  end
end
