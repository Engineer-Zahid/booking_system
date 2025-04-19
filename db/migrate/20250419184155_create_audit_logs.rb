class CreateAuditLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :audit_logs do |t|
      t.references :booking, null: false, foreign_key: true
      t.integer :action, null: false
      t.text :details, null: false

      t.timestamps
    end
  end
end
