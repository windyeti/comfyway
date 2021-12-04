class MantraImportJob < ApplicationJob
  queue_as :default

  def perform
    Services::GettingProductDistributer::Mantra.call
  end
end
