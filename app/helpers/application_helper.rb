module ApplicationHelper
  def avatar_url(email, size = 100)
    gravatar_id = Digest::MD5.hexdigest(email.downcase)
    "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}"
  end

  def previous_months(number = 5)
    today = Date.today.beginning_of_month
    date_from  = today - number.months
    date_to = today
    date_range = date_from..date_to

    date_months = date_range.map {|d| Date.new(d.year, d.month, 1) }.uniq
    date_months.map {|d| d.strftime "%Y-%m-%d" }
  end
end
