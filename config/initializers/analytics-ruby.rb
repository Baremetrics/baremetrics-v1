Analytics = AnalyticsRuby            # Alias for convenience
Analytics.init({
    secret: 'ENV["SEGMENT_SECRET"]',  # The secret for Baremetrics
    on_error: Proc.new { |status, msg| print msg }  # Optional error handler
})