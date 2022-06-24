class CreateUpdateProductJob < ApplicationJob
  queue_as :default

  def perform
    MaytoniImportJob.perform_later
    MantraImportJob.perform_later
    LightstarImportJob.perform_later
    SwgImportJob.perform_later

    begin
      ElevelImportJob.perform_later
    rescue
      retry
    end

    # Services::GettingProductDistributer::Maytoni.call
    # Services::GettingProductDistributer::Mantra.call
    # Services::GettingProductDistributer::Lightstar.call
    # Services::GettingProductDistributer::Swg.call
    # begin
    #   Services::GettingProductDistributer::Elevel.new.call
    # rescue
    #   retry
    # end
  end
end
