module EY
  class CLI
    class Web < EY::Thor
      desc "web enable [ENVIRONMENT]", <<-HELP
Take down the maintenance page for the current application in the specified environment.
      HELP
      method_option :environment, :type => :string, :aliases => %w(-e),
        :desc => "Environment on which to put up the maintenance page"
      def enable
        app         = api.app_for_repo!(repo)
        environment = fetch_environment(options[:environment], app)
        loudly_check_eysd(environment)
        EY.ui.info "Taking down maintenance page for #{environment.name}"
        environment.take_down_maintenance_page(app)
      end

      desc "web disable [ENVIRONMENT]", <<-HELP
Put up the maintenance page for the current application in the specified environment.

The maintenance page is taken from the app currently being deployed. This means
that you can customize maintenance pages to tell users the reason for downtime
on every particular deploy.

Maintenance pages searched for in order of decreasing priority:
* public/maintenance.html.custom
* public/maintenance.html.tmp
* public/maintenance.html
* public/system/maintenance.html.default
      HELP
      method_option :environment, :type => :string, :aliases => %w(-e),
        :desc => "Environment on which to take down the maintenance page"
      def disable
        app         = api.app_for_repo!(repo)
        environment = fetch_environment(options[:environment], app)
        loudly_check_eysd(environment)
        EY.ui.info "Putting up maintenance page for #{environment.name}"
        environment.put_up_maintenance_page(app)
      end
    end
  end
end