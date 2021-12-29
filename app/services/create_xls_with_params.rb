class Services::CreateXlsWithParams
  PRODUCT_STRUCTURE = {
    fid: 'Параметр: fid',
    sku: 'Артикул',
    title: 'Название товара',
    desc: 'Полное описание',
    sdesc: 'Краткое описание',
    price: 'Цена продажи',
    purchase_price: 'Цена закупки',
    oldprice: 'Старая цена',
    quantity: 'Остаток',
    image: 'Изображения',
    distributor: 'Дополнительное поле: Поставщик',
    vendor: 'Дополнительное поле: Производитель',
    manual: 'Дополнительное поле: Инструкция',
    manuals: 'Дополнительное поле: Инструкции',
    preview_3d: 'Дополнительное поле: 3D preview',
    foto: 'Дополнительное поле: Фото',
    draft: 'Дополнительное поле: Чертёж',
    model_3d: 'Дополнительное поле: 3D-модель',
    date_arrival: 'Дополнительное поле: Ожидается',
    quantity_add: 'Дополнительное поле: Склад',
    video: 'Ссылка на видео',
    url: 'Параметр: OLDLINK',
    barcode: 'Штрих-код',
    weight: 'Вес',
    currency: 'Валюта склада',
    cat: 'Корневая',
    cat1: 'Подкатегория 1',
    cat2: 'Подкатегория 2',
    cat3: 'Подкатегория 3',
    cat4: 'Подкатегория 4',
    mtitle: 'Тег title',
    mdesc: 'Мета-тег description',
    mkeywords: 'Мета-тег keywords',
  }.freeze

  def initialize(distributor = 'all')
    @distributor = distributor
  end

  def call
    @file_path_prep = "#{Rails.public_path}/product_#{@distributor}_prep.csv"
    @file_path_prep_xls = "#{Rails.public_path}/product_#{@distributor}_prep_xls.xls"
    @file_name_output = "#{Rails.public_path}/product_#{@distributor}_output.xls"

    if @distributor == 'all'
      @tovs = Product.order(:id)
    else
      @tovs = Product.where(distributor: @distributor).order(:id)
    end

    check_previous_files_csv

    create_csv_prep(PRODUCT_STRUCTURE)

    additions_headers = get_additions_headers

    product_hashs = get_product_hashs

    all_column_names = add_column_names(product_hashs, additions_headers)

    csv_with_full_headers(product_hashs, all_column_names)

    # create_xls_output
  end



  private

  def check_previous_files_csv
    check = File.file?("#{@file_path_prep}")
    if check.present?
      File.delete("#{@file_path_prep}")
    end
    check = File.file?("#{@file_path_output}")
    if check.present?
      File.delete("#{@file_path_output}")
    end
  end

  def create_csv_prep(product_hash_structure)
    CSV.open(@file_path_prep, 'w') do |writer|
      writer << product_hash_structure.values

      @tovs.each do |tov|
        product_properties = product_hash_structure.keys
        product_properties_amount = product_properties.map do |property|
          tov.send(property)
        end
        writer << product_properties_amount
      end
    end
  end

  def get_additions_headers
    result = []
    p = @tovs.select(:p1)
    p.each do |p|
      if p.p1 != nil
        p.p1.split(' --- ').each do |pa|
          result << pa.split(':')[0].strip if pa != nil
        end
      end
    end
    result.uniq
  end

  def get_product_hashs
    CSV.read(@file_path_prep, headers: true).map do |product|
      product.to_hash
    end
  end

  def add_column_names(product_hashs, addHeaders)
    result = []
    column_names = product_hashs.first.keys
    result += column_names
    addHeaders.each do |addH|
      additional_column_names = ['Параметр: '+addH]
      result += additional_column_names
    end
    result
  end

  def csv_with_full_headers(product_hashs, all_column_names)
    book = Spreadsheet::Workbook.new

    sheet = book.create_worksheet
    sheet.row(0).push(all_column_names)

    product_hashs.each.with_index(1) do |product_hash, index|
      sheet.row(index).push(product_hash)
    end

    book.write @file_path_prep_xls

  end

  def create_xls_output
    book = Spreadsheet::Workbook.new

    rows = CSV.read(@file_path_prep, headers: true).collect do |row|
      row.to_hash
    end
    sheet = book.create_worksheet
    headers = rows.first.keys
    sheet.row(0).push(headers)

    rows.each_with_index do |row, index|
      row_hash = Hash[headers.zip(row.value)]
    end

    CSV.open(@file_name_output, "w") do |csv_out|
      column_names = rows.first.keys
      csv_out << column_names
      CSV.foreach(@file_path_prep, headers: true ) do |row|
        fid = row[0]
        vel = Product.find_by_fid(fid)
        if vel != nil
# 				puts vel.id
          if vel.p1.present? # Вид записи должен быть типа - "Длина рамы: 20 --- Ширина рамы: 30"
            vel.p1.split('---').each do |vp|
              key = 'Параметр: '+vp.split(':')[0].strip
              value = vp.split(':')[1] if vp.split(':')[1] !=nil
              row[key] = value
            end
          end
        end
        csv_out << row
      end
    end
  end

  def create_csv_output
    CSV.open(@file_name_output, "w") do |csv_out|
      rows = CSV.read(@file_path_prep, headers: true).collect do |row|
        row.to_hash
      end
      column_names = rows.first.keys
      csv_out << column_names
      CSV.foreach(@file_path_prep, headers: true ) do |row|
        fid = row[0]
        vel = Product.find_by_fid(fid)
        if vel != nil
# 				puts vel.id
          if vel.p1.present? # Вид записи должен быть типа - "Длина рамы: 20 --- Ширина рамы: 30"
            vel.p1.split('---').each do |vp|
              key = 'Параметр: '+vp.split(':')[0].strip
              value = vp.split(':')[1] if vp.split(':')[1] !=nil
              row[key] = value
            end
          end
        end
        csv_out << row
      end
    end
  end
end
