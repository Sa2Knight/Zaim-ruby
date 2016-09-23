require 'sinatra/base'
require_relative 'models/Zaim'
require_relative 'models/util'

class ZaimController < Sinatra::Base

  set :views, File.dirname(__FILE__) + '/views'
  set :public_folder, File.dirname(__FILE__) + '/public'

  # / - トップページ
  #--------------------------------------------------------------------
  get '/' do
    erb :index
  end

  # /monthly - 月ごとの集計を表形式で表示
  #--------------------------------------------------------------------
  get '/monthly/?' do
    @monthly = @zaim.monthly_spending(params)
    @target = params['link']
    erb :monthly
  end

  # before - 全てのURLにおいて初めに実行される
  #---------------------------------------------------------------------
  before do
    @zaim = Zaim.new
  end

end
