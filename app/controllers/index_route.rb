require_relative 'zaim'

class IndexRoute < Zaim

  # get '/' - トップページへのアクセス
  #---------------------------------------------------------------------
  get '/' do
    'Hello Zaim!!'
  end

end
