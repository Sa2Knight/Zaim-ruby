require 'yaml'

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

end
