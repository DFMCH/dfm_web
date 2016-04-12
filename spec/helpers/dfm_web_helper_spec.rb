describe DfmWebHelper, type: :helper do

  it "menu_tag creates a li with the title and link etc" do
    expect(helper.menu_tag("title", "link", {foo: :bar, one: :two})).to eq "<a href=\"link\"><li foo=\"bar\" one=\"two\">title</li></a>"
  end
end
