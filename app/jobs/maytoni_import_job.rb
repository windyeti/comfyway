class MaytoniImportJob < ApplicationJob
  queue_as :default

  def perform
    Services::GettingProductDistributer::Maytoni.call
  end
end
