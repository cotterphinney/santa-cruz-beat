class CreateConcerts < ActiveRecord::Migration
 def self.up
   create_table :concerts do |t|
     t.string :title
     t.datetime :date
     t.string :venue
     t.timestamps
   end
 end

 def self.down
   drop_table :concerts
 end
end
