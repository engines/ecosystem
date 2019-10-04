module Server
  class Client
    class Distribution

      require 'uglifier'

      def initialize( version=nil )
        @version = version
      end

      def path
        raise "Version can't be blank" if @version === nil
        @path ||= "client/release/#{@version}"
      end

      def process
        if Dir.exist? path
          raise "Release #{@version} already exists!"
        else
          process!
        end
      end

      def process!
        if Dir.exist? path
          FileUtils.rm_r path
        end
        puts "Building release #{@version}"
        Dir.mkdir path
        File.write( "#{path}/client.js", client )
        File.write( "#{path}/client.min.js", client_min )
        # `jsdoc --readme axf/src/axf/README.md #{path}/axf/axf.js -d #{path}/docs/axf`
        # `jsdoc #{path}/plugins/plugins.js -d #{path}/docs/plugins`
      end

      def client
        concatenate( [ './client/src/**/*.js' ] )
      end

      def client_min
        minify client
      end

      def concatenate( sources )
        ["'use strict'"].tap do |result|
          sources.each do |source|
            files_from( source ).each do |file|
              result << File.read( file )
            end
          end
        end.join("\n")
      end

      def minify( javascript )
        Uglifier.compile javascript, harmony: true
      end

      def files_from( source )
        Dir.glob( [ source ] ).select { |file| puts file; File.file?(file) }.sort{ |a, b| a.count('/') <=> b.count('/') }
      end

    end
  end
end
