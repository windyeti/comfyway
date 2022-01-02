class CreateUpdateProductJob < ApplicationJob
  queue_as :default

  def perform
    MaytoniImportJob.perform_later
    MantraImportJob.perform_later
    LightstarImportJob.perform_later
    SwgJob.perform_later
    ElevelImportJob.perform_later
  end
end
