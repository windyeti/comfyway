class Services::CreateInsalesParams
  def self.call
    puts 'start'

    values = get_additions_headers
    # values = ["fid", "OLDLINK"]
    values.each do |value|
      puts "параметр - "+"#{value}"
      url = "http://#{Rails.application.credentials[:shop][:api_key]}:#{Rails.application.credentials[:shop][:password]}@#{Rails.application.credentials[:shop][:domain]}/admin/properties.json"
      data = 	{
        "property":
          {
            "title": "#{value}"
          }
      }

      RestClient.post( url, data.to_json, {:content_type => 'application/json', accept: :json}) { |response, request, result, &block|
        # puts response.code
        case response.code
        when 201
          puts 'sleep 0.2-201 - сохранили'
          File.open("#{Rails.public_path}/new_params.txt", "a+") do |f|
            f.write "#{value} - #{Time.now}\n"
          end
        when 422
          puts '422'
        else
          response.return!(&block)
        end
      }
      sleep 1
    end
    puts 'finish'
  end

  def self.get_additions_headers
    params = CSV.read("#{Rails.public_path}/map_params.csv", headers: true).map { |row| row["Название"].gsub("/", "&#47;") if row["Название"].present? }.uniq.compact
    exclude = ["Наименование", "Артикул", "Цена", "Валюта", "Остаток", "Краткое описание", "url", "ID артикула",
               "Ссылка на витрину", "Адрес видео на YouTube или Vimeo", "Закупочная цена", "Изображения товаров",  "Штрихкод"]
    result = params - exclude
    result
  end
end
