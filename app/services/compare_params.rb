class Services::CompareParams
  attr_reader :file_path_prep, :name_provider

  def initialize(name_provider)
    @name_provider = name_provider
    @file_path_prep = "#{Rails.root.join("public", "map_params.csv")}"
  end

  def compare(param)
    @map_params ||= get_map_params
    result = @map_params[param]
    result.present? ? result : param
  end

  private

  def get_map_params
    map_params = {}
    CSV.read(file_path_prep, headers: true).map do |row|
      hash = row.to_hash
      map_params[hash[name_provider]] = hash["Название"]
    end
    map_params
  end
end
