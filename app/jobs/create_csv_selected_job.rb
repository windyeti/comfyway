class CreateCsvSelectedJob < ApplicationJob
  queue_as :default

  def perform(search_id_by_q)
    Services::CsvSelected.call(search_id_by_q)
  end
end
