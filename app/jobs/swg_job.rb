class SwgJob < ApplicationJob
  queue_as :default

  def perform
    Services::GettingProductDistributer::Swg
  end
end
