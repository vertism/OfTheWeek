module HomeHelper
  
  def getYear()
    Time.now.to_date.cwyear
  end
  
  def getWeek()
    Time.now.to_date.cweek
  end
        
  def getDates(year, week)
    begin 
      year = year.to_i
      week = week.to_i

      minDate = Date.commercial(year, week, 1) - 7
      maxDate = Date.commercial(year, week, 1)

      if Time.now.to_date.cwyear == year && Time.now.to_date.cweek == week
        term = ""
      else
        term = maxDate.strftime('%d %b %Y')
      end

      {:week => week, :year => year, :min => minDate.strftime('%s'), :max => maxDate.strftime('%s'), :term => term}
    rescue
      nil
    end
  end

  def getURL(tag, currentYear, currentWeek, offset) 
    newDate = Date.commercial(currentYear.to_i, currentWeek.to_i) + (offset * 7)
    newWeek = newDate.cweek
    newYear = newDate.cwyear

    actualYear = getYear
    actualWeek = getWeek

    if newYear > actualYear || (newYear == actualYear && newWeek > actualWeek)
      return nil
    end

    '/' + tag + '/' + newYear.to_s + '/' + newWeek.to_s
  end
end
