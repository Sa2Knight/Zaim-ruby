require './app/zaim_controller'
require 'rack/protection'

use Rack::Session::Pool, :expire_after => 60 * 60 * 24 * 7
use Rack::Protection, raise: true
use Rack::Protection::AuthenticityToken

run ZaimController.new
