################################
#         DEXEC RULES
################################

(defrule recover_object-speech
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type recover_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(arm_info (side ?side) (grabbing ?object) (position ?pos) (enabled ?en))
	(item (name ?object) (speech_name ?item_name))
	(not
		(recover_object speech_sent)
	)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(recover_object speech_sent)
		(arm_info (side ?side) (grabbing nil) (position ?pos) (enabled ?en))
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "I think I dropped the " ?item_name)) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule recover_object-take_handover
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type recover_object) (params ?object) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(recover_object speech_sent)
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type take_handover) (params ?object) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

################################
#      FINALIZING RULES
################################

################################
#      CANCELING RULES
################################

