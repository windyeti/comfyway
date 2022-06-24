module Utils
  def replace_semi_to_dot(value)
    if value =~ /^\d+,\d{1,3}/
      value = value =~ /^\d+,\d{1,3}$/ ? value.gsub(/,/, '.') : "999999"
    end
    value
  end
end
