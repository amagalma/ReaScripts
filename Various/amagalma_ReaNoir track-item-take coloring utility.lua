curpos = reaper.GetCursorPosition()
retval, projectname = reaper.EnumProjects( 0, "" )
if projectname == "" then
  reaper.MB( "This action can be run only for saved projects.\nPlease, save the project and re-run." , "Action aborted", 0)
else
  file, err = io.open(projectname, "r")
  if not file then
	reaper.ShowMessageBox("Error reading project file:\n"..err, "Action aborted", 0)
	return 0
  end
  contents = file:read("*all")
  file:close()
  local questions = "Beats per minute:,Time Signature Numerator:,Time Signature Denominator:"
  local retval, retvals_csv = reaper.GetUserInputs("Specify time signature & tempo", 3, questions, "120,4,4")
  t={}
  for word in retvals_csv:gmatch("([^,]*)") do
   t[#t+1]=word
  end
  if retval == true then
    if tonumber(t[1]) and tonumber(t[2]) and tonumber(t[3]) then
	if string.match(contents, "TEMPOENVLOCKMODE 0") == "TEMPOENVLOCKMODE 0" then -- Timebase set to Time
	  reaper.Undo_BeginBlock() 
	  reaper.SetTempoTimeSigMarker(0, -1, curpos, -1, -1, tonumber(t[1]), tonumber(t[2]), tonumber(t[3]), false)
	elseif string.match(contents, "TEMPOENVLOCKMODE 1") == "TEMPOENVLOCKMODE 1" then -- Timebase set to Beats
	  local timesig_cnt = reaper.CountTempoTimeSigMarkers(0)
	  if timesig_cnt > 0 then
		for i=1,timesig_cnt do
		  _, timeposOut, _, _, _, _, _, _ = reaper.GetTempoTimeSigMarker(0,i)
		  if timeposOut > curpos then
			local msg = "While Tempo envelope is set to Beats, it is not advised to do this!\nIf you change the setting to Timebase, save the file - preferably with a different name - and re-run the action!\n                                               ~~~ Action aborted! ~~~ "
			reaper.ShowMessageBox(msg, "There are existing markers after cursor position!\n", 0)
			goto Finale
		  end
		end   
	  end
	  reaper.Undo_BeginBlock()
	  local beatsOut, measuresOut, _, _, _ = reaper.TimeMap2_timeToBeats(0, curpos)
	  reaper.SetTempoTimeSigMarker(0, -1, -1, measuresOut, beatsOut, tonumber(t[1]), tonumber(t[2]), tonumber(t[3]), false)
	end
	reaper.Undo_EndBlock("Insert time signature/tempo change marker at edit cursor",-1)
	::Finale::
	reaper.UpdateTimeline() 
    else
	 reaper.ShowMessageBox("Please, enter numbers!", "Action aborted", 0)
    end
  end
end
