class CreatePaymentInfos < ActiveRecord::Migration
  def change
    create_table :payment_infos do |t|
      t.references :payable, polymorphic: true, index: true
      t.string :merchant_id
      t.string :total
      t.string :trade_no
      t.string :merchant_order_no
      t.string :check_code
      t.string :ip
      t.string :payment_type
      t.string :pay_time
      t.string :card_6no
      t.string :card_4no

      t.timestamps null: false
    end
  end
end