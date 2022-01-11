class Services::CsvSelected
  def self.call(product_ids)

    file = "#{Rails.root}/public/pre_products_selected.csv"
    new_file = Rails.public_path.to_s + '/product_selected.csv'

    check = File.file?(file)
    File.delete(file) if check.present?

    check = File.file?(new_file)
    File.delete(new_file) if check.present?

    # создаём файл со статичными данными
    @tovs = Product.where(id: product_ids).order(:id)

    CSV.open(file, 'w') do |writer|
      headers = ['fid', 'Артикул', 'Название товара', 'Полное описание', 'Производитель', 'Цена продажи', 'Цена старая',
                 'Остаток', 'Изображения', 'Url', 'Подкатегория 1', 'ID товара в InSales', 'ID варианта товара в InSales']

      writer << headers
      @tovs.each do |pr|
        next if pr.title.nil?

        fid = pr.id
        sku = pr.sku
        title = pr.title
        desc = pr.desc
        distributor = pr.distributor
        price = pr.price
        oldprice = pr.oldprice
        quantity = pr.quantity
        image = pr.image
        url = pr.url
        cat = pr.cat
        insales_id = pr.insales_id
        insales_var_id = pr.insales_var_id

        writer << [fid, sku, title, desc, distributor, price, oldprice, quantity, image, url, cat, insales_id, insales_var_id]
      end
    end

    # параметры в таблице записаны в виде - "Состояние: новый --- Вид: квадратный --- Объём: 3л --- Радиус: 10м"
    # дополняем header файла названиями параметров

    vparamHeader = []
    p = @tovs.select(:p1)
    p.each do |p|
      next if p.p1.nil?

      p.p1.split('---').each do |pa|
        vparamHeader << pa.split(':')[0].strip unless pa.nil?
      end
    end
    addHeaders = vparamHeader.uniq

    # Load the original CSV file
    rows = CSV.read(file, headers: true).collect do |row|
      row.to_hash
    end
    # puts check_property_use.to_s

    # Original CSV column headers
    column_names = rows.first.keys
    # Array of the new column headers
    addHeaders.each do |addH|

      additional_column_names = ['Параметр: ' + addH]
      # Append new column name(s)
      column_names += additional_column_names
      s = CSV.generate do |csv|
        csv << column_names
        rows.each do |row|
          # Original CSV values
          values = row.values
          # Array of the new column(s) of data to be appended to row
          # 				additional_values_for_row = ['1']
          # 				values += additional_values_for_row
          csv << values
        end
      end
      File.open(file, 'w') { |file| file.write(s) }
    end
    # Overwrite csv file

    # заполняем параметры по каждому товару в файле

    CSV.open(new_file, 'w') do |csv_out|
      rows = CSV.read(file, headers: true).collect do |row|
        row.to_hash
      end
      column_names = rows.first.keys
      csv_out << column_names
      CSV.foreach(file, headers: true) do |row|
        fid = row[0]
        # puts fid
        vel = Product.find_by_id(fid)
        if !vel.nil? && vel.p1.present? # Вид записи должен быть типа - "Длина рамы: 20 --- Ширина рамы: 30"
          vel.p1.split('---').each do |vp|
            key = 'Параметр: ' + vp.split(':')[0].strip
            value = vp.split(':')[1].remove('.') unless vp.split(':')[1].nil?
            row[key] = value
          end
        end
        csv_out << row
      end
    end
    # current_process = "создаём файл csv_param"
    # CaseMailer.notifier_process(current_process).deliver_now
  end
end
