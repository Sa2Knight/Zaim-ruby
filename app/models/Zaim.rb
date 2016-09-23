require 'oauth'
require 'json'
require 'pp'
require_relative "util"
class Zaim

  API_URL = 'https://api.zaim.net/v2/'

  # ZaimAPIへのアクセストークンを生成する
  #--------------------------------------------------------------------
  def initialize
    api_key = Util.get_api_key
    oauth_params = {
      site: "https://api.zaim.net",
      request_token_path: "/v2/auth/request",
      authorize_url: "https://auth.zaim.net/users/auth",
      access_token_path: "https://api.zaim.net"
    }
    @consumer = OAuth::Consumer.new(api_key["key"], api_key["secret"], oauth_params)
    @access_token = OAuth::AccessToken.new(@consumer, api_key["oauth_token"], api_key["oauth_secret"])
  end

  # ユーザ名
  #--------------------------------------------------------------------
  def username
    get_verify["me"]["name"]
  end

  # 総支出額を取得
  #--------------------------------------------------------------------
  def total_spending
    sum = 0
    all_payments().each {|pay| sum += pay["amount"]}
    return sum
  end

  # 総収入額を取得
  #--------------------------------------------------------------------
  def total_income
    sum = 0
    all_incomes().each {|income| sum += income["amount"]}
    return sum
  end

  # 総入力回数を取得
  #--------------------------------------------------------------------
  def total_input_count
    all_payments().count + all_incomes().count
  end

  # 支払先別のランキングを取得
  #--------------------------------------------------------------------
  def place_ranking(params = {})
    create_ranking("place")
  end

  # カテゴリ別のランキングを取得
  #--------------------------------------------------------------------
  def category_ranking(params = {})
    ranking = create_ranking("category_id")
    id_to_name = id_to_categories(ranking.map{|r| r[:key]})
    ranking.each do |r|
      name = id_to_name[r[:key]]
      r[:key] = name
    end
  end

  # ジャンル別のランキングを取得
  # Todo: category_rankingとコード重複
  #--------------------------------------------------------------------
  def genre_ranking(params = {})
    ranking = create_ranking("genre_id")
    id_to_name = id_to_genres(ranking.map{|r| r[:key]})
    ranking.each do |r|
      name = id_to_name[r[:key]]
      r[:key] = name
    end
  end

  # 月ごとの支出を取得
  #--------------------------------------------------------------------
  def monthly_spending(params = {})
    payments = get_payments(params)
    monthly = Hash.new {|h,k| h[k] = 0}
    payments.each do |pay|
      month = Util.to_month(pay["date"])
      monthly[month] += pay["amount"]
    end
    return monthly
  end

  # 指定した日にちの出費内容
  # dateはYYYY-MM-DD形式の文字列
  #--------------------------------------------------------------------
  def payment_of_day(date , params = {})
    params["start_date"] = date
    params["end_date"] = date
    params["date"] = date
    get_payments(params)
  end

  # ランキングを生成
  #--------------------------------------------------------------------
  def create_ranking(key , params = {})
    payments = get_payments(params)
    t_hash = Hash.new {|h,k| h[k] = {:num => 0 , :amount => 0}}
    payments.each do |pay|
      _key = pay[key]
      t_hash[_key][:num] += 1
      t_hash[_key][:amount] += pay["amount"]
    end
    t_hash.delete("") #未入力は除外
    t_array = []
    t_hash.each {|k , v| t_array.push({:key => k}.merge!(v))}
    t_array.sort_by {|t| -t[:num]}
  end

  # カテゴリ名をIDに変換する
  #--------------------------------------------------------------------
  def category_to_id(category)
    categories = get_categories
    target = categories.select {|c| c['name'] == category}
    target[0]["id"]
  end

  # ジャンル名をIDに変換する(同名のジャンルが複数ある場合に非対応)
  #--------------------------------------------------------------------
  def genre_to_id(genre)
    genres = get_genres
    target = genres.select {|g| g['name'] == genre}
    target[0]["id"]
  end

  # category_idをカテゴリ名に変換する(リスト対応)
  # [category_id] → {category_id => category_name}
  #--------------------------------------------------------------------
  def id_to_categories(categories)
    categories_detail = get_categories.select {|c| categories.include?(c["id"])}
    Util.array_to_hash(categories_detail , "id" , "name")
  end

  # genre_idをジャンル名に変換する(リスト対応)
  # [genre_id] → {genre_id => genre_name}
  #--------------------------------------------------------------------
  def id_to_genres(genres)
    genres_detail = get_genres.select {|c| genres.include?(c["id"])}
    Util.array_to_hash(genres_detail , "id" , "name")
  end

  # 全支出データを取得及びキャッシュする
  #--------------------------------------------------------------------
  def all_payments
    @all_payments and return @all_payments
    @all_payments = get_payments()
  end

  # 総収入データを取得及びキャッシュする
  #--------------------------------------------------------------------
  def all_incomes
    @all_incomes and return @all_incomes
    @all_incomes = get_incomes()
  end

  # 以下、各種API呼び出しメソッド
  private
  def get_verify
    get("home/user/verify")
  end

  def get_payments(params = {})
    params["mode"] = "payment"
    url = Util.make_url("home/money" , params)
    get(url)["money"]
  end

  def get_incomes(params = {})
    params["mode"] = "income"
    url = Util.make_url("home/money" , params)
    get(url)["money"]
  end

  def get_categories
    get("home/category")["categories"]
  end

  def get_genres
    get("home/genre")["genres"]
  end

  def create_payments(category , genre , amount)
    post("home/money/payment" , category_id: category, genre_id: genre, amount: amount)
  end

  def get(url)
    response = @access_token.get("#{API_URL}#{url}")
    JSON.parse(response.body)
  end

  def post(url , params = nil)
    response = @access_token.post("#{API_URL}#{url}" , params)
    JSON.parse(response.body)
  end

end
