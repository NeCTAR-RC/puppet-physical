#!/usr/bin/env python3

# This is a wrapper for check_smart.pl
# It will find all disks on the host and run check_smart.pl on each of them
# and report back to nagios the worst response with a summary of the rest.
# Notice that for smartctl to function as properly, it needs to run as root.

from enum import IntEnum
import re
import subprocess


class NagiosRes(IntEnum):
    OK = 0
    WARNING = 1
    CRITICAL = 2
    UNKNOWN = 3


# For the summary
nagios_res_count = {
    "OK": 0,
    "WARNING": 0,
    "CRITICAL": 0,
    "UNKNOWN": 0,
}

try:
    serials = []
    # Scan
    drives = (
        subprocess.check_output(["sudo", "/usr/sbin/smartctl", "--scan-open"])
        .decode()
        .splitlines()
    )
    drives_check_smart = []
    worst_nagios_res = 0  # OK
    p_serial = re.compile(r"serial number: +(\b.*\b)", re.IGNORECASE)
    p_smart_support = re.compile(r"SMART support is: +(\b.*\b)", re.IGNORECASE)

    for drive in drives:

        # drives that smartctl can't open
        if re.match("^#", drive):
            continue

        # get the device name and device_type
        device, _, device_type, _ = drive.split(' ', 3)

        # in some situations smartctl might report the drives multiple times
        # we use the serial to check if we've seen the drive before
        smart_data = subprocess.check_output(
            ["sudo", "/usr/sbin/smartctl", "-i", device, "-d", device_type]
            ).decode()

        result = p_serial.search(smart_data)
        if result:
            # check for smart support
            result_smart_support = p_smart_support.search(smart_data)
            if result_smart_support:
                smart_unknown = "Unavailable - device lacks SMART capability"
                if result_smart_support.group(1) == smart_unknown:
                    continue

            serial = result.group(1)
            # seen the drive before
            if serial in serials:
                continue

            # first time seeing the drive
            serials.append(serial)
            try:
                # Run the external per disk nagios check
                nagios_check = subprocess.check_output(
                    [
                        "/usr/local/lib/nagios/plugins/check_smart.pl",
                        "-d",
                        device,
                        "-i",
                        device_type,
                    ]
                ).decode()
                # will only reach here if the return value from the check
                # is 0 (== "OK")
                nagios_res_count["OK"] += 1
            except subprocess.CalledProcessError as nagiosexc:
                nagios_check = nagiosexc.output.decode()

                # Critical is worse than Warning
                # Warning is worse than Unknown
                # Unknown is worse than OK

                # If the current return code is UNKNOWN
                # we only elevate the worst if it was OK
                if (nagiosexc.returncode == NagiosRes.UNKNOWN
                        and worst_nagios_res == NagiosRes.OK):
                    worst_nagios_res = NagiosRes.UNKNOWN
                # Else If the current return code is WARNING
                # we only elevate the worst if it was OK or UNKNOWN
                elif (nagiosexc.returncode == NagiosRes.WARNING
                        and (worst_nagios_res == NagiosRes.OK
                            or worst_nagios_res == NagiosRes.UNKNOWN)):
                    worst_nagios_res = NagiosRes.WARNING
                # Else If the current return code is CRITICAL
                # we always elevate as critical it the worst
                elif nagiosexc.returncode == NagiosRes.CRITICAL:
                    worst_nagios_res = NagiosRes.CRITICAL

                nagios_res_count[NagiosRes(nagiosexc.returncode).name] += 1

            drives_check_smart.append(nagios_check)

    # If there are no serials (drives) found return unknown
    if len(serials) == 0:
        print('UNKNOWN: No drives found.')

        exit(NagiosRes.UNKNOWN)

    else:
        print(f'{NagiosRes(worst_nagios_res).name}: SMART checks result: '
            f'{str(nagios_res_count)}')

        for item in drives_check_smart:
            print(item.strip())

        exit(worst_nagios_res)

except Exception as e:
    print(f'{NagiosRes.UNKNOWN.name}: Script failure: {e}')

    exit(NagiosRes.UNKNOWN)
