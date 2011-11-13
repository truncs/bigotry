class Article < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 10
  has_many :events
  has_many :sources
end
