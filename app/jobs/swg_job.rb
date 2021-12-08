class SwgJob < ApplicationJob
  queue_as :default

  def perform
    Services::GettingProductDistributer::Swg.call
  end
end
