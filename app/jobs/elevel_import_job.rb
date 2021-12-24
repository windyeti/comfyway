class ElevelImportJob < ApplicationJob
  queue_as :default

  def perform
    Services::GettingProductDistributer::Elevel.new.call
  end
end
