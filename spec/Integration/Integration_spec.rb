require 'rails_helper'

RSpec.describe 'Check links:', type: :feature do
  fixtures :Users

  before :each do
    # puts "#{page.html.inspect}"
    visit "/#{I18n.locale}/login_form"
    fill_in I18n.t(:email), with: 'goodman@test.com'
    fill_in I18n.t(:password), with: '12345678'
    click_button I18n.t(:enter)
  end

  it 'Login link' do
    expect(page).to have_content 'goodman@test.com'
  end

  it 'Users list link' do
    visit "/#{I18n.locale}/users"
    expect(page).to have_content 'Good Man'
    expect(page).to have_content 'Admin'
    expect(page).to have_content 'Bad Man'
  end

  it 'Tokens list link' do
    visit "/#{I18n.locale}/tokens"
    expect(page).to have_css('input#name')
    expect(page).to have_css('input#MAC')
    expect(page).to have_css('input#token')
    expect(page).to have_css('div#answer1')
    expect(page).to have_css('div#answer2_1')
    expect(page).to have_css('div#answer2_2')
  end
end
