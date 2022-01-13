class ElevelImportJob < ApplicationJob
  queue_as :default

  def perform
    ActionCable.server.broadcast 'status_process', {distributor: "elevel", process: "update_distributor", status: "start", message: "Обновление товаров поставщика Elevel"}
    Services::GettingProductDistributer::Elevel.new.call
    ActionCable.server.broadcast 'status_process', {distributor: "elevel", process: "update_distributor", status: "finish", message: "Обновление товаров поставщика Elevel"}
  end
end
