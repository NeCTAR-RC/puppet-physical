Facter.add('has_igb') do
  confine :kernel => :linux
  %x{cat /proc/modules | grep "^igb"}
  has_igb = $?.exitstatus == 0 ? true : false
  setcode do
    has_igb
  end
end
