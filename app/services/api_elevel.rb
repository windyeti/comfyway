class Services::ApiElevel
  def self.call(url, auth, payload)
    RestClient.post( url, payload.to_json, :accept => :json, :content_type => "application/json", :Authorization => auth) do |response, request, result, &block|
      case response.code
      when 200
        puts 'Okey'
        JSON.parse(response.body)
      when 422
        puts "error 422 - не добавили категорию"
        puts response
      when 404
        puts 'error 404'
        puts response
      when 503
        puts 'error 503'
      else
        puts 'UNKNOWN ERROR'
      end
    end
  end
end
