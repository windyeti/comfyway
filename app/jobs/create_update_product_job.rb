class CreateUpdateProductJob < ApplicationJob
  queue_as :default

  def perform

    LightstarImportJob.perform_later
    # SwgImportJob.perform_later

    IsonexUpdateJob.perform_later

    LoftitImportJob.perform_later
    FavouriteImportJob.perform_later
    KinklightImportJob.perform_later
    StluceImportJob.perform_later

    begin
      ElevelImportJob.perform_later
    rescue
      retry
    end
    MaytoniImportJob.perform_later
    # MantraImportJob.perform_later
  end
end
