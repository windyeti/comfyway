class MaytoniImportJob < ApplicationJob
  queue_as :default

  def perform
    ActionCable.server.broadcast 'status_process', {distributor: "maytoni", process: "update_distributor", status: "start", message: "Обновление товаров поставщика Maytoni"}
    Services::GettingProductDistributer::Maytoni.call
    ActionCable.server.broadcast 'status_process', {distributor: "maytoni", process: "update_distributor", status: "finish", message: "Обновление товаров поставщика Maytoni"}
  end
end
