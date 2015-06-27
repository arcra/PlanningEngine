################################
#         DEXEC RULES
################################

(defrule deliver_in_position-failed
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type deliver_in_position) (params ?object ?position) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(deliver_in_position failed)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task_status ?pnpdt_task__ failed)
	)
)

(defrule deliver_in_position-get_object
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type deliver_in_position) (params ?object ?position) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(position (name ?position))
	(not
		(deliver_in_position handing_over)
	)
	(not
		(arm_info (grabbing ?object))
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type get_object) (params ?object) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule deliver_in_position-handover_object
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type deliver_in_position) (params ?object ?position) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(robot_info (location ?position))
	(arm_info (grabbing ?object))
	(not
		(deliver_in_position handing_over)
	)
	=>
	(assert
		(deliver_in_position handing_over)
		(task (plan ?pnpdt_planName__) (action_type handover_object) (params ?object) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule deliver_in_position-obj_taken-get_close_position
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type deliver_in_position) (params ?object ?position) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(position (name ?position))
	(arm_info (grabbing ?object))
	(not
		(robot_info (location ?position))
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type getclose_position) (params ?position) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule deliver_in_position-position_unknown
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type deliver_in_position) (params ?object ?position) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?object) (speech_name ?sp_name))
	(not
		(position (name ?position))
	)
	(not
		(deliver_in_position failed)
	)
	=>
	(assert
		(deliver_in_position failed)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "I don't know where the location " ?position " is. I cannot deliver the " ?sp_name ".")) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule deliver_in_position-succeeded
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type deliver_in_position) (params ?object ?position) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(deliver_in_position handing_over)
	?pnpdt_f1__ <-(arm_info (side ?side) (grabbing ?object) (position ?pos))
	=>
	(retract ?pnpdt_f1__)
	(assert
		(arm_info (side ?side) (grabbing nil) (position ?pos))
		(task_status ?pnpdt_task__ successful)
	)
)

################################
#      FINALIZING RULES
################################

(defrule deliver_in_position-clear-task_flags
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type deliver_in_position) (params ?object ?position) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(deliver_in_position $?)
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

