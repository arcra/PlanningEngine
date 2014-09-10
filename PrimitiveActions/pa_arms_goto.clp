(defrule arms_goto-send_command
	?p <-(plan (action_type arms_goto) (params ?position))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	(not (waiting (symbol arms_goto)))
	(not (BB_answer "arms_goto" arms_goto ? ?))
	=>
	(send-command "arms_goto" arms_goto ?position 10000)
)

(defrule arms_goto-failed_or_timedout
	?p <-(plan (action_type arms_goto) (params ?position))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	(BB_answer "arms_goto" arms_goto 0 ?)
	=>
	(send-command "arms_goto" arms_goto ?position 10000)
)

(defrule arms_goto-succeeded
	?p <-(plan (action_type arms_goto))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	(BB_answer "arms_goto" arms_goto 1 ?)
	=>
	(assert
		(plan_status ?p successful)
	)
)
