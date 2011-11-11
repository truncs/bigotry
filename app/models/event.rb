class Event < ActiveRecord::Base
    has_many :articles
    has_many :sources, :through => :articles
end
