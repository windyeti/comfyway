class IsonexImportJob < ApplicationJob
  queue_as :default

  def perform(uploaded_io, extend_file)
    Services::GettingProductDistributer::IsonexCreate.call(uploaded_io, extend_file)
    ActionCable.server.broadcast 'status_process', {distributor: "isonex", process: "update_distributor", status: "finish", message: "Обновление товаров поставщика Isonex"}
  end
end
