def load_models

  # connect to db
  conf = YAML.load_file('database.yml')
  ActiveRecord::Base.establish_connection(conf['development'])
  
  ActiveRecord::Base.pluralize_table_names = false
  ActiveRecord::Base::default_timezone = :utc
  
  require 'catalog_models/validators'
  require 'catalog_models/models'

end

def get_datasets(project_id)

  Project.find(project_id).datasets.catalog_viewable

  # a list of catalog dataset for this project
  #Dataset.catalog_viewable.find(:all, :conditions => ["archive_ident LIKE ?", "#{project_id}.fc%"])

end

def get_datafiles_by_category(project_id)

  # return hash where key is category and value is list 
  # of file objects for this category
  project_datasets = get_datasets(project_id)

  tmp_hash = Hash.new{|hash, key| hash[key] = Array.new}
  stats_hash = Hash.new{|hash, key| hash[key] = Array.new}

  # loop through each dataset
  project_datasets.each {|d| 
    category = d.categories[0]
    tmp_hash[category.short_name].push(d.datafiles)
  }

  # now flatten since the value of the hash
  # is an array of arrays
  tmp_hash.each {|category,datafile_arr|
    stats_hash[category] = datafile_arr.flatten
  }

  stats_hash

end

def get_categories(project_id)

  # get the available categories for the project
  dataset_arr = get_datasets(project_id)
  
  # arr of categories for the datasets
  category_arr = dataset_arr.map{|dataset| dataset.categories}.flatten
  category_hash = Hash.new

  # return hash where key is category short_name and value is category id 
  category_arr.map{|category| category_hash[category.short_name] = category.id}
  category_hash

end
