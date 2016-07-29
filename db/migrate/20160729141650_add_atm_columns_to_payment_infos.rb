class AddAtmColumnsToPaymentInfos < ActiveRecord::Migration
  def change
    add_column :payment_infos, :atm_bank_code, :string
    add_column :payment_infos, :atm_code_no, :string
    add_column :payment_infos, :atm_expire_date, :string
    add_column :payment_infos, :atm_expire_time, :string
  end
end
