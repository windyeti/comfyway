class CreateUpdateProductJob < ApplicationJob
  queue_as :default

  def perform
    Services::GettingProductDistributer::Maytoni.call
    # MaytoniImportJob.perform_later
    #
    Services::GettingProductDistributer::Mantra.call
    # MantraImportJob.perform_later
    Services::GettingProductDistributer::Lightstar.call
    # LightstarImportJob.perform_later
    #
    Services::GettingProductDistributer::Swg.call
    # SwgImportJob.perform_later

    Services::GettingProductDistributer::Elevel.new.call
    # ElevelImportJob.perform_later
  end
end
