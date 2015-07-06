################################
#         DEXEC RULES
################################

(defrule wait_door-0-check_module_is_connected
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_door) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(wait_door module_is_connected)
	)
	(not
		(checked module_is_connected MVN_PLN)
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type check_module_is_connected) (params MVN_PLN) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule wait_door-0-module_connected
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_door) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(checked module_is_connected MVN_PLN)
	(module (name MVN_PLN) (status connected))
	=>
	(assert
		(wait_door module_is_connected)
	)
)

(defrule wait_door-0-module_not_connected
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_door) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(checked module_is_connected MVN_PLN)
	(module (name MVN_PLN) (status disconnected))
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type wait_user_start_module) (params MVN_PLN) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule wait_door-1-door_status_unknown
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_door) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(wait_door module_is_connected)
	(not
		(timer_sent wait_door_sleep)
	)
	(not
		(wait_door success)
	)
	(not
		(BB_answer "mp_obstacle" wait_door ? ?)
	)
	(not
		(waiting (symbol wait_door))
	)
	=>
	(send-command "mp_obstacle" wait_door "door"  )
)

(defrule wait_door-2-door_closed
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_door) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(wait_door module_is_connected)
	?pnpdt_f1__ <-(BB_answer "mp_obstacle" wait_door 1 ?)
	(not
		(timer_sent wait_door_sleep)
	)
	=>
	(retract ?pnpdt_f1__)
	(setTimer 2000 wait_door_sleep)
)

(defrule wait_door-2-door_open
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_door) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(wait_door module_is_connected)
	?pnpdt_f1__ <-(BB_answer "mp_obstacle" wait_door 0 ?)
	(not
		(wait_door success)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(wait_door success)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params "I can see now that the door is open.") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule wait_door-3-door_closed-check_again
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_door) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(BB_timer wait_door_sleep)
	(wait_door module_is_connected)
	(not
		(wait_door success)
	)
	=>
	(retract ?pnpdt_f1__)
	(send-command "mp_obstacle" wait_door "door"  )
)

(defrule wait_door-speech-send_again
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_door) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(wait_door module_is_connected)
	?pnpdt_f1__ <-(BB_timer wait_door_speech)
	(wait_door speech_sent)
	(not
		(wait_door success)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params "I'm still waiting for the door to be opened.") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
	(setTimer 10000 wait_door_speech)
)

(defrule wait_door-speech-start
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_door) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(wait_door module_is_connected)
	(not
		(wait_door success)
	)
	(not
		(wait_door speech_sent)
	)
	=>
	(assert
		(wait_door speech_sent)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params "I am waiting for the door to be opened.") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
	(setTimer 10000 wait_door_speech)
)

(defrule wait_door-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_door) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(wait_door success)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

################################
#      FINALIZING RULES
################################

(defrule wait_door-clear-task_flags
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type wait_door) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(wait_door $?)
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

