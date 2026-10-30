class DemoSessionsController < ApplicationController
  def reset
    @demo_session.reset!
    redirect_to root_path, notice: "あなたのデモを初期状態に戻しました。", status: :see_other
  end
end
