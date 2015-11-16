module ApplicationHelper
  def date_text(date)
    if date.blank?
      r_date = '-'
    else
      if "#{date.year}#{date.month}#{date.day}" == "#{Time.now.year}#{Time.now.month}#{Time.now.day}"
        r_date = "Hoy #{date.strftime "%l:%M %p"}"
      elsif "#{date.year}#{date.month}#{date.day}" == "#{Time.now.year}#{Time.now.month}#{Time.now.day - 1}"
        r_date = "Ayer #{date.strftime "%l:%M %p"}"
      elsif date.year == Time.now.year
        r_date = date.strftime "%e de %b."
      else
        r_date = date.strftime "%d/%m/%y"
      end
    end
  end
end
