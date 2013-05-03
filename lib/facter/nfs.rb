Facter.add('has_nfs_mounts') do
  confine :kernel => :linux
  %x{/bin/grep -v "^#" /etc/fstab | /usr/bin/awk {'print $3'} | /bin/grep nfs}
  has_nfs_mounts = $?.exitstatus == 0 ? true : false
  setcode do
    has_nfs_mounts
  end
end
