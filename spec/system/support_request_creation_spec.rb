require 'rails_helper'

RSpec.describe "Support Request Creation", type: :system do
  let!(:lockbox_partner) { FactoryBot.create(:lockbox_partner, :active, name: 'Gorillas R Us') }
  let!(:user)            { FactoryBot.create(:user) }

  before do
    login_as(user, :scope => :user)
  end

  it 'can file a support request from main dashboard' do
    visit "/support_requests/new"

    fill_in 'Pick-up Date', with: Date.current
    fill_in 'Client Alias',  with: 'McGee'
    fill_in 'Client Reference ID', with: 'b358250'

    page.all(:option, lockbox_partner.name).first.select_option
    page.all(:fillable_field, 'Amount').each {|e| e.set(13.37)}
    page.all(:option, 'Gas').each(&:select_option)

    click_button "Submit"

    assert_selector "h3", text: "Support Request for"

    click_link "Add Note"
    fill_in "note_text", with: "Here's some fine & fancy note text!"

    click_button "Save Note"
    assert_selector "td", text: "Here's some fine & fancy note text!"
  end

  it 'can file a support request from a lockbox dashboard' do
    visit "/lockbox_partners/#{lockbox_partner.id}/support_requests/new"

    fill_in 'Pick-up Date', with: Date.current
    fill_in 'Client Alias',  with: 'McGee'
    fill_in 'Client Reference ID', with: 'b358250'

    page.all(:fillable_field, 'Amount').each {|e| e.set(13.37)}
    page.all(:option, 'Gas').each(&:select_option)

    click_button "Submit"

    assert_selector "h3", text: "Support Request for"

    click_link "Add Note"
    fill_in "note_text", with: "Here's some fine & fancy note text!"

    click_button "Save Note"
    assert_selector "td", text: "Here's some fine & fancy note text!"
  end
end
