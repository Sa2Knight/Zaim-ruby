require 'sinatra/base'

class Zaim < Sinatra::Base

  set :views, File.dirname(__FILE__) + '/../views'
  set :public_folder, File.dirname(__FILE__) + '/../public'

  # configure - サーバ起動時の初期設定
  #---------------------------------------------------------------------
  configure do
    enable :sessions
  end

  # helpers - コントローラを補佐するメソッドを定義
  #---------------------------------------------------------------------
  helpers do
    include Rack::Utils
  end

  # before - 全てのURLにおいて初めに実行される
  #---------------------------------------------------------------------
  before do
  end

end
