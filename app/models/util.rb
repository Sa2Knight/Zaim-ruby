require 'yaml'

class Util

  APIFILE = "api"

  # APIキーを取得
  # {:key => hoge , :secret => fuga}
  #--------------------------------------------------------------------
  def self.get_api_key()
    YAML.load_file(APIFILE)
  end
end
