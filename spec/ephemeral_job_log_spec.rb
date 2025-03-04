# frozen_string_literal: true

RSpec.describe EphemeralJobLog do
  it 'has a version number' do
    expect(EphemeralJobLog::VERSION).not_to be nil
  end
end
