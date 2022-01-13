class SwgImportJob < ApplicationJob
  queue_as :default

  def perform
    ActionCable.server.broadcast 'status_process', {distributor: "Swg", process: "update_distributor", status: "start", message: "Обновление товаров поставщика Swg"}
    Services::GettingProductDistributer::Swg.call
    ActionCable.server.broadcast 'status_process', {distributor: "Swg", process: "update_distributor", status: "finish", message: "Обновление товаров поставщика Swg"}
  end
end
