class LedronImportJob < ApplicationJob
  queue_as :default

  def perform(path_file, extend_file)
    Services::GettingProductDistributer::Ledron.call(path_file, extend_file)
    ActionCable.server.broadcast 'status_process', {distributor: "ledron", process: "update_distributor", status: "finish", message: "Обновление товаров поставщика Ledron"}
  end
end
