require_relative 'base'

class IndexRoute < Base

  # get '/' - トップページへのアクセス
  #---------------------------------------------------------------------
  get '/' do
    erb :index
  end

end
