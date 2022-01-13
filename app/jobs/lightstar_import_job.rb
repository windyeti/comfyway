class LightstarImportJob < ApplicationJob
  queue_as :default

  def perform
    ActionCable.server.broadcast 'status_process', {distributor: "lightstar", process: "update_distributor", status: "start", message: "Обновление товаров поставщика Lightstar"}
    Services::GettingProductDistributer::Lightstar.call
    ActionCable.server.broadcast 'status_process', {distributor: "lightstar", process: "update_distributor", status: "finish", message: "Обновление товаров поставщика Lightstar"}
  end
end
