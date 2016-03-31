# Shared Model Methods
module SharedModelMethods
  extend ActiveSupport::Concern

  # Class Methods
  module ClassMethods
    # My Numbering :-)
    def numbering(list = 1, length_of_page = 3, range_of_pages = 5)
      # get objects count
      objects_count = count

      # count of elements per page, should be more then 0
      length_of_page = 1 if length_of_page <= 0

      # range of pages, should be odd number
      range_of_pages += 1 if range_of_pages.even?

      # create amount of lists
      if objects_count % length_of_page == 0
        lists = objects_count / length_of_page
      else
        lists = objects_count / length_of_page + 1
      end

      lists == 0 ? lists = 1 : lists

      # check input variable "list"
      list = list.to_i
      list <= 0 ? list = 1 : list
      list > lists ? list = lists : list

      # create next page
      list < lists ? next_page = list + 1 : next_page = lists

      # create previous page
      list > 1 ? previous_page = list - 1 : previous_page = 1

      # create borders for range of pages
      if list - range_of_pages / 2 < 1 # special case for left border
        left_border = 1

        if range_of_pages >= lists
          right_border = lists
        else
          right_border = range_of_pages
        end

      elsif list + range_of_pages / 2 > lists # special case for right border
        right_border = lists

        if lists - range_of_pages < 1
          left_border = 1
        else
          left_border = lists - range_of_pages + 1
        end

      else # common case
        left_border = list - range_of_pages / 2
        right_border = list + range_of_pages / 2
      end

      # select objects
      objects = limit(length_of_page).offset((list - 1) * length_of_page)

      # output
      { objects: objects,
        pages:
              { left: left_border,
                right: right_border,
                next: next_page,
                previous: previous_page,
                current_page: list } }
    end
  end
end
