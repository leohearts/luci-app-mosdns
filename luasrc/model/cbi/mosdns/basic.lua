m = Map("mosdns")
m.title = translate("MosDNS")
m.description = translate("MosDNS is a 'programmable' DNS forwarder.")

m:section(SimpleSection).template = "mosdns/mosdns_status"

s = m:section(TypedSection, "mosdns")
s.addremove = false
s.anonymous = true

enable = s:option(Flag, "enabled", translate("Enable"))
enable.rmempty = false

configfile = s:option(ListValue, "configfile", translate("MosDNS Config File"))
configfile:value("/etc/mosdns/config.yaml", translate("Def Config"))
configfile:value("/etc/mosdns/config_custom.yaml", translate("Cus Config"))
configfile.default = "/etc/mosdns/config.yaml"

listenport = s:option(Value, "listen_port", translate("Listen port"))
listenport.datatype = "and(port,min(1))"
listenport.default = 5335
listenport.rmempty = false
listenport:depends( "configfile", "/etc/mosdns/config.yaml")

loglevel = s:option(ListValue, "log_level", translate("Log Level"))
loglevel:value("debug")
loglevel:value("info")
loglevel:value("warn")
loglevel:value("error")
loglevel.default = "error"
loglevel:depends( "configfile", "/etc/mosdns/config.yaml")

logfile = s:option(Value, "logfile", translate("MosDNS Log File"))
logfile.placeholder = "/dev/null"
logfile.default = "/dev/null"
logfile:depends( "configfile", "/etc/mosdns/config.yaml")

dnsforward = s:option(Value, "dns_forward", translate("Remote DNS"))
dnsforward.default = "tls://8.8.4.4"
dnsforward:value("tls://1.1.1.1", "1.1.1.1 (CloudFlare DNS)")
dnsforward:value("tls://8.8.8.8", "8.8.8.8 (Google DNS)")
dnsforward:value("tls://8.8.4.4", "8.8.4.4 (Google DNS)")
dnsforward:value("208.67.222.222", "208.67.222.222 (Open DNS)")
dnsforward:value("208.67.220.220", "208.67.220.220 (Open DNS)")
dnsforward:depends( "configfile", "/etc/mosdns/config.yaml")

cache_size = s:option(Value, "cache_size", translate("DNS Cache Size"))
cache_size.datatype = "and(uinteger,min(0))"
cache_size.rmempty = false
cache_size:depends( "configfile", "/etc/mosdns/config.yaml")

minimal_ttl = s:option(Value, "minimal_ttl", translate("Minimum TTL"))
minimal_ttl.datatype = "and(uinteger,min(1))"
minimal_ttl.datatype = "and(uinteger,max(3600))"
minimal_ttl.rmempty = false
minimal_ttl:depends( "configfile", "/etc/mosdns/config.yaml")

maximum_ttl = s:option(Value, "maximum_ttl", translate("Maximum TTL"))
maximum_ttl.datatype = "and(uinteger,min(1))"
maximum_ttl.rmempty = false
maximum_ttl:depends( "configfile", "/etc/mosdns/config.yaml")

redirect = s:option(Flag, "redirect", translate("Enable DNS Forward"), translate("Forward Dnsmasq Domain Name resolution requests to MosDNS"))
redirect:depends( "configfile", "/etc/mosdns/config.yaml")
redirect.default = true

adblock = s:option(Flag, "adblock", translate("Enable DNS ADblock"))
adblock:depends( "configfile", "/etc/mosdns/config.yaml")
adblock.default = true

config = s:option(TextValue, "manual-config")
config.description = translate("<font color=\"ff0000\"><strong>View the Custom YAML Configuration file used by this MosDNS. You can edit it as you own need.</strong></font>")
config.template = "cbi/tvalue"
config.rows = 25
config:depends( "configfile", "/etc/mosdns/config_custom.yaml")

function config.cfgvalue(self, section)
  return nixio.fs.readfile("/etc/mosdns/config_custom.yaml")
end

function config.write(self, section, value)
  value = value:gsub("\r\n?", "\n")
  nixio.fs.writefile("/etc/mosdns/config_custom.yaml", value)
end

return m
