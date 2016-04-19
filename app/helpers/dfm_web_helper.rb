module DfmWebHelper


  def excel_icon(link = params.merge(:format => "xlsx"))
    # Create Excel icon in consistent location
    content_for :excel do
      link_to(image_tag('excel.png', :width => 40, :height => 40), link)
    end
  end
end
