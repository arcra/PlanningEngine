################################
#         DEXEC RULES
################################

(defrule getclose_location-check_getclose_location
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type getclose_location) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(getclose_location moving)
	?pnpdt_f2__ <-(getclose_location speech_sent)
	?pnpdt_f3__ <-(getclose_location failed_speech_sent)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__ ?pnpdt_f3__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type check_getclose_location) (params ?location) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule getclose_location-not_moved
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type getclose_location) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(getclose_location speech_sent)
	(not
		(getclose_location moving)
	)
	=>
	(assert
		(getclose_location moving)
	)
	(send-command "mp_getclose" getclose_location ?location 180000 )
)

(defrule getclose_location-start_speech
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type getclose_location) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(location (name ?location) (speech_name ?sp_name))
	(not
		(getclose_location speech_sent)
	)
	=>
	(assert
		(getclose_location speech_sent)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "I'm going to the " ?sp_name)) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule getclose_location-succeeded
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type getclose_location) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(getclose_location moving)
	?pnpdt_f2__ <-(getclose_location speech_sent)
	?pnpdt_f3__ <-(robot_info (x ?x) (y ?y) (angle ?ang))
	?pnpdt_f4__ <-(getclose_location succeeded)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__ ?pnpdt_f3__ ?pnpdt_f4__)
	(assert
		(robot_info (location ?location) (x ?x) (y ?y) (angle ?ang))
		(task_status ?pnpdt_task__ successful)
	)
)

(defrule getclose_location-succeeded-speech
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type getclose_location) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(getclose_location moving)
	(getclose_location speech_sent)
	(location (name ?location) (speech_name ?sp_name))
	(BB_answer "mp_getclose" getclose_location 1 =(str-cat "" ?location))
	(not
		(getclose_location succeeded)
	)
	=>
	(assert
		(getclose_location succeeded)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "I arrived to the " ?sp_name)) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule getclose_location-timedout_or_failed
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type getclose_location) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(getclose_location moving)
	(getclose_location speech_sent)
	(BB_answer "mp_getclose" getclose_location 0 =(str-cat "" ?location))
	(not
		(getclose_location failed_speech_sent)
	)
	=>
	(assert
		(getclose_location failed_speech_sent)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params "It seems I couldn't manage to get there. I will check for problems and try again.") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

################################
#      FINALIZING RULES
################################

(defrule getclose_location-clear_flags
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type getclose_location) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(getclose_location $?)
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

(defrule getclose_location-cancel-failed_response
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type getclose_location) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(cancel_active_tasks)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(BB_answer "mp_stop" cancel_getclose_location 0 ?)
	=>
	(send-command "mp_stop" cancel_getclose_location "" 1000 )
)

(defrule getclose_location-cancel-start
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type getclose_location) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(cancel_active_tasks)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(waiting (symbol cancel_getclose_location))
	)
	(not
		(BB_answer "mp_stop" cancel_getclose_location ? ?)
	)
	=>
	(send-command "mp_stop" cancel_getclose_location "" 1000 )
)

(defrule getclose_location-cancel-successful-moving-speech
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type getclose_location) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(cancel_active_tasks)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(getclose_location speech_sent)
	(BB_answer "mp_stop" cancel_getclose_location 1 ?)
	?pnpdt_f2__ <-(getclose_location moving)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
)

(defrule getclose_location-cancel-successful-not_moving-speech
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type getclose_location) (params ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(cancel_active_tasks)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(BB_answer "mp_stop" cancel_getclose_location 1 ?)
	?pnpdt_f1__ <-(getclose_location speech_sent)
	(not
		(getclose_location moving)
	)
	=>
	(retract ?pnpdt_f1__)
)

