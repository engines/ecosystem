module Server
  class Api

    before do
      @engines = App::Models::Engines.new(
                    settings.engines_system_ip,
                    api_token,
                    logger )
    end

  end
end
