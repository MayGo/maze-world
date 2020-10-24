--[[
	This file specifies the protocol for communication between the client and
	server.

	It uses 'Typer' as a way to encode type signatures into the remotes, which
	are checked on both ends. This should be enough to verify that well-behaved
	clients are obeying the API contract, and acts as a first-pass guard against
	malicious clients.

	Both the client and server must implement the correct points of this API.
	Each remote is only one-way to prevent low-hanging fruit exploits related to
	causing a server to yield forever when using RemoteFunction objects.

	The server will automatically generate a RemoteEvent object for every object
	in this table.

	The client will automatically wait for every event to exist and connect to
	each of them.
]] local Typer
= require(script.Parent.Typer)

return {
	fromClient = {
		clientStart = { arguments = Typer.args() },
		startRoomGame = { arguments = Typer.args({ 'roomId', Typer.type('string') }) },
		endRoomGame = { arguments = Typer.args({ 'roomId', Typer.type('string') }) },
		pickUpItem = { arguments = Typer.args({ 'itemId', Typer.type('string') }) },
		pickUpCoin = { arguments = Typer.args({ 'itemId', Typer.type('string') }) },
		dropItem = { arguments = Typer.args({ 'itemId', Typer.type('string') }) },
		buyItem = { arguments = Typer.args({ 'productId', Typer.type('string') }) },
		equipItem = { arguments = Typer.args({ 'productId', Typer.type('string') }) },
		roomVote = {
			arguments = Typer.args(
				{ 'roomId', Typer.type('string') },
				{ 'vote', Typer.type('string') }
			),
		},
		startGhosting = { arguments = Typer.args() },
		stopGhosting = { arguments = Typer.args() },
		unequipItem = { arguments = Typer.args({ 'productId', Typer.type('string') }) },
		unequipAll = { arguments = Typer.args() },
	},
	fromServer = {
		initialStoreState = { arguments = Typer.args({ 'state', Typer.any() }) },
		clientStartGhosting = { arguments = Typer.args() },
		clientPlaySound = {
			arguments = Typer.args(
				{ 'soundName', Typer.type('string') },
				{ 'triggerPart', Typer.any() }
			),
		},
		clientPlayBackgroundSound = {
			arguments = Typer.args({ 'soundName', Typer.type('string') }),
		},
		storeAction = { arguments = Typer.args({ 'action', Typer.type('table') }) },
	},
}