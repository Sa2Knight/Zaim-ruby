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
  def total_spending(params = {})
    sum = 0
    payments = get_payments(params)
    payments.each {|pay| sum += pay["amount"]}
    return sum
  end

  # 支払先別のランキングを取得
  #--------------------------------------------------------------------
  def place_ranking(params = {})
    create_ranking("place")
  end

  # カテゴリ別のランキングを取得
  #--------------------------------------------------------------------
  def category_ranking(params = {})
    ranking_with_id = create_ranking("category_id")
    ranking_with_name = {}
    id_to_name = id_to_categories(ranking_with_id.keys)
    ranking_with_id.each do |k , v|
      name = id_to_name[k]
      ranking_with_name[name] = v
    end
    ranking_with_name
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
    targets = Hash.new {|h,k| h[k] = {:num => 0 , :amount => 0}}
    payments.each do |pay|
      _key = pay[key]
      targets[_key][:num] += 1
      targets[_key][:amount] += pay["amount"]
    end
    targets.delete("") #未入力は除外
    targets_hash = {}
    targets.sort_by {|k , v| -v[:num]}.each do |t|
      targets_hash[t[0]] = t[1]
    end
    targets_hash
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

  # 以下、各種API呼び出しメソッド
  private
  def get_verify
    get("home/user/verify")
  end

  def get_payments(params)
    params["mode"] = "payment"
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
