require 'forwardable'

module AppnexusApi
  module Faraday
    module Response
      class DebugLogger < ::Faraday::Middleware
        extend Forwardable

        def initialize(app, logger = nil)
          super(app)
          @logger = logger || begin
            require 'logger'
            ::Logger.new(STDOUT)
          end
        end

        def_delegators :@logger, :debug, :info, :warn, :error, :fatal

        def call(env)
          info "#{env.method} #{env.url.to_s}"
          debug('request') { dump_headers env.request_headers }
          debug('request') { env.body }
          super
        end

        def on_complete(env)
          info('Status') { env.status.to_s }
          debug('response') { dump_headers env.response_headers }
          debug('response') { env.body }
        end

        private

        def dump_headers(headers)
          headers.map { |k, v| "#{k}: #{v.inspect}" }.join("\n")
        end
      end
    end
  end
end