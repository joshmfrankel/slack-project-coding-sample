class CreateIncidents < ActiveRecord::Migration[7.0]
  def change
    create_table :incidents do |t|
      t.string :title
      t.text :description
      t.integer :severity
      t.integer :status
      t.string :external_slack_user_id

      t.timestamps
    end
  end
end
