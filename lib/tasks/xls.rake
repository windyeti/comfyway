namespace :xls do
  task cell: :environment do
    puts '=====>>>> СТАРТ Isonex XLS '+Time.now.to_s
    Product.where(distributor: "Isonex").each {|tov| tov.update(quantity: 0, check: false)}
    # FileUtils.rm_rf(Dir.glob('public/isonex.xls'))

    file_path = "#{Rails.root}/public/isonex.xls"

    file = File.open(file_path)

    xlsx = open_spreadsheet(file)

    xlsx.sheets.each do |sheet_name|
      sheet = xlsx.sheet(sheet_name)
      p headers = sheet.row(1)

      last_row = sheet.last_row

      # (1..last_row).each do |i|
      #   p sheet.row(i)
      #   # p first_cell = sheet.cell(i, 'A')
      #   # next unless first_cell.to_i.to_s == first_cell
      #   # data = {
      #   #   barcode: sheet.cell(i, 'A'),
      #   #   vendorcode: sheet.cell(i, 'B'),
      #   #   title: sheet.cell(i, 'D'),
      #   #   weight: sheet.cell(i, 'F'),
      #   #   quantity: sheet.cell(i, 'G'),
      #   #   use_until: sheet.cell(i, 'H'),
      #   #   price: sheet.cell(i, 'J') ? sheet.cell(i, 'J').to_s.gsub(' ', '').to_f : nil,
      #   #   desc: sheet.cell(i, 'O'),
      #   #   check: true
      #   # }
      #   #
      #   # ashanti = Ashanti
      #   #             .find_by(vendorcode: data[:vendorcode])
      #   #
      #   # ashanti.present? ? ashanti.update(data) : Ashanti.create(data)
      # end
      p "====>>> Isonex все продукты импортировались"
    end
  end

  def open_spreadsheet(file)
    case File.extname(file)
    when ".csv" then Roo::CSV.new(file.path) #csv_options: {col_sep: ";",encoding: "windows-1251:utf-8"})
    when ".xls" then Roo::Excel.new(file.path)
    when ".xlsx" then Roo::Spreadsheet.open(file.path, extension: :xlsx)
      # when ".xlsx" then Roo::Excelx.new(file.path, extension: :xlsx)
    when ".XLS" then Roo::Excel.new(file.path)
    else raise "Unknown file type: #{File.extname(file)}"
    end
  end
end
