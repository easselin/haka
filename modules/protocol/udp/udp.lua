-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

local class = require("class")
local ipv4 = require("protocol/ipv4")

local function compute_checksum(pkt)
	local checksum = ipv4.inet_checksum()

	-- UDP checksum is computed using a
	-- pseudo-header made of some fields
	-- of ipv4 header

	-- size of the udp pseudo-header
	local pseudo_header = haka.vbuffer_allocate(12)
	-- source and destination ipv4 addresses
	pseudo_header:sub(0,4):setnumber(pkt.src.packed)
	pseudo_header:sub(4,4):setnumber(pkt.dst.packed)
	-- padding (null byte)
	pseudo_header:sub(8,1):setnumber(0)
	-- UDP protocol number
	pseudo_header:sub(9,1):setnumber(0x11)
	-- UDP message length (header + data)
	pseudo_header:sub(10,2):setnumber(pkt.length)
	checksum:process(pseudo_header)

	checksum:process(pkt._payload)
	return checksum:reduce()
end

local udp_dissector = haka.dissector.new{
	type = haka.helper.PacketDissector,
	name = 'udp'
}

udp_dissector.grammar = haka.grammar.new("udp", function ()
	packet = record{
		field('srcport',   number(16)),
		field('dstport',   number(16)),
		field('length',    number(16))
			:validate(function (self) self.len = 8 + #self.payload end),
		field('checksum',  number(16))
			:validate(function (self)
				self.checksum = 0
				self.checksum = compute_checksum(self)
			end),
		field('payload',   bytes())
	}

	export(packet)
end)

function udp_dissector.method:forge_payload(pkt, payload)
	if payload.modified then
		self.checksum = nil
	end

	self:validate()
end

function udp_dissector.method:verify_checksum()
	return compute_checksum(self) == 0
end

function udp_dissector.method:create(pkt, init)
	if not init then init = {} end
	if not init.length then init.length = 8 end
	pkt.proto = 17

	class.super(udp_dissector).create(self, pkt, init, init.length)
end

function udp_dissector.method:install_criterion()
	return { srcport = self.srcport, dstport = self.dstport }
end

haka.policy {
	name = "udp",
	on = haka.dissectors.ipv4.policies.next_dissector,
	proto = 17,
	action = haka.dissectors.udp.install
}
