local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local src = Modules:WaitForChild('src')
local logger = require(src.utils.Logger)

local SoundTriggerManager = {}

local sounds =
	{
		'Effect_Mouse',
		'Effect_Scream1',
		'Effect_Scream2',
		'Effect_Scream3',
		'Effect_Scream4',
		'Effect_Scream5',
		'Effect_Chainsaw1',
		'Effect_Chainsaw2',
		'Effect_Whisper1',
		'Effect_Whisper2',
		'Effect_Whisper3',
		'Effect_ISeeYou',
		'Effect_Fart',
		'Effect_Barking',
		'Effect_WindHowl',
		'Effect_WolfHowl',
		'Effect_Snarl',
		'Effect_WolfSnarl',
		'Effect_ZombieSnarl',
	}

local cachedSounds = {}
function SoundTriggerManager:makeSound(triggerPart, waitFor, playAudio)
	local sound = cachedSounds[triggerPart]
	if not sound then
		sound = sounds[math.random(1, #sounds)]
		cachedSounds[triggerPart] = sound
	end

	logger:w('Player played random sound', sound)
	playAudio(sound, triggerPart)

	wait(waitFor)
end

return SoundTriggerManager