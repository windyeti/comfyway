class CreateXlsJob < ApplicationJob
  queue_as :default

  def perform(distributor)
    Services::CreateXlsWithParams.new(distributor).call
  end
end
