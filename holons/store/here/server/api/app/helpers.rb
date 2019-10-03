module Server
  class Api
    module App
      module Helpers
        Dir.glob( [ File.dirname(__FILE__) + "/helpers/**/*.rb" ] ).
            each { |file| require file }
      end
    end
  end
end
