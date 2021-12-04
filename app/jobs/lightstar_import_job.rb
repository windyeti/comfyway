class LightstarImportJob < ApplicationJob
  queue_as :default

  def perform
    Services::GettingProductDistributer::Lightstar.call
  end
end
