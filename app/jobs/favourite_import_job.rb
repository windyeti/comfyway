class FavouriteImportJob < ApplicationJob
  queue_as :default

  def perform
    ActionCable.server.broadcast 'status_process', {distributor: "favourite", process: "create_distributor", status: "start", message: "Создание новых товаров поставщика Favourite"}
    Services::GettingProductDistributer::Favourite.call
    ActionCable.server.broadcast 'status_process', {distributor: "favourite", process: "create_distributor", status: "finish", message: "Создание новых товаров поставщика Favourite"}
  end
end
