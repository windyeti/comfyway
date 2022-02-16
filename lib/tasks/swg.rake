namespace :swg do
  task read: :environment do
    test_csv = "#{Rails.root.join('public', 'test.csv')}"
    download_link = "https://swgshop.ru/upload/swgshop_export_full.csv"
    File.open(test_csv, 'w') do |f|
      block = proc do |response|
        body = response.body.force_encoding("UTF-8").gsub!("\r", '').gsub!(/"/, "")
        f.write body
      end
      RestClient::Request.new(method: :get, url: download_link, block_response: block).execute
    end

    rows = CSV.read(test_csv.encoding, headers: true, quote_char: "\x00" )
    # rows = CSV.read(test_csv )
    CSV.open("#{Rails.public_path}/test_swg2.csv", "w+") do |csv|
      csv << rows.first.to_hash.keys
      csv << rows.first
      rows.each do |row|
        p row
        csv << row
      end
    end
  end
end
