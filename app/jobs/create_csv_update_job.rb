class CreateCsvUpdateJob < ApplicationJob
  queue_as :default

  def perform
    ActionCable.server.broadcast 'status_process', {distributor: "product", process: "update_price_quantity", status: "start", message: "Создание Csv update Цен и Остатков"}
    Services::CreateCsvUpdate.new.call
    ActionCable.server.broadcast 'status_process', {distributor: "product", process: "update_price_quantity", status: "finish", message: "Создание Csv update Цен и Остатков"}
  end
end
