ShowHelpNotification = function(msg)
	AddTextEntry('rLocationHelpNotif', msg)
	DisplayHelpTextThisFrame('rLocationHelpNotif', false)
end

ShowNotification = function(msg)
	AddTextEntry('rLocationNotif', msg)
	BeginTextCommandThefeedPost('rLocationNotif')
	EndTextCommandThefeedPostTicker(false, false)
end