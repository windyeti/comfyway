class StluceImportJob < ApplicationJob
  queue_as :default

  def perform
    ActionCable.server.broadcast 'status_process', {distributor: "stluce", process: "create_distributor", status: "start", message: "Создание новых товаров поставщика St Luce"}
    Services::GettingProductDistributer::Stluce.call
    ActionCable.server.broadcast 'status_process', {distributor: "stluce", process: "create_distributor", status: "finish", message: "Создание новых товаров поставщика St Luce"}
  end
end
