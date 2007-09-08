class User < ActiveRecord::Base
    has_many :addresses
end
