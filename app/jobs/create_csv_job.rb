class CreateCsvJob < ApplicationJob
  queue_as :default

  def perform(distributor)
    Services::CreateCsvWithParams.new(distributor).call
  end
end
