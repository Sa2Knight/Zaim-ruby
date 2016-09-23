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
    @sum = @monthly.values.inject {|sum , v| sum + v}
    @target = params['link']
    erb :monthly
  end

  # helpers - ビューから利用する汎用メソッド
  #---------------------------------------------------------------------
  helpers do
    def to_kanji(price)
      price = price.to_i
      price < 10000 and return price
      m = price / 10000
      s = price % 10000
      return "#{m}万#{s}"
    end
  end

  # before - 全てのURLにおいて初めに実行される
  #---------------------------------------------------------------------
  before do
    @zaim = Zaim.new
  end

end
