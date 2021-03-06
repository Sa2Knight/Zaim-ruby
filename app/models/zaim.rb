require 'oauth'
require 'json'
require 'pp'
require_relative 'http'
require_relative 'util'
class Zaim

  API_URL = 'https://api.zaim.net/v2/'

  # ZaimAPIへのアクセストークンを生成する
  #--------------------------------------------------------------------
  def initialize
    @http = Http.new
  end

  # ユーザ名
  #--------------------------------------------------------------------
  def username
    @http.get_verify["me"]["name"]
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
    ranking = create_ranking("place")
    ranking.each {|r| r[:id] = r[:key]}
  end

  # カテゴリ別のランキングを取得
  #--------------------------------------------------------------------
  def category_ranking(params = {})
    ranking = create_ranking("category_id")
    id_to_name = id_to_categories(ranking.map{|r| r[:key]})
    ranking.each do |r|
      name = id_to_name[r[:key]]
      r[:id] = r[:key]
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
      r[:id] = r[:key]
      r[:key] = name
    end
  end

  # 月ごとの支出を取得
  #--------------------------------------------------------------------
  def monthly_spending(params = {})
    payments = @http.get_payments(params)
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
    @http.get_payments(params)
  end

  # ランキングを生成
  #--------------------------------------------------------------------
  def create_ranking(key , params = {})
    payments = @http.get_payments(params)
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
    categories = @http.get_categories
    target = categories.select {|c| c['name'] == category}
    target[0]["id"]
  end

  # ジャンル名をIDに変換する(同名のジャンルが複数ある場合に非対応)
  #--------------------------------------------------------------------
  def genre_to_id(genre)
    genres = @http.get_genres
    target = genres.select {|g| g['name'] == genre}
    target[0]["id"]
  end

  # category_idをカテゴリ名に変換する(リスト対応)
  # [category_id] → {category_id => category_name}
  #--------------------------------------------------------------------
  def id_to_categories(categories)
    categories_detail = @http.get_categories.select {|c| categories.include?(c["id"])}
    Util.array_to_hash(categories_detail , "id" , "name")
  end

  # genre_idをジャンル名に変換する(リスト対応)
  # [genre_id] → {genre_id => genre_name}
  #--------------------------------------------------------------------
  def id_to_genres(genres)
    genres_detail = @http.get_genres.select {|c| genres.include?(c["id"])}
    Util.array_to_hash(genres_detail , "id" , "name")
  end

  # 全支出データを取得及びキャッシュする
  #--------------------------------------------------------------------
  def all_payments
    @all_payments and return @all_payments
    @all_payments = @http.get_payments()
  end

  # 総収入データを取得及びキャッシュする
  #--------------------------------------------------------------------
  def all_incomes
    @all_incomes and return @all_incomes
    @all_incomes = @http.get_incomes()
  end

end
