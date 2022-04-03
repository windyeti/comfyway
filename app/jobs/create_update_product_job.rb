class CreateUpdateProductJob < ApplicationJob
  queue_as :default

  def perform
    Services::GettingProductDistributer::Elevel.new.call
    # Services::GettingProductDistributer::Maytoni.call
    # Services::GettingProductDistributer::Mantra.call
    # Services::GettingProductDistributer::Lightstar.call
    # Services::GettingProductDistributer::Swg.call
  end
end
