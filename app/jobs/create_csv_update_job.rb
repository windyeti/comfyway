class CreateCsvUpdateJob < ApplicationJob
  queue_as :default

  def perform
    Services::CreateCsvUpdate.new.call
  end
end
