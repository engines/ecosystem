module Server
  class Api
    module App
      module Helpers

        # require 'fileutils'
        #
        # def preauth
        #   raise Error::NotAuthenticated unless api_token
        #   raise Error::Timeout unless within_timeout
        #   set_timeout
        # end
        #
        # def preauth_or_redirect
        #   preauth
        # rescue Error::NotAuthenticated, Error::Timeout
        #   redirect '/'
        # end
        #
        # def within_timeout
        #   last_activity_at = auth_timestamp
        #   return false unless last_activity_at
        #   last_activity_at + settings.session_timeout_seconds > Time.now
        # end
        #
        # def auth_timestamp
        #   File.mtime auth_filepath
        # end
        #
        # def set_timeout
        #   FileUtils.touch auth_filepath
        # end
        #
        # def api_token
        #   File.read auth_filepath
        # rescue Errno::ENOENT
        # end
        #
        # def save_api_token( token )
        #   File.write auth_filepath, token
        # end
        #
        # def reset_preauth
        #   File.delete( auth_filepath ) if File.exist? auth_filepath
        # end
        #
        # def auth_filepath
        #   "sessions/#{ session[:session_id] }"
        # end

      end
    end
  end
end
