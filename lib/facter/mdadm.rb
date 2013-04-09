Facter.add('mdadm_devices') do
  confine :kernel => :linux
  setcode do
    devices = []
    if FileTest.exists?('/proc/mdstat')
      File.open('/proc/mdstat', 'r') do |f|
        while line = f.gets
          if line =~ /^(md\d+)/
            devices.push($1)
          end
        end
      end
    end
    devices.sort.join(',')
  end
end
