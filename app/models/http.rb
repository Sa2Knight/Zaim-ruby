require 'oauth'
require 'json'
require 'pp'
require_relative "util"
class Http

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
