class AddLinksToConcerts < ActiveRecord::Migration
  def change
  	add_column :concerts, :link, :string
  end
end
