(deffunction spg_say
	(?symbol $?elements)
	(bind ?text "")
	(progn$ (?var $?elements)
		(bind ?text (str-cat ?text " " ?var) )
	)
	(bind ?length (str-length ?text))
	(bind ?timeout (+ (* 250 ?length) 1000) )
	(send-command "spg_say" ?symbol ?text ?timeout )
)

(defrule spg_say-send_command
	?p <-(plan (action_type spg_say) (params $?speech))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	(not (waiting (symbol spg_say)))
	(not (BB_answer "spg_say" spg_say 1 ?))
	=>
	(spg_say spg_say $?speech)
)

(defrule spg_say-command_succeeded
	?p <-(plan (action_type spg_say))
	(active_plan ?p)
	(not
		(plan_status ?p ?)
	)
	(BB_answer "spg_say" spg_say 1 ?)
	=>
	(assert
		(plan_status ?p successful)
	)
)
