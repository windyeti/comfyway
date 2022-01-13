class CreateCsvSelectedJob < ApplicationJob
  queue_as :default

  def perform(search_id_by_q)
    ActionCable.server.broadcast 'status_process', {distributor: "product", process: "create_csv_selected", status: "start", message: "Создание Csv Selected"}
    Services::CsvSelected.call(search_id_by_q)
    ActionCable.server.broadcast 'status_process', {distributor: "product", process: "create_csv_selected", status: "finish", message: "Создание Csv Selected"}
  end
end
