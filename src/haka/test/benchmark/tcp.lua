local ipv4 = require('protocol/ipv4')
local tcp = require('protocol/tcp')

haka.rule{
	on = haka.dissectors.tcp.events.receive_packet,
	eval = function (pkt)
	end
}
