class ImportInsalesXmlJob < ApplicationJob
  queue_as :default

  def perform
    Services::ImportInsalesXml.call
  end
end
