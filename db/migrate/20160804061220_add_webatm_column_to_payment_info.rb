class AddWebatmColumnToPaymentInfo < ActiveRecord::Migration
  def change
    add_column :payment_infos, :payer_account_5code, :string
    add_column :payment_infos, :pay_bank_code, :string
  end
end
