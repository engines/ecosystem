require 'sinatra/base'
require 'sinatra/extension'
require 'sinatra/json'
require 'sinatra/streaming'
require 'sinatra/cookies'
require 'byebug' if Sinatra::Base.development?
require 'yaml'
require 'logger'

require './server'

Dir.glob( './tasks/**/*.rake' ).each { |file| load file }

task default: [:release]
