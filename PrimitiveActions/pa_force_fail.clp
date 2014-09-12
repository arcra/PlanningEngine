(defrule force_fail-fail
	?p <-(plan (action_type force_fail))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	=>
	(assert
		(plan_status ?p failed)
	)
)
