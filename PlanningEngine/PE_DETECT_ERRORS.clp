;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;						ERROR DETECTION RULES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; To detect errors in plan design, not run-time errors.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



(defrule DETECT_ERROR-CYCLED_PLAN ; This should be prevented before execution, but just in case.
	(declare (salience 10000))
	(plan (task ?taskName) (action_type ?action_type) (params $?params) (step $?steps) )
	?p <-(plan (task ?taskName) (action_type ?action_type) (params $?params) 
		(step $?steps2&:(and 
				(< (length$ $?steps) (length$ $?steps2))
				(eq (subseq$ $?steps2 (+ 1 (- (length$ $?steps2) (length$ $?steps))) (length$ $?steps2)) $?steps)
			)
		)
	)
	=>
	(retract ?p)
	(assert
		(plan (task ?taskName) (action_type ?action_type) (params $?params) (step $?steps2))
	)
	(printout t "ERROR: CYCLED PLAN!" crlf
		tab tab "Task: " ?taskName crlf
		tab tab "Action type: " ?action_type crlf
		tab tab "Params" $?params crlf )
	(halt)
)

(defrule DETECT_ERROR-PLAN_STATUS_WITHOUT_ACTIVE_PLAN ; By design of the planning engine, this should never happen!
	(declare (salience 10000))
	?p <-(plan (task ?taskName) (action_type ?action_type) (params $?params) (step $?steps))
	(plan_status ?p)
	(not (active_plan ?p))
	=>
	(printout t "ERROR: PLAN STATUS W/O ACTIVE PLAN!" crlf
		tab tab "Task: " ?taskName crlf
		tab tab "Action type: " ?action_type crlf
		tab tab "Params" $?params crlf )
	(halt)
)
