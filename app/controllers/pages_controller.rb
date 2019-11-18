class PagesController < ApplicationController
  skip_before_filter :require_login

  def index
    render layout: false
  end

  def demo
  end
end
