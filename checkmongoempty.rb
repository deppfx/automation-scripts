#!/usr/bin/ruby

require 'mongo'

Mongo::Logger.logger.level = ::Logger::FATAL

#auth = db.authenticate(tps, password) unless (db.user.nil? || db.user.blank?)
#
##auth = client.authenticate(tps, password)
#
#put " This is the #{auth}."
#
#client.collections.each { |coll| puts coll.name }
#
#client.close

client_host = ['127.0.0.1:27017']

client_options = {
  database: 'concepts_db',
  user: 'tps',
  password: 'password'
}

begin
  client = Mongo::Client.new(client_host, client_options)
  puts('Client Connection: ')
  #puts(client.cluster.inspect)
  puts("##################")
  puts('Collection Names: ')
  puts("##################")
  puts(client.database.collection_names)
  puts('Connected!')
  #result = client[:concepts].find()
  #puts(result)
  puts(client[:concepts].find.limit(1).first)
  puts("Next is count")
  puts(client[:concepts].count())
  collcount = client[:concepts].count()
  if collcount == 0
    puts("Database is empty")
  else
    puts("Database contains #{collcount} documents")
  end
  client.close
rescue StandardError => err
  puts('Error: ')
  puts(err)
end
