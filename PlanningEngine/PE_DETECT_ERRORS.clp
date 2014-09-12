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
;	(log-message ERROR "CYCLED PLAN!" crlf
;		tab tab "Task: " ?taskName crlf
;		tab tab "Action type: " ?action_type crlf
;		tab tab "Params" $?params crlf
;	)
	(printout t "ERROR: CYCLED PLAN!" crlf
		tab tab "Task: " ?taskName crlf
		tab tab "Action type: " ?action_type crlf
		tab tab "Params" $?params crlf
	)
	(halt)
)

(defrule DETECT_ERROR-PLAN_STATUS_WITHOUT_ACTIVE_PLAN ; By design of the planning engine, this should never happen!
	(declare (salience 10000))
	?p <-(plan (task ?taskName) (action_type ?action_type) (params $?params) (step $?steps))
	(plan_status ?p)
	(not (active_plan ?p))
	=>
;	(log-message ERROR "PLAN STATUS W/O ACTIVE PLAN!" "\n"
;		"\t\tTask: " ?taskName "\n"
;		"\t\tAction type: " ?action_type "\n"
;		"\t\tParams" $?params "\n"
;	)
	(printout t "ERROR: PLAN STATUS W/O ACTIVE PLAN!" crlf
		tab tab "Task: " ?taskName crlf
		tab tab "Action type: " ?action_type crlf
		tab tab "Params" $?params crlf
	)
	(halt)
)

(defrule DETECT_ERROR-CYCLED_PRIORITIES
	(declare (salience 10000))
	(plan_priority ?action_type1 ?priority1)
	(plan_priority ?action_type2 ?priority2)
	(plan_priority ?action_type3 ?priority3)
	(test
		(and
			(> ?priority1 ?priority2)
			(> ?priority2 ?priority3)
			(> ?priority3 ?priority1)
		)
	)
	=>
;	(log-message ERROR "CYCLED PRIORITIES!" "\n"
;		"\t\tAction types: " ?action_type1 " - " ?action_type2 " - " ?action_type3 "\n"
;	)
	(printout t "ERROR: CYCLED PRIORITIES!" crlf
		tab tab "Action types: " ?action_type1 " - " ?action_type2 " - " ?action_type3 crlf
	)
	(halt)
)

(defrule DETECT_ERROR-REPEATED_PRIORITIES
	(declare (salience 10000))
	(plan_priority ?action_type ?priority1)
	(plan_priority ?action_type ~?priority1)
	=>
;	(log-message ERROR "REPEATED PRIORITIES!" "\n"
;		"\t\tAction type: " ?action_type "\n"
;	)
	(printout t "ERROR: REPEATED PRIORITIES!" crlf
		tab tab "Action type: " ?action_type crlf
	)
	(halt)
)
