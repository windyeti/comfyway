namespace :work do
  task maytoni: :environment do
    # MaytoniImportJob.perform_later
    Services::GettingProductDistributer::Maytoni.call
  end

  task swg: :environment do
    SwgImportJob.perform_later
  end

  task mantra: :environment do
    MantraImportJob.perform_later
  end

  task lightstar: :environment do
    LightstarImportJob.perform_later
  end

  # task ledron: :environment do
  #   LedronImportJob.perform_later
  # end

  task elevel: :environment do
    # Services::GettingProductDistributer::Elevel.new.call

    ElevelImportJob.perform_later
  end

  task xls: :environment do
    Services::CreateXlsWithParams.new(distributor: "Swg").call
  end

  task update_params: :environment do
    CreateInsalesParamsJob.perform_later
  end

  task assings_id_var: :environment do
    IdImportJob.perform_later
  end

  task test_maytoni: :environment do
    CreateXlsJob.perform_later(distributor: 'Maytoni', deactivated: false, insales_var_id: nil)
  end
end
