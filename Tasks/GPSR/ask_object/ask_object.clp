################################
#         DEXEC RULES
################################

(defrule ask_object-clear_SV
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ask_object) (params ?question) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(ask_object speech_sent)
	)
	(not
		(BB_sv_updated "recognizedSpeech" $?)
	)
	(not
		(ask_object sv_cleared)
	)
	=>
	(assert
		(ask_object sv_cleared)
	)
)

(defrule ask_object-object_confirmed
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ask_object) (params ?question) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(ask_object speech_sent)
	?pnpdt_f1__ <-(BB_sv_updated "recognizedSpeech" ?count ?speech ? $?recognized)
	(item (name ?new_obj) (speech_name ?item_name))
	(test (neq (str-index ?item_name ?speech) FALSE))
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task_status ?pnpdt_task__ successful)
		(object_confirmed ?new_obj)
	)
)

(defrule ask_object-object_not_found
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ask_object) (params ?question) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(ask_object speech_sent)
	?pnpdt_f1__ <-(BB_sv_updated "recognizedSpeech" ?count ?speech ? $?recognized)
	(not
		(and
			(item (name ?new_obj) (speech_name ?item_name))
			(test (neq (str-index ?item_name ?speech) FALSE))
		)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(BB_sv_updated "recognizedSpeech" (- ?count 1) $?recognized)
	)
)

(defrule ask_object-speech
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ask_object) (params ?question) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(ask_object sv_cleared)
	(not
		(ask_object speech_sent)
	)
	=>
	(assert
		(ask_object speech_sent)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params ?question) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
	(setTimer 10000 ask_object)
)

(defrule ask_object-timedout
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ask_object) (params ?question) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(ask_object speech_sent)
	?pnpdt_f2__ <-(BB_timer ask_object)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
)

################################
#      FINALIZING RULES
################################

(defrule ask_object-clear-task_flags
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type ask_object) (params ?question) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(ask_object $?)
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

