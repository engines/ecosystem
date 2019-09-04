module Server
  class Api

    if Sinatra::Base.development?

      set :bind, '0.0.0.0'
      configure do
        enable :cross_origin
      end
      before do
        response.headers['Access-Control-Allow-Origin'] = '*'
      end
      options "*" do
        response.headers["Allow"] = "*"
        response.headers["Access-Control-Allow-Headers"] = "*"
        response.headers["Access-Control-Allow-Origin"] = "*"
        200
      end

    end

  end
end
