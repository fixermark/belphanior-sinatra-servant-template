# Interactive HTTP terminal; loads functions that allow for manipulation of
# HTTP directly.
# Usage example:
# > require 'http_term'
# > host 'http://localhost:3000'
# > get '/'
# 200
# ok
# > post '/config/foo','hi'
# 200
#
# get 'config/foo'
# 200
# hi

require 'net/http'

$http_target=URI.parse("http://localhost:3000")

def host(domain)
  $http_target = URI.parse(domain)
end

def get(uri)
  res = Net::HTTP.start($http_target.host, $http_target.port) {|http|
    http.get(uri)
  }
  print "#{res.code}\n"
  print "#{res.body}\n"
end
