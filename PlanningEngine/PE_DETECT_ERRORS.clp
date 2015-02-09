;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;						ERROR DETECTION RULES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule DETECT_ERROR-REPEATED_PRIORITIES
	(declare (salience 10000))
	(task_priority ?action_type ?priority1)
	(task_priority ?action_type ~?priority1)
	=>
;	(log-message ERROR "REPEATED PRIORITIES!" "\n"
;		"\t\tAction type: " ?action_type "\n"
;	)
	(printout t "ERROR: REPEATED PRIORITIES!" crlf
		tab tab "Action type: " ?action_type crlf
	)
	(halt)
)

(defrule DETECT_ERROR-CHLIDREN_TASK_WITHOUT_PARENT_TASK ; By design of the planning engine, this should never happen!
	(declare (salience 10000))
	(task (id ?t) (plan ?planName) (action_type ?action_type) (params $?params) (parent ?pt&~nil))
	(not (task (id ?pt)))
	=>
;	(log-message ERROR "TASK STATUS W/O ACTIVE TASK!" "\n"
;		"\t\tPlan: " ?planName "\n"
;		"\t\tAction type: " ?action_type "\n"
;		"\t\tParams" $?params "\n"
;	)
	(printout t "ERROR: TASK W/O PARENT TASK!" crlf
		tab tab "Plan: " ?planName crlf
		tab tab "Action type: " ?action_type crlf
		tab tab "Params" $?params crlf
	)
	(halt)
)


; I think there are cases in which cycled plans are ok. Although they should be handled with care.
; That's why I commented out this rule:

;(defrule DETECT_ERROR-CYCLED_PLAN ; This should be prevented before execution, but just in case.
;	(declare (salience 10000))
;	(task (plan ?planName) (action_type ?action_type) (step $?steps) ) ; (params $?params)
;	?task <-(task (id ?t) (plan ?planName) (action_type ?action_type) (params $?params) 
;		(step $?steps2&:(and 
;				(< (length$ $?steps) (length$ $?steps2))
;				(eq (subseq$ $?steps2 (+ 1 (- (length$ $?steps2) (length$ $?steps))) (length$ $?steps2)) $?steps)
;			)
;		)
;	)
;	=>
;	(retract ?task)
;	(assert
;		(task (plan ?planName) (action_type ?action_type) (params $?params) (step $?steps2))
;	)
;;	(log-message ERROR "CYCLED PLAN!" crlf
;;		tab tab "Plan: " ?planName crlf
;;		tab tab "Action type: " ?action_type crlf
;;		tab tab "Params" $?params crlf
;;	)
;	(printout t "ERROR: CYCLED PLAN!" crlf
;		tab tab "Plan: " ?planName crlf
;		tab tab "Action type: " ?action_type crlf
;		tab tab "Params" $?params crlf
;	)
;	(halt)
;)

; If there are tasks that "accomplish" or "cancels" other tasks, this might be useful.
; That's why I commented out this rule:

;(defrule DETECT_ERROR-TASK_STATUS_WITHOUT_ACTIVE_TASK ; By design of the planning engine, this should never happen!
;	(declare (salience 10000))
;	(task (id ?t) (plan ?planName) (action_type ?action_type) (params $?params) (step $?steps))
;	(task_status ?t ?)
;	(not (active_task ?t))
;	=>
;	(log-message ERROR "TASK STATUS W/O ACTIVE TASK!" "\n"
;		"\t\tPlan: " ?planName "\n"
;		"\t\tAction type: " ?action_type "\n"
;		"\t\tParams" $?params "\n"
;	)
;	(printout t "ERROR: TASK STATUS W/O ACTIVE TASK!" crlf
;		tab tab "Plan: " ?planName crlf
;		tab tab "Action type: " ?action_type crlf
;		tab tab "Params" $?params crlf
;	)
;	(halt)
;)

; Priorities CAN be cycled, because transitivity is not a requisite
; That's why I commented out this rule:

;(defrule DETECT_ERROR-CYCLED_PRIORITIES
;	(declare (salience 10000))
;	(task_priority ?action_type1 ?priority1)
;	(task_priority ?action_type2 ?priority2)
;	(task_priority ?action_type3 ?priority3)
;	(test
;		(and
;			(> ?priority1 ?priority2)
;			(> ?priority2 ?priority3)
;			(> ?priority3 ?priority1)
;		)
;	)
;	=>
;;	(log-message ERROR "CYCLED PRIORITIES!" "\n"
;;		"\t\tAction types: " ?action_type1 " - " ?action_type2 " - " ?action_type3 "\n"
;;	)
;	(printout t "ERROR: CYCLED PRIORITIES!" crlf
;		tab tab "Action types: " ?action_type1 " - " ?action_type2 " - " ?action_type3 crlf
;	)
;	(halt)
;)
