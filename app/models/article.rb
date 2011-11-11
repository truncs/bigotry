class Article < ActiveRecord::Base
    has_many :events
    has_many :sources
end
