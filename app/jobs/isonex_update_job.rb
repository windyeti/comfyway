class IsonexUpdateJob < ApplicationJob
  queue_as :default

  def perform
    ActionCable.server.broadcast 'status_process', {distributor: "isonex", process: "update_distributor", status: "start", message: "Обновление товаров поставщика Isonex"}
    Services::GettingProductDistributer::IsonexUpdate.call
    ActionCable.server.broadcast 'status_process', {distributor: "isonex", process: "update_distributor", status: "finish", message: "Обновление товаров поставщика Isonex"}
  end
end
