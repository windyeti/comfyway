class LedronImportJob < ApplicationJob
  queue_as :default

  def perform(path_file, extend_file)
    Services::GettingProductDistributer::Ledron.call(path_file, extend_file)
    ActionCable.server.broadcast 'state_process', {distributor: "Ledron", state: "finish", message: "Закончен процесс импорта товаров Ledron"}
  end
end
