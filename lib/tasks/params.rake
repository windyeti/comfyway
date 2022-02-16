namespace :params do
  task maytoni_image_nil: :environment do
    Product.where(distributor: "Maytoni").each do |product|
      product.update(image: nil)
    end
  end

  task maytoni_image: :environment do
    maytoni_shop_rows = CSV.read("#{Rails.public_path}/shop_maytoni.csv", headers: true)

    CSV.open("#{Rails.public_path}/shop_maytoni_image.csv", "a+") do |csv|
      csv << maytoni_shop_rows.first.to_hash.keys
      maytoni_shop_rows.each do |row|
        product = Product.find_by(fid: row['Параметр: fid'])
        row["Изображения"] = product.image if product.present?
        csv << row
      end
    end
  end

  task check_truefalse: :environment do
    rows = CSV.read("#{Rails.public_path}/PRODUCTS.csv", headers: true)
    rows.each do |row|
      row.each do |str|
        p row if str[1].match(/\Strue|\Sfalse|true\S|false\S/)
      end
    end
  end

  task maytoni: :environment do
    MaytoniImportJob.perform_later
  end

  task swg: :environment do
    SwgImportJob.perform_later
  end

  task mantra: :environment do
    MantraImportJob.perform_later
  end

  task lightstar: :environment do
    LightstarImportJob.perform_later
  end

  task ledron: :environment do
    LedronImportJob.perform_later
  end

  task elevel: :environment do
    ElevelImportJob.perform_later
  end
end
