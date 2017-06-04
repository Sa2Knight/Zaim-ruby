require 'sinatra/base'
require_relative 'models/zaim'
require_relative 'models/util'

class ZaimController < Sinatra::Base

  set :views, File.dirname(__FILE__) + '/views'
  set :public_folder, File.dirname(__FILE__) + '/public'

  # before - 全てのURLにおいて初めに実行される
  #---------------------------------------------------------------------
  before do
    @zaim = Zaim.new
    #content_type :json SPA化したらつける
  end

  # ユーザの入力回数/総収入/総支出を取得
  #--------------------------------------------------------------------
  get '/api/user' do
    Util.to_json(
      :input_count    => @zaim.total_input_count,
      :total_income   => @zaim.total_income,
      :total_spending => @zaim.total_spending,
    )
  end

  # 月ごとの支出額を取得
  #--------------------------------------------------------------------
  get '/api/payments/monthly' do
    monthly = @zaim.monthly_spending(params)
    Util.to_json(monthly)
  end

  # カテゴリ別のランキングを取得
  #--------------------------------------------------------------------
  get '/api/payments/ranking/category' do
    Util.to_json @zaim.category_ranking
  end

  # ジャンル別のランキングを取得
  #--------------------------------------------------------------------
  get '/api/payments/ranking/genre' do
    Util.to_json @zaim.genre_ranking
  end

  # 支払先別のランキングを取得
  #--------------------------------------------------------------------
  get '/api/payments/ranking/place' do
    Util.to_json @zaim.place_ranking
  end

  # / - トップページ
  #--------------------------------------------------------------------
  get '/' do
    erb :index
  end

end
