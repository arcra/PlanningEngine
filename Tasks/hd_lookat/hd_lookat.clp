(defrule hd_lookat-send_command
	(task (id ?t) (action_type hd_lookat) (params ?pan ?tilt))
	(active_task ?t)
	(not (task_status ?t ?) )
	(not (cancel_active_tasks))

	(or
		(not (head_info (pan ?pan)))
		(not (head_info (tilt ?tilt)))
	)
	(not (waiting (symbol hd_lookat)))
	(not (BB_answer "hd_lookat" hd_lookat ? ?))
	=>
	(send-command "hd_lookat" hd_lookat (str-cat ?pan " " ?tilt) 10000)
)

(defrule hd_lookat-failed_or_timedout
	(task (id ?t) (action_type hd_lookat) (params ?pan ?tilt))
	(active_task ?t)
	(not (task_status ?t ?) )
	(not (cancel_active_tasks))

	(or
		(not (head_info (pan ?pan)))
		(not (head_info (tilt ?tilt)))
	)
	(BB_answer "hd_lookat" hd_lookat 0 ?)
	=>
	(send-command "hd_lookat" hd_lookat (str-cat ?pan " " ?tilt) 10000)
)

(defrule hd_lookat-new_position
	(task (id ?t) (action_type hd_lookat) (params ?pan ?tilt))
	(active_task ?t)
	(not (task_status ?t ?) )
	(not (cancel_active_tasks))

	?hi <-(head_info (pan ?pan1) (tilt ?tilt1))
	(or
		(test (<> ?pan ?pan1))
		(test (<> ?tilt ?tilt1))
	)
	(BB_answer "hd_lookat" hd_lookat 1 ?)
	=>
	(retract ?hi)
	(assert
		(head_info (pan ?pan) (tilt ?tilt))
	)
)

(defrule hd_lookat-succeeded
	(task (id ?t) (action_type hd_lookat) (params ?pan ?tilt))
	(active_task ?t)
	(not (task_status ?t ?) )
	(not (cancel_active_tasks))

	(head_info (pan ?pan) (tilt ?tilt))
	=>
	(assert
		(task_status ?t successful)
	)
)


