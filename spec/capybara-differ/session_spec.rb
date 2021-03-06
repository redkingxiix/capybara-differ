RSpec.describe 'Capybara::Session' do
  before do
    Capybara.save_path = File.join('spec', 'fixtures')
    allow_any_instance_of(Capybara::Session).to receive(:save_page).and_return('Disabling save_page')
  end

  describe '#check_page' do
    it "requires options as Hash" do
      session = Capybara::Session.new(:rack_test)
      expect{
        session.check_page('session_test', 'not_hash')
      }.to raise_error(ArgumentError)
    end

    it "compares with the original by default" do
      session = Capybara::Session.new(:rack_test)
      expect{
        session.check_page('session_test', diffy: {format: :text})
      }.to output(%r{\-  Revision1\n\+  Revision3}).to_stdout
    end

    it "compares with the previous with compare_with option" do
      session = Capybara::Session.new(:rack_test)
      expect{
        session.check_page('session_test', compare_with: :previous, diffy: {format: :text})
      }.to output(%r{\-  Revision2\n\+  Revision3}).to_stdout
    end

    it "outputs the message of no history when there is no history" do
      session = Capybara::Session.new(:rack_test)
      session.check_page('no_history', compare_with: :previous, diffy: {format: :text})
      expect{
        session.check_page('no_history', compare_with: :previous, diffy: {format: :text})
      }.to output(%r{no history}).to_stdout
    end

    it "sanitizes path from invalid name" do
      session = Capybara::Session.new(:rack_test)
      expect{
        session.check_page('../../../invalid', compare_with: :previous, diffy: {format: :text})
      }.to output(%r{_invalid}).to_stdout
    end
  end
end
