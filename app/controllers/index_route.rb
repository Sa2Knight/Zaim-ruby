require_relative 'base'

class IndexRoute < Base

  # get '/' - トップページへのアクセス
  #---------------------------------------------------------------------
  get '/' do
    @zaim.username
  end

end
