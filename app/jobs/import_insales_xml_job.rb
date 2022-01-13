class ImportInsalesXmlJob < ApplicationJob
  queue_as :default

  def perform
    ActionCable.server.broadcast 'status_process', {distributor: "product", process: "update_product", status: "start", message: "Обновление товаров из InSales"}
    Services::ImportInsalesXml.call
    ActionCable.server.broadcast 'status_process', {distributor: "product", process: "update_product", status: "finish", message: "Обновление товаров из InSales"}
  end
end
