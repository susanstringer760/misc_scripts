def load_models

  # connect to db
  conf = YAML.load_file('database.yml')
  ActiveRecord::Base.establish_connection(conf['development'])
  
  ActiveRecord::Base.pluralize_table_names = false
  ActiveRecord::Base::default_timezone = :utc
  
  require 'catalog_models/validators'
  require 'catalog_models/models'

end

def get_categories

  Category.find(28)

end
