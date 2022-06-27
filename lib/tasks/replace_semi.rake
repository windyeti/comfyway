namespace :replace_semi do
  task elevel: :environment do
    require 'utils'
    include Utils

    ["Arlight", "Arte Lamp", "Evoluce", "Favourite", "F-PROMO", "Kink Light", "Lumion",
     "Novotech", "Odeon Light", "Divinare", "Loft It", "St Luce",
     "ABB", "Schneider Electric", "Legrand"].each do |brand|

      file_path = "#{Rails.public_path}/replace/#{brand}_semi.html"

      FileUtils.rm_rf(Dir.glob(file_path))

      File.open(file_path, "a+") do |f|
        count = 0
        f.write "<html><head><style>.title {font-weight: 600; padding-right: 10px}span {display: inline-block; padding: 10px}.change {background: red}</style></head><body>"

        str_brand = "Бренд: #{brand}"
        products = Product.where(distributor: "Elevel").select do |product|
          product.p1.split(" --- ").include?(str_brand)
        end

        p products.count

        products.each do |product|
          title = product.title
          f.write "<p><span class='title'>#{title}</span>"

          product.p1.split(" --- ").each do |param|
            arr_param = param.split(": ")
            name = arr_param[0]
            value = arr_param[1]
            new_value = replace_semi_to_dot(name, value)

            if new_value == value
              f.write "<span>#{name}: #{value}</span>"
            else
              f.write "<span class='change'>#{name}: <span>было: #{value}</span><span>стало: #{new_value}</span></span>"
            end
          end
          f.write "</p>"
          p count += 1
        end
        f.write "</body></html>"
      end
    end

  end
  task distr: :environment do
    require 'utils'
    include Utils

    ["Maytoni", "Mantra", "Lightstar", "Ledron", "Swg"].each do |distr|

      file_path = "#{Rails.public_path}/replace/#{distr}_semi.html"

      FileUtils.rm_rf(Dir.glob(file_path))

      File.open(file_path, "a+") do |f|
        count = 0
        f.write "<html><head><style>.title {font-weight: 600; padding-right: 10px}span {display: inline-block; padding: 10px}.change {background: red}</style></head><body>"

        products = Product.where(distributor: distr)

        p products.count

        products.each do |product|
          title = product.title
          f.write "<p><span class='title'>#{title}</span>"

          product.p1.split(" --- ").each do |param|
            arr_param = param.split(": ")
            name = arr_param[0]
            value = arr_param[1]
            new_value = replace_semi_to_dot(name, value)

            if new_value == value
              f.write "<span>#{name}: #{value}</span>"
            else
              f.write "<span class='change'>#{name}: <span>было: #{value}</span><span>стало: #{new_value}</span></span>"
            end
          end
          f.write "</p>"
          p count += 1
        end
        f.write "</body></html>"
      end
    end

  end

  task every: :environment do
    require 'utils'
    include Utils
    count = 0
    p time_start = Time.now

    Product.find_each do |product|

      arr_params = product.p1.split(" --- ")
      new_arr_params = arr_params.map do |param|
        arr_param = param.split(": ")
        name = arr_param[0]
        value = arr_param[1]
        new_value = replace_semi_to_dot(name, value)
        "#{name}: #{new_value}" if new_value.present?
      end.compact
      product.update(p1: new_arr_params.join(" --- "))
      p count += 1
    end
    p count
    p time_start
  end
end
