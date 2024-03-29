class SupportRequest < ApplicationRecord
  belongs_to :lockbox_partner
  belongs_to :user
  has_one :lockbox_action
  accepts_nested_attributes_for :lockbox_action
  has_many :lockbox_transactions, through: :lockbox_action
  accepts_nested_attributes_for :lockbox_transactions, reject_if: :all_blank,
    allow_destroy: true
  has_many :notes, as: :notable

  validates :client_ref_id, presence: true
  validates :name_or_alias, presence: true
  validates :user, presence: true
  validates :lockbox_partner, presence: true

  # Sometimes the UUID will already have been created elsewhere, and sometimes not
  before_validation :populate_client_ref_id

  # for grepability:
  # scope :pending
  # scope :completed
  # scope :canceled
  LockboxAction::STATUSES.each do |status|
    scope status, -> { joins(:lockbox_action).where("lockbox_actions.status": status) }
    scope "#{status}_for_partner", ->(lockbox_partner_id:) { joins(:lockbox_action).where(lockbox_partner_id: lockbox_partner_id, "lockbox_actions.status": status) }
  end

  def all_support_requests_for_partner
    @all_support_requests_for_partner ||= self
      .class
      .where(lockbox_partner: lockbox_partner)
      .sort { |x, y| y.eff_date <=> x.eff_date }
  end

  def amount
    lockbox_action.amount
  end

  def editable_status?
    lockbox_action.editable_status?
  end

  def eff_date
    lockbox_action.eff_date
  end
  alias_method :pickup_date, :eff_date

  def most_recent_note
    @most_recent_note ||= notes.last
  end

  def newer_request_by_partner
    return nil unless newer_idx
    all_support_requests_for_partner[newer_idx]
  end

  def older_request_by_partner
    return nil unless older_idx
    all_support_requests_for_partner[older_idx]
  end

  def status
    lockbox_action.status
  end

  def status_options
    LockboxAction::STATUSES - [status]
  end

  def record_creation
    note_text =
      "Support request generated by #{user.name} " \
      "at #{created_at.strftime("%I:%M %p %:::z")} " \
      "on #{created_at.strftime("%B %d, %Y")}"
    notes.create(text: note_text)
  end

  private

  def index_in_support_requests_collection
    all_support_requests_for_partner.find_index self
  end

  def newer_idx
    idx = index_in_support_requests_collection
    @newer_idx ||= idx > 0 ? idx - 1 : nil
  end

  def older_idx
    idx = index_in_support_requests_collection
    max_idx = all_support_requests_for_partner.count - 1
    @older_idx ||= idx < max_idx ? idx + 1 : nil
  end

  def populate_client_ref_id
    self.client_ref_id = SecureRandom.uuid if client_ref_id.blank?
  end
end
