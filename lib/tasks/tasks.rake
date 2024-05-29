# frozen_string_literal: true

namespace :xconn do
  desc "Start SAMPLE app"
  task :run, [:host, :port, :realm, :directory, :app] do |_t, args|
    host      = args[:host]       || "127.0.0.1"
    port      = args[:port]       || 8080
    realm     = args[:realm]      || "realm1"
    app       = args[:app]        || "Example"
    directory = args[:directory]  || "./example/sample"

    command = "bin/xconn -h #{host} -p #{port} -r #{realm} -d #{directory} -a #{app}"

    puts "Running: #{command}"

    trap("SIGINT") do
      puts "\nReceived SIGINT. Gracefully exiting..."

      exit 0
    end

    `#{command}`
  end
end
