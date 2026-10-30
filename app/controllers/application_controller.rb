class ApplicationController < ActionController::Base
  before_action :set_demo_session

  private

  def set_demo_session
    token = session[:demo_token]
    @demo_session = DemoSession.where("expires_at > ?", Time.current).find_by(token: token) if token.present?
    unless @demo_session
      reset_session
      @demo_session = DemoSession.start!
      session[:demo_token] = @demo_session.token
    end
  end
end
