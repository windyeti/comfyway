class CreateInsalesParamsJob < ApplicationJob
  queue_as :default

  def perform
    ActionCable.server.broadcast 'status_process', {distributor: "product", process: "update_params", status: "start", message: "Обновление параметров товаров в InSales"}
    Services::CreateInsalesParams.call
    ActionCable.server.broadcast 'status_process', {distributor: "product", process: "update_params", status: "finish", message: "Обновление параметров товаров в InSales"}
  end
end
