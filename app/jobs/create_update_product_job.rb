class CreateUpdateProductJob < ApplicationJob
  queue_as :default

  def perform
    MaytoniImportJob.perform_later
    # MantraImportJob.perform_later
    LightstarImportJob.perform_later
    # SwgImportJob.perform_later

    begin
      ElevelImportJob.perform_later
    rescue
      retry
    end

    IsonexUpdateJob.perform_later

    LoftitImportJob.perform_later
    FavouriteImportJob.perform_later
    KinklightImportJob.perform_later
  end
end
