require 'thread'

%x{dmidecode -t 38 2>/dev/null|grep -q "IPMI Device"}
has_ipmi = $?.exitstatus == 0 ? true : false
Facter.add("has_ipmi") do
  confine :kernel => %w{Linux FreeBSD}
  setcode do
    has_ipmi
  end
end

if has_ipmi
  out = %x{ipmitool lan print 1 2>/dev/null}.chomp
  out.each_line do |line|
    larr = line.chomp.split(/ : /)
    if !larr[0].nil?
      larr[0].rstrip!.lstrip!
      case larr[0]
      when "IP Address Source" then
        Facter.add("ipmi_ipsource") do
          confine :kernel => %w{Linux FreeBSD}
          setcode do
            larr[1]
          end
        end
      when "IP Address" then
        Facter.add("ipmi_ipaddress") do
          confine :kernel => %w{Linux FreeBSD}
          setcode do
            larr[1]
          end
        end
      when "Subnet Mask" then
        Facter.add("ipmi_netmask") do
          confine :kernel => %w{Linux FreeBSD}
          setcode do
            larr[1]
          end
        end
      when "MAC Address" then
        Facter.add("ipmi_macaddress") do
          confine :kernel => %w{Linux FreeBSD}
          setcode do
            larr[1]
          end
        end
      when "Default Gateway IP" then
        Facter.add("ipmi_gateway") do
          confine :kernel => %w{Linux FreeBSD}
          setcode do
            larr[1]
          end
        end
      end
    end
  end
end
