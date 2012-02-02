module OTWDate
  
  def self.currentYear
    Time.now.to_date.cwyear
  end
  
  def self.currentWeek
    Time.now.to_date.cweek
  end
        
  def self.getDates(year, week)
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
  
end