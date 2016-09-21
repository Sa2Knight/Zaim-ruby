require 'yaml'
require 'date'

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
    return url
  end

  # yyyy-mm-dd を yyyy-mmに変換する
  # cutoffを指定することで、25日以降を翌月扱いにできる
  #--------------------------------------------------------------------
  def self.to_month(date , cutoff = 25)
    # 文字列を年月日に分割
    match = date.match(/(\d{4})-(\d{1,2})-(\d{1,2})/)
    year = match[1].to_i
    month = match[2].to_i
    day = match[3].to_i

    # 当該月cutoff日が土日の場合、cutoff値をズラす
    date_object = Date.new(year , month , cutoff)
    date_object.wday == 0 && cutoff -= 2
    date_object.wday == 6 && cutoff -= 1

    # cutoff値を元に月を補正
    if cutoff <= day
      month += 1
      if month == 13
        year += 1
        month = 1
      end
    end
    return "#{year}-#{month}"
  end

end
