class LockboxTransaction < ApplicationRecord
  belongs_to :lockbox_action

  BALANCE_EFFECTS = [ :debit, :credit ].freeze
end