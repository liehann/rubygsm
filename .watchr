module WatchrActions
  def self.run_spec(file)
    unless File.exist?(file)
      puts "#{file} does not exist"
      return
    end

    puts "Running #{file}"
    system "rspec #{file}"
  end
end

watch("spec/.*/*_spec.rb") do |match|
  WatchrActions.run_spec match[0]
end

watch("lib/(.*/.*).rb") do |match|
  # WatchrActions.run_spec "spec/lib/#{match[1]}_spec.rb"
  WatchrActions.run_spec "spec/modem_spec.rb"
end


