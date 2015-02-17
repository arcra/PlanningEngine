;					ENDING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule cubes_plan-success
	(task (id ?t) (plan ?planName) (action_type cubes_plan) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (cubes_goal $?))
	?ss <-(cubes_plan speech_sent)
	=>
	(retract ?ss)
	(assert
		(task_status ?t successful)
	)
)

(defrule cubes_plan-failure
	(task (id ?t) (plan ?planName) (action_type cubes_plan) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(chilren_status ?t failed)
	?ss <-(cubes_plan speech_sent)
	=>
	(retract ?ss)
	(assert
		(task_status ?t failed)
	)
)


;						EXECUTION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule cubes_plan-head
	(task (id ?t) (plan ?planName) (action_type cubes_plan) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (head_info (pan 0) (tilt 0)))
	(not (cubes_plan moving_head))
	=>
	(assert
		(task (plan ?planName) (action_type hd_lookat) (params 0 0) (step 1 $?steps) (parent ?t))
		(cubes_plan moving_head)
	)
)

(defrule cubes_plan-head-failed
	(task (id ?t) (plan ?planName) (action_type cubes_plan) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (head_info (pan 0) (tilt 0)))
	(cubes_plan moving_head)
	=>
	(assert
		(task (plan ?planName) (action_type hd_lookat) (params 0 0) (step 1 $?steps) (parent ?t))
	)
)

(defrule cubes_plan-head-succeeded
	(task (id ?t) (plan ?planName) (action_type cubes_plan) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(head_info (pan 0) (tilt 0))
	?f <-(cubes_plan moving_head)
	=>
	(retract ?f)
)

(defrule cubes_plan-speech
	(task (id ?t) (plan ?planName) (action_type cubes_plan) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(not (cubes_plan speech_sent))
	(not (cubes_plan speaking))
	=>
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I'm going to execute the plan:" ?planName)
			(step 1 $?steps) (parent ?t) )
		(cubes_plan speaking)
	)
)

(defrule cubes_plan-speech-finished
	(task (id ?t) (plan ?planName) (action_type cubes_plan) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	?f <-(cubes_plan speaking)
	(children_status ?t ?)
	=>
	(retract ?f)
	(assert
		(cubes_plan speech_sent)
	)
)

(defrule cubes_plan-do_cubes
	(task (id ?t) (plan ?planName) (action_type cubes_plan) (step $?steps))
	(active_task ?t)
	(not (task_status ?t ?))
	(not (cancel_active_tasks))

	(exists (cubes_goal $?))
	(cubes_plan speech_sent)
	(head_info (pan 0) (tilt 0))
	(not (cubes_plan moving_head))
	=>
	(assert
		(task (plan ?planName) (action_type cubes_do_cubes) (step 1 $?steps) (parent ?t))
	)
)
