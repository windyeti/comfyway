class CreateXlsJob < ApplicationJob
  queue_as :default

  def perform(data)
    ActionCable.server.broadcast 'status_process',
                                 {
                                  distributor: data[:distributor],
                                  process: "create_xls_distributor",
                                  status: "start",
                                  message: "Создание Xls для импорта новых товаров #{data[:distributor]}"
                                 }

    Services::Xls::Distributor.new(data).call

    ActionCable.server.broadcast 'status_process',
                                 {
                                  distributor: data[:distributor],
                                  process: "create_xls_distributor",
                                  status: "finish",
                                  message: "Создание Xls для импорта новых товаров #{data[:distributor]}"
                                 }
  end
end
