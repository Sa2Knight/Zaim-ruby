require './app/controllers/index_route'
require 'rack/protection'

use Rack::Session::Pool, :expire_after => 60 * 60 * 24 * 7
use Rack::Protection, raise: true
use Rack::Protection::AuthenticityToken

map('/') {run IndexRoute.new}
