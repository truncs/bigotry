require 'yaml'
module ArticlesHelper
  def daylife_helper
    raw_config = File.read(RAILS_ROOT + "/config/daylife.yml")
    daylife_config = YAML.load(raw_config)[RAILS_ENV]
    Daylife::API.new(daylife_config[:api_key],DAYLIFE_CONFIG[:sharedsecret]) 
  end
end
