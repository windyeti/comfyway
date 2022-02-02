class Services::CreateInsalesParams
  def self.call
    puts 'start'
    vparamHeader = []
    p = Product.all.select(:p1)
    p.each do |p|
      if p.p1 != nil
        p.p1.split(' --- ').each do |pa|
          vparamHeader << pa.split(':')[0].strip if pa != nil
        end
      end
    end
    values = vparamHeader.uniq
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
        puts response.code
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
end
