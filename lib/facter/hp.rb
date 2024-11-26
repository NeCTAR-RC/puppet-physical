if FileTest.exist?("/usr/sbin/dmidecode")
  Facter.add('broken_hp') do
    confine :kernel => :linux
    %x{/usr/sbin/dmidecode | /bin/grep "Product Name" | /bin/grep "...Qh"}
    broken_hp = $?.exitstatus == 0 ? true : false
    setcode do
      broken_hp
    end
  end
end
if FileTest.exist?("/usr/bin/lspci")
  Facter.add('hp_raid') do
    confine :kernel => :linux
    %x{/usr/bin/lspci | grep "Hewlett-Packard Company Smart Array"}
    hp_raid = $?.exitstatus == 0 ? true : false
    setcode do
      hp_raid
    end
  end
end
