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
  # Do a dns lookup of both e.g. rcc50-ilom.nectar.org.au and rcc50-ipmi.nectar.org.au
  # Prefer the -ipmi version if it exists
  ipmi_lookup = %x{host `hostname`-ipmi.`dnsdomainname` | grep "has address" | sed -e "s/.*has address //g" 2>/dev/null}.chomp
  ilom_lookup = %x{host `hostname`-ilom.`dnsdomainname` | grep "has address" | sed -e "s/.*has address //g" 2>/dev/null}.chomp
  Facter.add("ipmi_dns_lookup") do
    setcode do
      if ipmi_lookup != ''
        ipmi_lookup
      else
        if ilom_lookup != ''
          ilom_lookup
        end
      end
    end
  end

  %x{ipmitool raw 0x06 0x52 0x07 0x70 0x01 0x0c 2>/dev/null}
  h8dgt_ps1 = $?.exitstatus == 0 ? true : false
  %x{ipmitool raw 0x06 0x52 0x07 0x72 0x01 0x0c 2>/dev/null}
  h8dgt_ps2 = $?.exitstatus == 0 ? true : false
  %x{ipmitool raw 0x06 0x52 0x07 0x74 0x01 0x0c 2>/dev/null}
  h8dgt_ps3 = $?.exitstatus == 0 ? true : false
  %x{ipmitool raw 0x06 0x52 0x07 0x78 0x01 0x78 2>/dev/null}
  h8dgt_pm_ps1 = $?.exitstatus == 0 ? true : false
  %x{ipmitool raw 0x06 0x52 0x07 0x7a 0x01 0x78 2>/dev/null}
  h8dgt_pm_ps2 = $?.exitstatus == 0 ? true : false
  %x{ipmitool raw 0x06 0x52 0x07 0x7c 0x01 0x78 2>/dev/null}
  h8dgt_pm_ps3 = $?.exitstatus == 0 ? true : false

  Facter.add("h8dgt_ps1") do
    confine :kernel => %w{Linux FreeBSD}
    setcode do
      h8dgt_ps1
    end
  end
  Facter.add("h8dgt_ps1") do
    confine :kernel => %w{Linux FreeBSD}
    setcode do
      h8dgt_ps1
    end
  end
  Facter.add("h8dgt_ps2") do
    confine :kernel => %w{Linux FreeBSD}
    setcode do
      h8dgt_ps2
    end
  end
  Facter.add("h8dgt_ps3") do
    confine :kernel => %w{Linux FreeBSD}
    setcode do
      h8dgt_ps3
    end
  end
  Facter.add("h8dgt_pm_ps1") do
    confine :kernel => %w{Linux FreeBSD}
    setcode do
      h8dgt_pm_ps1
    end
  end
  Facter.add("h8dgt_pm_ps2") do
    confine :kernel => %w{Linux FreeBSD}
    setcode do
      h8dgt_pm_ps2
    end
  end
  Facter.add("h8dgt_pm_ps3") do
    confine :kernel => %w{Linux FreeBSD}
    setcode do
      h8dgt_pm_ps3
    end
  end


end
