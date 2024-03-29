# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end



# присвоение новым товарам "ID варианта" из инсайлс
# + (хотя это можно не делать, так как все уже есть у товаров) получение в приложение остаков по складам из инсайсл
every 1.day, :at => '07:00' do
  runner "ImportInsalesXmlJob.perform_later"
end

# создание файла апдейта остатков и цен в инсайлс
every 1.day, :at => '07:30' do
  runner "CreateCsvUpdateJob.perform_later"
end

# созданеи параметров в инсайсл для новых товаров
# every 1.day, :at => '08:00' do
#   runner "CreateInsalesParamsJob.perform_later"
# end


# ---------------------------
# создание файлов импорта с новыми товарами поставщиков для инсайлс
every 1.day, :at => '19:00' do
  runner "CreateXlsJob.perform_later(distributor: 'Stluce')"
end

every 1.day, :at => '20:00' do
  runner "CreateXlsJob.perform_later(distributor: 'Maytoni')"
end

# every 1.day, :at => '21:00' do
#   runner "CreateXlsJob.perform_later(distributor: 'Mantra')"
# end

every 1.day, :at => '22:00' do
  runner "CreateXlsJob.perform_later(distributor: 'Lightstar')"
end

every 1.day, :at => '23:00' do
  runner "CreateXlsJob.perform_later(distributor: 'Ledron')"
end

# every 1.day, :at => '00:00' do
#   runner "CreateXlsJob.perform_later(distributor: 'Swg')"
# end

every 1.day, :at => '01:00' do
  runner "CreateXlsJob.perform_later(distributor: 'Elevel')"
end

every 1.day, :at => '02:00' do
  runner "CreateXlsJob.perform_later(distributor: 'Isonex')"
end

every 1.day, :at => '03:00' do
  runner "CreateXlsJob.perform_later(distributor: 'Loftit')"
end

every 1.day, :at => '04:00' do
  runner "CreateXlsJob.perform_later(distributor: 'Favourite')"
end

every 1.day, :at => '05:00' do
  runner "CreateXlsJob.perform_later(distributor: 'Kinklight')"
end

# ---------------------------

# ==============================
# Update Product Distributor
# Ledron -- руками днем
every 1.day, :at => '06:00' do
  runner "CreateUpdateProductJob.perform_later"
end
# ==============================

