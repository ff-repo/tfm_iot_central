class AddDescriptionToBotTracks < ActiveRecord::Migration[7.2]
  def change
    add_column :bot_tracks, :description, :string
    add_column :bot_tracks, :kind, :string
  end
end
