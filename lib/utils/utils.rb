module Utils
  def replace_semi_to_dot(name, value)
    arr_name = ["Пылевлагозащита, IP", "Световой поток, Лм (для лент Лм&#47;м)"]
    value = if arr_name.include?(name)
      value.remove(/[a-zA-Zа-яА-Я]/)
    else
      if value =~ /^\d+,\d{1,3}/
        value = value =~ /^\d+,\d{1,3}$/ ? value.gsub(/,/, '.') : "999999"
      end
      value
    end
    value
  end
end
