require 'thread'

if FileTest.exists?("/usr/sbin/dmidecode")
  %x{dmidecode -t 38 2>/dev/null|grep -q "IPMI Device"}
  has_ipmi = $?.exitstatus == 0 ? true : false
  Facter.add("has_ipmi") do
    confine :kernel => %w{Linux FreeBSD}
    setcode do
      has_ipmi
    end
  end
end

if FileTest.exists?("/usr/bin/ipmitool")
  if has_ipmi
    out = %x{ipmitool lan print 1 2>/dev/null}.chomp
    out.each_line do |line|
      larr = line.chomp.split(/ : /)
      if !larr[0].nil?
        larr[0].strip!
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

    out = %x{ipmitool mc info 2>/dev/null | head -n 10}.chomp
    out.each_line do |line|
      larr = line.chomp.split(/ : /)
      if !larr[0].nil?
        larr[0].strip!
        case larr[0]
        when "Manufacturer Name" then
          Facter.add("ipmi_manufacturer") do
            confine :kernel => %w{Linux FreeBSD}
            setcode do
              larr[1]
            end
          end
        when "Firmware Revision" then
          Facter.add("ipmi_firmware") do
            confine :kernel => %w{Linux FreeBSD}
            setcode do
              larr[1]
            end
          end
        end
      end
    end

   if FileTest.exists?("/usr/bin/host")
      # Do a dns lookup of possible subdomains of the dnsdomainname or variations
      # of the hostname to find the ipmi ip address - using ipmi/ilom/oob
      # e.g. if the hostname is rcc50.nectar.org.au, search for the following hostnames:
      # rcc50.ipmi.nectar.org.au
      # rcc50-ipmi.nectar.org.au
      # rcc50.ilom.nectar.org.au
      # rcc50-ilom.nectar.org.au
      # rcc50.oob.nectar.org.au
      # rcc50-oob.nectar.org.au
      # Stop on the first one that exists and skip the rest
      ipmi_lookup = ''
      hostname = %x{hostname}.chomp
      if !Facter.value(:ipmi_domain).nil?
        dnsdomainname = Facter.value(:ipmi_domain)
        command = "host #{hostname}.#{dnsdomainname} | grep \"has address\" | sed -e \"s/.*has address //g\" 2>/dev/null"
        ipmi_lookup = %x{#{command}}.chomp
      else
        dnsdomainname = %x{dnsdomainname}.chomp
        ['ipmi', 'ilom', 'oob'].each do |x|
          ['.', '-'].each do |sep|
            if ipmi_lookup != ''
              next
            end
            command = "host #{hostname}#{sep}#{x}.#{dnsdomainname} | grep \"has address\" | sed -e \"s/.*has address //g\" 2>/dev/null"
            ipmi_lookup = %x{#{command}}.chomp
          end
        end
      end
      if ipmi_lookup != ''
        Facter.add("ipmi_dns_lookup") do
          setcode do
            ipmi_lookup
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

    idrac = %x{ipmitool raw 0x2e 0x01 0xa2 0x02 0x00 2>/dev/null | cut -d " " -f 5}.chomp
    if !idrac.nil? and idrac != ''
      user = '2'
      idrac_user2_priv = %x{ipmitool raw 0x2e 0x02 0xa2 0x02 0x00 0x#{idrac} 0x04 0x0#{user} 0x00 0x00 0xFF 2>/dev/null | cut -d " " -f 13-16}.chomp
      if !idrac_user2_priv.nil?
        Facter.add("idrac_user2_priv") do
          confine :kernel => %w{Linux FreeBSD}
          setcode do
            idrac_user2_priv
          end
        end
      end
      idrac = %x{ipmitool raw 0x2e 0x01 0xa2 0x02 0x00 2>/dev/null | cut -d " " -f 5}.chomp
      if !idrac.nil? and idrac != ''
        user = '3'
        idrac_user3_priv = %x{ipmitool raw 0x2e 0x02 0xa2 0x02 0x00 0x#{idrac} 0x04 0x0#{user} 0x00 0x00 0xFF 2>/dev/null | cut -d " " -f 13-16}.chomp
        if !idrac_user3_priv.nil?
          Facter.add("idrac_user3_priv") do
            confine :kernel => %w{Linux FreeBSD}
            setcode do
              idrac_user3_priv
            end
          end
        end
      end
    end
  end
end
