require 'find'
Facter.add(:splunk_version) do
  confine :kernel => :linux
  setcode do
    command = ''
    path = ['/opt/splunk/bin','/opt/splunkforwarder/bin']
    path.each do |directory|
      if File.directory?(directory)
        Find.find(directory) do |file|
          command << file if !File::directory?(file) and File.executable?(file) and file =~ /.*\/splunk$/
        end
      end
    end
    if command != ''
      version = Facter::Core::Execution.execute("#{command} --no-prompt --answer-yes --accept-license version", :timeout => 30)
    elsif command == ''
      version = Facter::Core::Execution.execute('splunk --no-prompt --answer-yes --accept-license version', :timeout => 30)
    end
    if version
      version.match(/[\d+\.]+\s/).to_s
    else
      nil
    end
  end
end
