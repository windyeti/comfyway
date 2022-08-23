namespace :xls do
  task cell: :environment do
    puts '=====>>>> СТАРТ Isonex XLS '+Time.now.to_s
    Product.where(distributor: "Isonex").each {|tov| tov.update(quantity: 0, check: false)}
    file_path = "#{Rails.root}/public/isonex/isonex.xls"

    file = File.open(file_path)
    xlsx = open_spreadsheet(file)

    rows = []
    xlsx.sheets.each do |sheet_name|
      sheet = xlsx.sheet(sheet_name)
      p headers = sheet.row(1)

      last_row = sheet.last_row

      (2..last_row).each do |i|
        rows << headers.zip(sheet.row(i))
      end
    end
    p rows
    p "====>>> Isonex все продукты импортировались"
  end

  # def open_spreadsheet(file)
  #   case File.extname(file)
  #   when ".csv" then Roo::CSV.new(file.path) #csv_options: {col_sep: ";",encoding: "windows-1251:utf-8"})
  #   when ".xls" then Roo::Excel.new(file.path)
  #   when ".xlsx" then Roo::Spreadsheet.open(file.path, extension: :xlsx)
  #     # when ".xlsx" then Roo::Excelx.new(file.path, extension: :xlsx)
  #   when ".XLS" then Roo::Excel.new(file.path)
  #   else raise "Unknown file type: #{File.extname(file)}"
  #   end
  # end
end
