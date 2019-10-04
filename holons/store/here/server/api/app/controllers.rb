module Server
  class Api
    module App
      module Controllers

        extend Sinatra::Extension
        include Models

        Dir.glob( [ File.dirname(__FILE__) + "/controllers/**/*.rb" ] ).
            each { |file| require file }

      end
    end
  end
end
