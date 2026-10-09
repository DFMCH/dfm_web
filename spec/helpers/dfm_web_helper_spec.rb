require "rails_helper"

describe DfmWebHelper, type: :helper do

  it "host_application_title extracts the host app title" do
    expect(host_application_title).to eq "Dummy"
  end

end
