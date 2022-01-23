class IdImportJob < ApplicationJob
  queue_as :default

  def perform
    ActionCable.server.broadcast 'status_process', {distributor: "product", process: "assings_ID_var", status: "start", message: "assings ID var"}

    rows = CSV.read("#{Rails.public_path}/shop.csv", headers: true)

    rows_count = rows.count
    percent = 0
    one_percent = rows_count/100

    rows.each.with_index do |row, index|
      fid = row['Параметр: fid']
      product = Product.find_by(fid: fid)
      if product.present?
        product.update(
                        insales_id: row["ID товара"],
                        insales_var_id: row["ID варианта"],
                        insales_link: row["URL"],
                        insales_images: row["Изображения"],
                        quantity: row["Остаток"]
                        )
        p fid
      end

      new_percent = one_percent*(index*100/rows_count)
      if new_percent >= percent + one_percent
        ActionCable.server.broadcast 'status_process', {distributor: "product", process: "assings_ID_var", status: "progress", percent: new_percent/one_percent}
        percent = new_percent
      end

    end
    ActionCable.server.broadcast 'status_process', {distributor: "product", process: "assings_ID_var", status: "finish", message: "assings ID var"}
  end
end
