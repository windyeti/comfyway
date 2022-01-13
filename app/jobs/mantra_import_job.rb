class MantraImportJob < ApplicationJob
  queue_as :default

  def perform
    ActionCable.server.broadcast 'status_process', {distributor: "mantra", process: "update_distributor", status: "start", message: "Обновление товаров поставщика Mantra"}
    Services::GettingProductDistributer::Mantra.call
    ActionCable.server.broadcast 'status_process', {distributor: "mantra", process: "update_distributor", status: "finish", message: "Обновление товаров поставщика Mantra"}
  end
end
