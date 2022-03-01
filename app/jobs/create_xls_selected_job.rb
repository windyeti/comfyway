class CreateXlsSelectedJob < ApplicationJob
  queue_as :default

  def perform(search_id_by_q)
    ActionCable.server.broadcast 'status_process', {distributor: "product", process: "create_xls_selected", status: "start", message: "Создание Xls Selected"}
    Services::XlsSelected.new(search_id_by_q).call
    ActionCable.server.broadcast 'status_process', {distributor: "product", process: "create_xls_selected", status: "finish", message: "Создание Xls Selected"}
  end
end
