require_relative 'base'

class IndexRoute < Base

  # get '/' - トップページへのアクセス
  #---------------------------------------------------------------------
  get '/' do
    'Hello Zaim!!'
  end

end
