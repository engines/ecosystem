module Server
  class Api
    module App
      module Controllers


        # def self.route( url, &block )
        #   # get url do &block
        #   post url do  &block
        # end

        post '/login' do
          reset_preauth
          api_vars = {
            user_name: "admin",
            password: params[:password]
          }
          save_api_token @engines.post_api_vars( '/system/login', api_vars, { timeout: 5 } ).body
          set_timeout
          content_type :text
          "Success."
        end

        delete '/login' do
          preauth
          @engines.get( '/system/status' )
          save_api_token nil
          content_type :text
          "Success."
        end

        get '/reconnected' do
          @engines.get( '/throw_a_404' )
        rescue Error::SystemNotFound
          # System has responded with a 404, so it must be alive!
          return 'System is connected.'
        end

        get '/eventsource/builder' do
          preauth
          content_type "text/event-stream"
          stream( :keep_open ) do |out|
            started = Time.now.strftime("%H:%M:%S")
            logger.info "STREAM:#{ started } Builder log stream started."
            begin
              @engines.stream_lines( '/engine_builder/follow_stream' ) do |line|
                raise Error::NotAuthenticated if line == 'Invalid Token'
                line = nil if line == '.'
                out.puts "data: #{ line }\n\n"
                out.flush
              end
              logger.info "STREAM:#{ started } Builder log stream complete."
            rescue => e
              error_message = "STREAM:#{ started } Builder log stream error. #{ e }"
              logger.error error_message
              out.puts "data: \033[1;31m#{ error_message }\033[0m\n\n"
            ensure
              out.puts "data: #{ 4.chr }\n\n" # ASCII 4 is EOT (end of transmission)
              out.close
            end
          rescue IOError => e
            logger.info "STREAM:#{ started } Builder log stream lost its connection with user agent."
          end
        end

        get '/eventsource/containers' do
          preauth
          content_type "text/event-stream"
          stream( :keep_open ) do |out|
            started = Time.now.strftime("%H:%M:%S")

            logger.info "STREAM:#{ started }: Container events stream open."
            begin
              @engines.stream_lines( '/containers/events/stream' ) do |serializedEvent|
                raise Error::Timeout unless within_timeout
                # raise Error::NotAuthenticated if serializedEvent == 'Invalid Token'
                # debugger
                event = JSON.parse( serializedEvent, symbolize_names: true )
                if event[:no_op]
                  data = {}
                else
                  if event[:container_type] == 'service' || event[:container_type] == 'app'
                    name = event[:container_name]
                    type = event[:container_type] == 'service' ? 'service' : 'application'
                    typeForRoute = type == 'service' ? 'service' : 'engine'
                    status = JSON.parse(
                      @engines.get( "/containers/#{ typeForRoute }/#{ name }/status" ),
                      symbolize_names: true
                    )
                    update = { type: type, name: name, status: status }
                    data = { type: :container_status_update, container_status_update: update }.to_json
                  else
                    data = { type: :unhandled_event, unhandled_event: event }.to_json
                  end
                end
                logger.info "STREAM:#{ started }: Container events stream sending data.\n#{ data }\n"
                out.puts "data: #{ data }\n\n"
                out.flush
              end
              raise "The container events stream lost its connection to the Engines system."
            rescue Error::Timeout
              out.puts "data: #{ { type: :timeout }.to_json }\n\n"
              logger.info "STREAM:#{ started }: Container events stream closed due to user timeout."
            rescue => e
              out.puts "data: #{ { type: :error, error: e.to_s }.to_json }\n\n"
              logger.error "STREAM:#{ started }: Container events stream closed with error. #{ e }"
            ensure
              out.close
            end
          rescue IOError => e
            logger.info "STREAM:#{ started } Container events stream lost its connection to user agent."
          end
        end

        get '/download/service/:service_name' do

          preauth_or_redirect

          filename = "Engines #{ params[:service_name] } export #{ Time.now.strftime("%Y-%m-%d %H:%M:%S") }.zip"
          route = "/containers/service/#{ params[:service_name] }/export"

          content_type 'application/zip'
          attachment filename

          stream do |out|
            logger.info "Service export stream started."
            begin
              @engines.stream_chunks( route ) do |chunk|
                # raise Error::NotAuthenticated if line == 'Invalid Token'
                # line = nil if line == '.'
                out.write chunk
                out.flush
              end
              logger.info "Service export stream complete."
            rescue IOError => e
              logger.info "Service export stream lost its connection with user agent."
            rescue => e
              error_message = "Service export stream error. #{ e }"
              logger.error error_message
            ensure
              out.close unless out.closed?
            end
          end

        end

        get '/download/test' do

          filepath = 'test/sample_file_for_download_test.zip'

          content_type 'application/zip'
          attachment "sample_file.zip"
          response['Content-Length'] = File.size( filepath ).to_s

          stream do |out|
            logger.info "Test download stream started."
            begin
              File.open( filepath, 'rb' ) do |f|
                until f.eof? do
                  puts "Download test: do a chunk"
                  out.write( f.read( 1048576 ) )
                  out.flush
                  sleep 0.5
                end
              end
              logger.info "Test download stream complete."
            rescue IOError => e
              logger.info "Test download stream lost its connection with user agent."
            rescue => e
              error_message = "Test download stream error. #{ e }"
              logger.error error_message
            ensure
              out.close unless out.closed?
            end
          end

        end

        # post '/upload/service/navphp' do
        #   # debugger
        #   'ok'
        # end

        get '/-/*' do
          # sleep 3
          preauth
          path = request.fullpath.sub '/api/-', ''
          # debugger if path == '/system/config/default_site'
          result = @engines.get( path )
          status result.code
          content_type result.headers[:content_type]
          result.body
        end

        delete '/-/*' do
          preauth
          path = request.fullpath.sub '/api/-', ''
          result = @engines.delete( path )
          status result.code
          content_type result.headers[:content_type]
          result.body
        end

        post '/-/*' do
          preauth
          path = request.fullpath.sub '/api/-', ''
          result = @engines.post_api_vars( path, params[:api_vars] )
          status result.code
          content_type result.headers[:content_type]
          result.body
        end

      end
    end
  end
end
