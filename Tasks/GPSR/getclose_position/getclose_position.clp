################################
#         DEXEC RULES
################################

(defrule getclose_position-check_getclose_position
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type getclose_position) (params ?position) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(getclose_position moving)
	?pnpdt_f2__ <-(getclose_position failed_speech_sent)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type check_getclose_position) (params ?position) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule getclose_position-not_moved
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type getclose_position) (params ?position) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(position (name ?position) (x ?x) (y ?y) (angle ?angle))
	(not
		(getclose_position moving)
	)
	=>
	(assert
		(getclose_position moving)
	)
	(send-command "mp_getclose" getclose_position (str-cat ?x " " ?y " " ?angle) 180000 )
)

(defrule getclose_position-succeeded
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type getclose_position) (params ?position) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(robot_info)
	(BB_answer "mp_getclose" getclose_position 1 ?new_location_str)
	(getclose_position moving)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task_status ?pnpdt_task__ successful)
		(robot_info (location ?position) (x (nth$ 1 (explode$ ?new_location_str))) (y (nth$ 2 (explode$ ?new_location_str))) (angle (nth$ 3 (explode$ ?new_location_str))))
	)
)

(defrule getclose_position-timedout_or_failed
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type getclose_position) (params ?position) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(getclose_position moving)
	(BB_answer "mp_getclose" getclose_position 0 ?)
	(not
		(getclose_position failed_speech_sent)
	)
	=>
	(assert
		(getclose_position failed_speech_sent)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params "It seems I couldn't manage to reach a location. I will check for problems and try again.") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

################################
#      FINALIZING RULES
################################

(defrule getclose_position-clear_flags
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type getclose_position) (params ?position) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(getclose_position $?)
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

(defrule getclose_position-cancel-failed_response
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type getclose_position) (params ?position) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(cancel_active_tasks)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(BB_answer "mp_stop" cancel_getclose_position 0 ?)
	=>
	(send-command "mp_stop" cancel_getclose_position "" 1000 )
)

(defrule getclose_position-cancel-start
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type getclose_position) (params ?position) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(cancel_active_tasks)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(waiting (symbol cancel_getclose_position))
	)
	(not
		(BB_answer "mp_stop" cancel_getclose_position ? ?)
	)
	=>
	(send-command "mp_stop" cancel_getclose_position "" 1000 )
)

(defrule getclose_position-cancel-successful-moving-speech
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type getclose_position) (params ?position) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(cancel_active_tasks)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(BB_answer "mp_stop" cancel_getclose_position 1 ?)
	?pnpdt_f1__ <-(getclose_position moving)
	=>
	(retract ?pnpdt_f1__)
)

