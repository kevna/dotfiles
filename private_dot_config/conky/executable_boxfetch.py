#!/usr/bin/env python3
import sys
import csv
import tempfile
import os
import argparse

def addDefaults(data, defaults, ignores = [], keepBlanks = True, blanks = (None, "")):
    for k, v in defaults.items():
        if v in ignores:
            continue
        shouldKeepBlanks = False
        if isinstance(keepBlanks, list):
            if k in keepBlanks:
                shouldKeepBlanks = True
        else:
            shouldKeepBlanks = keepBlanks
        if shouldKeepBlanks or (v not in blanks):
            data.setdefault(k, v)
    return data

import fabric.operations
from fabric.api import hide, settings, execute
class RemoteError(Exception):
    pass
class Remote(object):
    DEFAULTCONFIG = {
            "timeout": 5,
            "abort_exception": RemoteError,
            "abort_on_prompts": True, # If this is a manual script then we can override this, but automatic scripts shouldn't hang on a prompt.
            "parallel": True,
            "skip_bad_hosts": False, # Critical we don't ignore problem hosts
            "connection_attempts": 2,
            "command_timeout": 3600, # Same as RpcClient by default
            "system_known_hosts": "/etc/ssh/ssh_known_hosts", # Our global list of known hosts. Ideally should be read directly from the ssh_config_path, but since it's not actually defined in there, fabric doesn't know. NOTE paramiko can't cope if there is more than one host key for the same IP in this file - so virtual ips won't work properly and it may have problems if we re-install a box and temporarily have both keys in there. Not much we can do about that except (a) fix paramiko or (b) temporarily disable this check
            "disable_known_hosts": True, # NOTE This IS correct! disable_known_hosts only disables loading the individual user known_hosts files (at least in Fabric 1.14.0). The system_known_hosts (above) is still loaded (which is what we want) with this flag set to True
            "reject_unknown_hosts": True,  # We need to this to ensure we don't auto-add unknown hosts which is the default (insecure!) fabric behaviour! It also should mean we validate against the global hosts defined in system_known_hosts
            "use_ssh_config": True, # We want to use the system configured settings (see ssh_config_path)
            "ssh_config_path": "/etc/ssh/ssh_config", # Unfortunately fabric only reads some of the settings in here: http://docs.fabfile.org/en/1.13/usage/execution.html#ssh-config
            "ok_ret_codes": (0,),
            }
    def __init__(self, hosts, config = {}):
        self.hosts = hosts
        addDefaults(config, self.DEFAULTCONFIG)
        self.config = config
        self.expectedError = "Could not chdir to home directory /home/%s: No such file or directory" % config["user"] # This is because there are no home directories on production

    def localIp(self, ifname):
        import socket
        import fcntl
        import struct
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        return socket.inet_ntoa(fcntl.ioctl(
            s.fileno(),
            0x8915,  # SIOCGIFADDR
            struct.pack('256s', ifname[:15].encode("utf-8"))
        )[20:24])

    def runCommand(self, command, sudo = False):
        method = fabric.operations.run
        if sudo:
            method = fabric.operations.sudo
        with settings(hide("output", "running"), **self.config):
            results = execute(method, command, hosts = self.hosts)
        for host, output in results.items():
            # status = output.return_code
            if output.startswith(self.expectedError):
                results[host] = output.replace(self.expectedError,"").strip()
        return results


class BoxFetch(object):
    FIELDNAMES = ["boxid", "loadavg", "connections", "shortstatus"]
    ALLBOXES = ["26", "27", "28", "9", "42", "43", "44", "45", "3", "19", "23", "29", "30", "4", "5", "6", "7", "8", "13", "14", "15", "18", "24", "40", "41"]
    def __init__(self, args):
        self.options = self.parseArgs(args)
        try:
            self.validateArguments()
        except AssertionError as e:
            sys.exit(e)

    def parseArgs(self, args):
        p = argparse.ArgumentParser()
        p.add_argument("-u", "--username", help = "ssh username")
        p.add_argument("-p", "--password", help = "ssh password")
        p.add_argument("boxes", nargs="*", default = self.ALLBOXES, help = "boxes to connect to")
        return vars(p.parse_args(args))

    def validateArguments(self):
        spuriousBoxes = set(self.options["boxes"]).difference(self.ALLBOXES)
        assert not spuriousBoxes, "unsupported boxes %s" % list(spuriousBoxes)

    def getHosts(self):
        return ["10.4.%d.1" % int(box) for box in self.options["boxes"]]

    def allStatus(self):
        hosts = self.getHosts()
        remote = Remote(hosts, config = {
                "user": self.options["username"],
                "password": self.options["password"],
                })
        remoteStats = {
                "loadavg": ("cat /proc/loadavg", {}),
                "connections": ("w -hi | awk '{if($3 !~ /%s$/) {print $3}}' | sort | uniq -c | wc -l" % remote.localIp("tun0").replace(".", "\."), {}),# unique connections other than this box
                "shortstatus": ("shortstatus.py --show-updates --colour=conky 2>/dev/null || shortstatus.sh", {"sudo": True}),
                }
        results = {}
        for key, (command, kwargs) in remoteStats.items():
            results[key] = remote.runCommand(command, **kwargs)
        for host in hosts:
            structure = {
                    "boxid": host.split(".")[2],
                    }
            for key in remoteStats.keys():
                structure[key] = results[key][host]
            yield structure

    def writeCsv(self, rows):
        with tempfile.NamedTemporaryFile(mode = "w",  delete = False) as tmp:
            writer = csv.DictWriter(tmp, fieldnames = self.FIELDNAMES)
            writer.writeheader()
            for row in rows:
                writer.writerow(row)
        os.rename(tmp.name, os.path.expanduser("~/.config/conky/boxstat.csv"))


    def main(self):
        self.writeCsv(self.allStatus())


if __name__ == "__main__":
    BoxFetch(sys.argv[1:]).main()

