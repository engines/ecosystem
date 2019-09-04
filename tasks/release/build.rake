namespace :release do

  task :build, [ :version ] do | task, args |
    debugger
    @distribution = Server::Client::Distribution.new( args.version )
    @distribution.process
  end

  task :overwrite, [ :version ] do | task, args |
    @distribution = Server::Client::Distribution.new( args.version )
    @distribution.process!
  end

end
