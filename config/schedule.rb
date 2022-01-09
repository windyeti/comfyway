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


# создание и апдейт товаров поставщиков
# every 1.day, :at => '21:30' do
#   runner "CreateUpdateProductJob.perform_later"
# end

# созданеи параметров в инсайсл для новых товаров
every 1.day, :at => '21:30' do
  runner "CreateInsalesParamsJob.perform_later"
end

# создание файлов импорта с новыми товарами поставщиков для инсайлс
# every 1.day, :at => '20:00' do
#   runner "CreateXlsJob.perform_later(distributor: 'Maytoni')"
# end
#
# every 1.day, :at => '22:00' do
#   runner "CreateXlsJob.perform_later(distributor: 'Mantra')"
# end
#
# every 1.day, :at => '00:00' do
#   runner "CreateXlsJob.perform_later(distributor: 'Lightstar')"
# end
#
# every 1.day, :at => '02:00' do
#   runner "CreateXlsJob.perform_later(distributor: 'Ledron')"
# end

every 1.day, :at => '12:00' do
  runner "CreateXlsJob.perform_later(distributor: 'Swg')"
end
#
# every 1.day, :at => '06:00' do
#   runner "CreateXlsJob.perform_later(distributor: 'Elevel')"
# end

# создание файла апдейта остатков и цен в инсайлс
every 1.day, :at => '06:00' do
  runner "CreateCsvUpdateJob.perform_later"
end

# присвоение новым товарам "ID варианта" из инсайлс
# + (хотя это можно не делать, так как все уже есть у товаров) получение в приложение остаков по складам из инсайсл
every 1.day, :at => '07:00' do
  runner "ImportInsalesXmlJob.perform_later"
end
