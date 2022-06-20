class CreateUpdateProductJob < ApplicationJob
  queue_as :default

  def perform
    Services::GettingProductDistributer::Maytoni.call
    Services::GettingProductDistributer::Mantra.call
    Services::GettingProductDistributer::Lightstar.call
    Services::GettingProductDistributer::Swg.call
    begin
      Services::GettingProductDistributer::Elevel.new.call
    rescue
      retry
    end
  end
end
