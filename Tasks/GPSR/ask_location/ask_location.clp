################################
#         DEXEC RULES
################################

(defrule ask_location-clear_SV
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ask_location) (params ?question) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(ask_location speech_sent)
	)
	(not
		(BB_sv_updated "recognizedSpeech" $?)
	)
	(not
		(ask_location sv_cleared)
	)
	=>
	(assert
		(ask_location sv_cleared)
	)
)

(defrule ask_location-location_confirmed
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ask_location) (params ?question) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(ask_location speech_sent)
	?pnpdt_f1__ <-(BB_sv_updated "recognizedSpeech" ?count ?speech ? $?recognized)
	(location (name ?new_loc) (speech_name ?loc_name))
	(test (neq (str-index ?loc_name ?speech) FALSE))
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task_status ?pnpdt_task__ successful)
		(location_confirmed ?new_loc)
	)
)

(defrule ask_location-location_not_found
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ask_location) (params ?question) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(ask_location speech_sent)
	?pnpdt_f1__ <-(BB_sv_updated "recognizedSpeech" ?count ?speech ? $?recognized)
	(not
		(and
			(location (name ?new_loc) (speech_name ?loc_name))
			(test (neq (str-index ?loc_name ?speech) FALSE))
		)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(BB_sv_updated "recognizedSpeech" (- ?count 1) $?recognized)
	)
)

(defrule ask_location-speech
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ask_location) (params ?question) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(ask_location sv_cleared)
	(not
		(ask_location speech_sent)
	)
	=>
	(assert
		(ask_location speech_sent)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params ?question) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
	(setTimer 10000 ask_location)
)

(defrule ask_location-timedout
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ask_location) (params ?question) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(ask_location speech_sent)
	?pnpdt_f2__ <-(BB_timer ask_location)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
)

################################
#      FINALIZING RULES
################################

(defrule ask_location-clear-task_flags
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ask_location) (params ?question) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(ask_location $?)
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

