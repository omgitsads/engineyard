require 'highline'
require 'engineyard-api-client'

module EY
  class CLI
    class API
      attr_reader :token

      def initialize(token = nil)
        @token = token
        @token ||= EY::EYRC.load.api_token
        @token ||= self.class.fetch_token
        raise EY::Error, "Sorry, we couldn't get your API token." unless @token
        @api = EY::APIClient.new(@token)
      end

      def request(*args)
        begin
          @api.request(*args)
        rescue EY::APIClient::InvalidCredentials
          EY.ui.warn "Credentials rejected; please authenticate again."
          refresh
          retry
        end
      end

      def refresh
        @token = self.class.fetch_token
      end

      def self.fetch_token
        EY.ui.info("We need to fetch your API token; please log in.")
        begin
          email    = EY.ui.ask("Email: ")
          password = EY.ui.ask("Password: ", true)
          token = EY::APIClient.authenticate(email, password)
          EY::EYRC.load.api_token = token
        rescue EY::APIClient::InvalidCredentials
          EY.ui.warn "Invalid username or password; please try again."
          retry
        end
      end

      protected

      def method_missing(meth, *args, &block)
        if @api.respond_to?(:meth)
          @api.send(meth, *args, &block)
        else
          super
        end
      end

    end
  end
end
