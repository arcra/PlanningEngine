;					ENDING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule cubes_plan-success
	(task (id ?t) (plan ?planName) (action_type cubes_plan) (step $?steps))
	(active_task ?t)
	(not 
		(task_status ?t ?)
	)
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
	(not 
		(task_status ?t ?)
	)
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
(defrule cubes_plan-speech
	(task (id ?t) (plan ?planName) (action_type cubes_plan) (step $?steps))
	(active_task ?t)
	(not 
		(task_status ?t ?)
	)
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
	(not 
		(task_status ?t ?)
	)
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
	(not 
		(task_status ?t ?)
	)
	(not (cancel_active_tasks))

	(exists (cubes_goal $?))
	(cubes_plan speech_sent)
	=>
	(assert
		(task (plan ?planName) (action_type cubes_do_cubes) (step 1 $?steps) (parent ?t))
	)
)
