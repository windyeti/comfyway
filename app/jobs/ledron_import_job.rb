class LedronImportJob < ApplicationJob
  queue_as :default

  def perform(path_file, extend_file)
    ActionCable.server.broadcast 'state_process', {state: "start", message: "Запущен процесс импорта товаров Ledron"}
    Services::GettingProductDistributer::Ledron.call(path_file, extend_file)
    ActionCable.server.broadcast 'state_process', {state: "finish", message: "Закончен процесс импорта товаров Ledron"}
  end
end
