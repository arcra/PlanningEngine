################################
#         DEXEC RULES
################################

(defrule attend_person-1-save_position
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type attend_person) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(position (name =(sym-cat AP_ ?pnpdt_task__)))
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type save_position) (params (sym-cat AP_ ?pnpdt_task__)) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule attend_person-2-wait_for_user_instruction
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type attend_person) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(position (name =(sym-cat AP_ ?pnpdt_task__)))
	(not
		(attend_person ?pnpdt_task__ finished)
	)
	(not
		(attend_person ?pnpdt_task__ executing)
	)
	=>
	(assert
		(attend_person ?pnpdt_task__ executing)
		(task (plan ?pnpdt_planName__) (action_type wait_for_user_instruction) (params "") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule attend_person-3-executed-in_place
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type attend_person) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(attend_person ?pnpdt_task__ executing)
	(robot_info (location =(sym-cat AP_ ?pnpdt_task__)))
	(position (name =(sym-cat AP_ ?pnpdt_task__)))
	(not
		(attend_person ?pnpdt_task__ finished)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params "Let me know if you want me to do something else.") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule attend_person-3-executed-not_in_place
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type attend_person) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(attend_person ?pnpdt_task__ executing)
	(position (name =(sym-cat AP_ ?pnpdt_task__)))
	(not
		(attend_person ?pnpdt_task__ finished)
	)
	(not
		(robot_info (location =(sym-cat AP_ ?pnpdt_task__)))
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type getclose_position) (params (sym-cat AP_ ?pnpdt_task__)) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule attend_person-4-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type attend_person) (params "") (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(attend_person ?pnpdt_task__ finished)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

################################
#      FINALIZING RULES
################################

################################
#      CANCELING RULES
################################

