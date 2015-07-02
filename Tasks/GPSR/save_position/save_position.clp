################################
#         DEXEC RULES
################################

(defrule save_position-save_position-no_prev
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type save_position) (params ?symbol) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(BB_answer "mp_position" ?symbol 1 ?position)
	?pnpdt_f2__ <-(robot_info (status ?status))
	(not
		(position (name ?symbol))
	)
	(not
		(save_position saved)
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
	(assert
		(position (name ?symbol) (x (nth$ 1 (explode$ ?position))) (y (nth$ 2 (explode$ ?position))) (angle (nth$ 3 (explode$ ?position))))
		(robot_info (location custom) (status ?status) (x (nth$ 1 (explode$ ?position))) (y (nth$ 2 (explode$ ?position))) (angle (nth$ 3 (explode$ ?position))))
		(save_position saved)
	)
)

(defrule save_position-save_position-prev
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type save_position) (params ?symbol) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(position (name ?symbol))
	?pnpdt_f2__ <-(BB_answer "mp_position" ?symbol 1 ?position)
	?pnpdt_f3__ <-(robot_info (status ?status))
	(not
		(save_position saved)
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__ ?pnpdt_f3__)
	(assert
		(position (name ?symbol) (x (nth$ 1 (explode$ ?position))) (y (nth$ 2 (explode$ ?position))) (angle (nth$ 3 (explode$ ?position))))
		(robot_info (location custom) (status ?status) (x (nth$ 1 (explode$ ?position))) (y (nth$ 2 (explode$ ?position))) (angle (nth$ 3 (explode$ ?position))))
		(save_position saved)
	)
)

(defrule save_position-send_command
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type save_position) (params ?symbol) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	(not
		(waiting (cmd "mp_position") (symbol ?symbol))
	)
	(not
		(save_position saved)
	)
	(not
		(BB_answer "mp_position" ?symbol ? ?)
	)
	=>
	(send-command "mp_position" ?symbol ""  )
)

(defrule save_position-success
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type save_position) (params ?symbol) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(save_position saved)
	(position (name ?symbol))
	=>
	(retract ?pnpdt_f1__)
	(assert
		(task_status ?pnpdt_task__ successful)
	)
)

(defrule save_position-timedout_or_failed
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type save_position) (params ?symbol) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(not
		(task_status ?pnpdt_task__ ?)
	)
	?pnpdt_f1__ <-(non-existent-fact)
	?pnpdt_f2__ <-(BB_answer "mp_position" ?symbol 0 ?)
	(not
		(save_position saved)
	)
	=>
	(retract ?pnpdt_f1__ ?pnpdt_f2__)
	(assert
		(task (plan ?pnpdt_planName__) (action_type check_mp_position) (params "") (step 1 $?pnpdt_steps__) (parent ?pnpdt_task__) )
	)
)

################################
#      FINALIZING RULES
################################

(defrule save_position-clear-task_flags
	(task (id ?pnpdt_task__) (plan ?pnpdt_planName__) (action_type save_position) (params ?symbol) (step $?pnpdt_steps__) )
	(active_task ?pnpdt_task__)
	(not
		(cancel_active_tasks)
	)
	(task_status ?pnpdt_task__ ?)
	?pnpdt_f1__ <-(save_position $?)
	=>
	(retract ?pnpdt_f1__)
)

################################
#      CANCELING RULES
################################

