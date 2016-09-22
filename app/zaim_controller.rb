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
    zaim_params = {}
    category = params['category']
    genre = params['genre']
    if category
      @target = category
      category_id = @zaim.category_to_id(category)
      zaim_params['category_id'] = category_id
    elsif genre
      @target = genre
      genre_id = @zaim.genre_to_id(genre)
      zaim_params['genre_id'] = genre_id
    else
      @target = "累計"
    end
    @monthly = @zaim.monthly_spending(zaim_params)
    erb :monthly
  end

  # before - 全てのURLにおいて初めに実行される
  #---------------------------------------------------------------------
  before do
    @zaim = Zaim.new
  end

end
