if FileTest.exists?("/usr/bin/lspci")
  has_infiniband = Facter::Util::Resolution.exec('/usr/bin/lspci | grep "InfiniBand: Mellanox" | wc -l').chomp
  Facter.add(:has_infiniband) do
    setcode do
      if has_infiniband != "0"
        true
      else
        false
      end
    end
  end
end
