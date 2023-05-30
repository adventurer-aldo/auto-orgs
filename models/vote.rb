class Vote < ActiveRecord::Base
  belongs_to :council, foreign_key: 'council_id'
end