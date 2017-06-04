require 'yaml'
require 'date'
require 'uri'

class Util

  APIFILE = "api"

  # APIキーを取得
  # {:key => hoge , :secret => fuga}
  #--------------------------------------------------------------------
  def self.get_api_key()
    YAML.load_file(APIFILE)
  end

  # GET用のURLを生成する
  #--------------------------------------------------------------------
  def self.make_url(url , params)
    params.each do |k , v|
      if url.index('?').nil?
        url += "?#{k}=#{v}"
      else
        url += "&#{k}=#{v}"
      end
    end
    url_escape = URI.escape(url)
    return url_escape
  end

  # yyyy-mm-dd を yyyy-mmに変換する
  #--------------------------------------------------------------------
  def self.to_month(date)
    # 文字列を年月日に分割
    match = date.match(/(\d{4})-(\d{1,2})-(\d{1,2})/)
    year = match[1].to_i
    month = match[2].to_i
    day = match[3].to_i
    date_object = Date.new(year , month , 1)
    return "#{year}-#{month}"
  end

  # ハッシュ配列から特定の要素をキーとしたハッシュに変換する
  # ex) ([{:a => 1, :b => 'a'}, {:a => 2, :b => 'b'}], :a, :b) → {1=>"a", 2=>"b"}
  #--------------------------------------------------------------------
  def self.array_to_hash(array , key , value)
    hash = {}
    array.each do |h|
      hash[h[key]] = h[value]
    end
    hash
  end

  # RubyオブエクトをJSONに変換する
  #---------------------------------------------------------------------
  def self.to_json(obj)
    obj.kind_of?(Hash) or obj.kind_of?(Array) or return ""
    JSON.generate(obj)
  end

end
