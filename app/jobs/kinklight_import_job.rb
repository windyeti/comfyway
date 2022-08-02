class KinklightImportJob < ApplicationJob
  queue_as :default

  def perform
    ActionCable.server.broadcast 'status_process', {distributor: "kinklight", process: "create_distributor", status: "start", message: "Создание новых товаров поставщика Kinklight"}
    Services::GettingProductDistributer::Kinklight.call
    ActionCable.server.broadcast 'status_process', {distributor: "kinklight", process: "create_distributor", status: "finish", message: "Создание новых товаров поставщика Kinklight"}
  end
end
