################################
#         DEXEC RULES
################################

(defrule put_object_in_location-obj_NOT_tkn-take_object
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type put_object_in_location) (params ?object ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?object) (location ?loc2))
	(test (neq ?loc2 ?location))
	(not
		(arm_info (grabbing ?object))
	)
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type get_object) (params ?object) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule put_object_in_location-obj_tken-rbot_NOT_lctd-object_taken-robot_not_located-getclose_location
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type put_object_in_location) (params ?object ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(robot_info (location ?loc2))
	(arm_info (grabbing ?object))
	(test (neq ?loc2 ?location))
	=>
	(assert
		(task (plan ?pnpdt_planName__) (action_type getclose_location) (params ?location) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule put_object_in_location-obj_tken-rbot_lctd-dropping
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type put_object_in_location) (params ?object ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(arm_info (grabbing ?object))
	(robot_info (location ?location))
	(not
		(put_object_in_location dropping)
	)
	=>
	(assert
		(put_object_in_location dropping)
		(task (plan ?pnpdt_planName__) (action_type drop) (params ?object) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule put_object_in_location-obj_tken-rbot_lctd-dropping-failed
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type put_object_in_location) (params ?object ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(arm_info (grabbing ?object))
	(put_object_in_location dropping)
	(item (name ?object) (speech_name ?sp_name))
	(not
		(put_object_in_location drop_failed speaking)
	)
	=>
	(assert
		(put_object_in_location drop_failed speaking)
		(task (plan ?pnpdt_planName__) (action_type spg_say) (params (str-cat "I could not drop the " ?sp_name ". I will try again.")) (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

(defrule put_object_in_location-obj_tken-rbot_lctd-dropping-failed-spoken
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type put_object_in_location) (params ?object ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(arm_info (grabbing ?object))
	?pnpdt_f1__ <-(put_object_in_location dropping)
	?pnpdt_f2__ <-(put_object_in_location drop_failed speaking)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
)

(defrule put_object_in_location-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type put_object_in_location) (params ?object ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(item (name ?object) (location ?location))
	(not
		(arm_info (grabbing ?object))
	)
	=>
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

################################
#      FINALIZING RULES
################################

(defrule put_object_in_location-clean-dropping
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type put_object_in_location) (params ?object ?location) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(put_object_in_location $?)
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

