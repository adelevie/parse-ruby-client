# -*- encoding : utf-8 -*-
client = Parse.create(
  application_id: 'your_application_id',
  api_key: 'your_REST_API_Key')

profile = client.object('Profile')
profile['first_name']    = 'John'
profile['last_name']     = 'Doe'
profile['username']      = 'jdoe'
profile['email_address'] = 'jdoe@fubar.com'
profile['birthday']      = Parse::Date.new('1980-12-25')
profile.save

profile.increment 'login_count'

# Queries
cls = 'GameScore'
(1..100).each do |i|
  score = client.object(cls)
  score['score'] = i
  score.save
end

client.query(cls).greater_eq('score', 10).less_eq('score', 20).get

client.query(cls).value_in('score', [10, 20, 30, 40]).get

# Pushes
push = client.push(alert: "I'm sending this push to all my app users!")
push.save
