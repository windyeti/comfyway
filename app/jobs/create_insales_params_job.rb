class CreateInsalesParamsJob < ApplicationJob
  queue_as :default

  def perform
    Services::CreateInsalesParams.call
  end
end
