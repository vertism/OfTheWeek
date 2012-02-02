require 'otw_date'

module HomeHelper
  
  def getURL(photo, offset) 
    newDate = Date.commercial(photo.year.to_i, photo.week.to_i) + (offset * 7)
    newWeek = newDate.cweek
    newYear = newDate.cwyear

    if newYear > OTWDate.currentYear || (newYear == OTWDate.currentYear && newWeek > OTWDate.currentWeek)
      return nil
    end

    '/s/' + photo.tag + '/' + newYear.to_s + '/' + newWeek.to_s
  end
  
end
