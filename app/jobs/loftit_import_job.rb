class LoftitImportJob < ApplicationJob
  queue_as :default

  def perform
    ActionCable.server.broadcast 'status_process', {distributor: "loftit", process: "create_distributor", status: "start", message: "Создание новых товаров поставщика Loftit"}
    Services::GettingProductDistributer::Loftit.call
    ActionCable.server.broadcast 'status_process', {distributor: "loftit", process: "create_distributor", status: "finish", message: "Создание новых товаров поставщика Loftit"}
  end
end
