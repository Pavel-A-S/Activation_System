# Just an ApplicationHelper
module ApplicationHelper
  def will_be_numbered(path, list) # attributes from numbering look securely
    # show "Previous" button
    concat link_to '', "#{path}?list=#{list[:previous]}",
                   class: 'numbered_previous_link'
    # show numbered pages
    (list[:left]..list[:right]).each do |link|
      if link == list[:current_page]
        concat link_to "#{link}", "#{path}?list=#{link}",
                       class: 'current_page'
      else
        concat link_to "#{link}", "#{path}?list=#{link}",
                       class: 'numbered_link'
      end
    end

    # show "Next" button
    concat link_to '', "#{path}?list=#{list[:next]}",
                   class: 'numbered_next_link'
  end
end
