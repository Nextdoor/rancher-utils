require 'rancher/api'
require 'net/http'

CATTLE_ACCESS_KEY = ENV['CATTLE_ACCESS_KEY']
CATTLE_SECRET_KEY = ENV['CATTLE_SECRET_KEY'] 
CATTLE_ENV_ENDPOINT = ENV['CATTLE_ENV_ENDPOINT'] 
CATTLE_SERVICE_ID = ENV['CATTLE_SERVICE_ID'] 

# TODO(abhijeet) Email Rancher engineers for a code-review
# CATTLE_SERVICE_FIRST_CONTAINER_IMAGE = ENV['CATTLE_SERVICE_FIRST_CONTAINER_IMAGE'] 

Rancher::Api.configure do |config|
  config.url = CATTLE_ENV_ENDPOINT
  config.access_key = CATTLE_ACCESS_KEY 
  config.secret_key = CATTLE_SECRET_KEY 
end

service = Rancher::Api::Service.find(CATTLE_SERVICE_ID)

# TODO(abhijeet) when all hell breaks lose, use shell 'curl'
# File.write('/tmp/upgrade.json', service.upgrade.to_json)

url = service.actions['upgrade']
uri = URI(url)
request = Net::HTTP::Post.new(uri.request_uri)
request.basic_auth(CATTLE_ACCESS_KEY, CATTLE_SECRET_KEY)
request['Content-Type'] = 'application/json'
request['Accept'] = 'application/json'
request.body = service.upgrade.to_json

res = Net::HTTP.start(uri.host, uri.port,
  :use_ssl => uri.scheme == 'https') do |http|
  http.request(request)
end

case res
when Net::HTTPSuccess, Net::HTTPRedirection
  print "Requesting upgrade for #{service.name}"
else
  puts res.body
end

Timeout.timeout(300) do
  i = 10
  print "."
  sleep i
  service = Rancher::Api::Service.find(CATTLE_SERVICE_ID)
  finish = service.actions['finishupgrade']
  while service.transitioning == 'yes' || finish.nil? || finish.empty?
    wait_time = 10 
    i += wait_time
    print "."
    service = Rancher::Api::Service.find(CATTLE_SERVICE_ID)
    finish = service.actions['finishupgrade']
    sleep wait_time
  end
  puts "\nUpgraded #{service.name}, took approximately #{i} secs."
end
  
puts "Finishing upgrade for #{service.name}"

url = service.actions['finishupgrade']
uri = URI(url)
request = Net::HTTP::Post.new(uri.request_uri)
request.basic_auth(CATTLE_ACCESS_KEY, CATTLE_SECRET_KEY)
request['Content-Type'] = 'application/json'
request['Accept'] = 'application/json'

res = Net::HTTP.start(uri.host, uri.port,
  :use_ssl => uri.scheme == 'https') do |http|
  http.request(request)
end

case res
when Net::HTTPSuccess, Net::HTTPRedirection
  puts "Finished upgrade for #{service.name}"
else
  puts res.body
end
