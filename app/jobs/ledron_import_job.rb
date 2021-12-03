class LedronImportJob < ApplicationJob
  queue_as :default

  def perform(path_file, extend_file)
    Services::GettingProductDistributer::Ledron.call(path_file, extend_file)
  end
end
