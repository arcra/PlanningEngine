;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							PLANNING CONTROL RULES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;					IMPORTANT NOTES (TO UNDERSTAND)
; - Only one top-level task (for each plan) is decomposed in smaller tasks
;	at a time. (Only one path from the root node to a lead node
;	of the task search tree)
;	i. e. The whole task is not "expanded" from the start.
;	UNLESS different steps can run in parallel.

; - A task fact can have an enabled_task fact or an active_task fact, but
;	not both.
; - Only the most detailed tasks (so far) (i. e. leaf nodes)
;	are either enabled or active. (i. e. parent tasks cannot be enabled,
;	and thus, cannot be discarded when activating tasks)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;	GET READY TO START PLANNING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule NOT_allTasksEnabled
	(declare (salience 9800))

	?ate <-(PE-allTasksEnabled)
	(not (PE-ready_to_plan))
	?t <-(task (plan ?planName) (action_type ?action_type1) (step ?step1 $?steps1) (params $?params1))
	(not (active_task ?t))
	; There's no other task of the same plan that should have been activated before this one. (i. e. this one should have been activated.)
	(not
		(and
			(task (plan ?planName) (action_type ?action_type2) (params $?params2) (step ?step2 $?steps2))
			(test
				(or
					(neq ?action_type1 ?action_type2)
					(neq $?params1 $?params2)
					(neq (create$ ?step1 $?steps1) (create$ ?step2 $?steps2))
				)
			)
			(test
				(or
					(> (length$ $?steps2) (length$ $?steps1))
					(and
						(eq $?steps2 $?steps1)
						(< ?step2 ?step1)
					)
				)
			)
			(not (can_run_in_parallel ?action_type1 ?action_type2))
			(not (can_run_in_parallel ?action_type2 ?action_type1))
		)
	)
	; There's no other task from a different plan that should have been activated before this one. (i. e. this one should have been activated.)
	(not
		(and
			(task (plan ~?planName) (action_type ?action_type3))
			(task_priority ?action_type3 ?x)
			(or
				(and
					(not (task_priority ?action_type1 ?))
					(test (> ?x 0))
				)
				(and
					(task_priority ?action_type1 ?y)
					(test (> ?x ?y))
				)
			)
			(not (can_run_in_parallel ?action_type1 ?action_type3))
			(not (can_run_in_parallel ?action_type3 ?action_type1))
		)
	)
	=>
	(retract ?ate)
	(assert
		(cancel_active_tasks)
	)
)

(defrule retract_active_tasks
	(declare (salience -9800))
	(cancel_active_tasks)
	?at <-(active_task ?)
	=>
	(retract ?at)
)

(defrule retract_cancel_tasks_flag
	?cat <-(cancel_active_tasks)
	(not (active_task ?))
	=>
	(retract ?cat)
)

(defrule set_ready_to_plan
	(not (active_task ?))
	(not (PE-allTasksEnabled))
	(not (PE-ready_to_plan))
	=>
	(assert
		(PE-ready_to_plan)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;	ENABLE PLANS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule EnableMostDetailedTasksFromPlans
	(not (PE-allTasksEnabled))
	(PE-ready_to_plan)
;	(not (task_status ? ?)) ; So task_status can propagate before enabling new tasks.
	?t <-(task (plan ?planName) (action_type ?action_type) (params $?params1) (step ?step1 $?steps1))
	(not (PE-enabled_task ?t))
	(not
		(and
			(task (plan ?planName) (action_type ?action_type2) (params $?params2) (step ?step2 $?steps2))
			(test
				(or
					(neq ?action_type ?action_type2)
					(neq $?params1 $?params2)
					(neq (create$ ?step1 $?steps1) (create$ ?step2 $?steps2))
				)
			)
			(test
				(or
					(> (length$ $?steps2) (length$ $?steps1))
					(and
						(eq $?steps2 $?steps1)
						(< ?step2 ?step1)
					)
				)
			)
			(not (can_run_in_parallel ?action_type1 ?action_type2))
			(not (can_run_in_parallel ?action_type2 ?action_type1))
		)
	)
	=>
	(assert
		(PE-enabled_task ?t)
	)
)

(defrule allTasksEnabled
	(declare (salience -9800))
	(not (PE-allTasksEnabled))
	(PE-ready_to_plan)
	=>
	(assert
		(PE-allTasksEnabled)
		(PE-discarded)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;	ACTIVATE PLANS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule set_task_active-search_top_priority_task-start_comparing_tasks
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	(not (PE-comparing $?))
	(PE-enabled_task ?t1)
	(PE-enabled_task ?t2)
	(test
		(neq ?t1 ?t2)
	)
	(PE-discarded $?discarded)
	(not 
		(test
			(or
				(member$ ?t1 $?discarded)
				(member$ ?t2 $?discarded)
			)
		)
	)
	=>
	(assert
		(PE-comparing ?t1 ?t1 ?t2 ?t2)
	)
)

(defrule set_task_active-search_top_priority_task-no_priority_first-no_parent
	(declare (salience 9900))
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?t1 <-(task (parent nil))
	?cmp <-(PE-comparing ?et1 ?t1 ?et2 ?t2)
	(not
		(task_priority =(fact-slot-value ?t1 action_type) ?)
	)
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?cmp ?d)
	(assert
		(PE-discarded $?discarded ?et1)
	)
)

(defrule set_task_active-search_top_priority_task-no_priority_second-no_parent
	(declare (salience 9900))
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?t2 <-(task (parent nil))
	?cmp <-(PE-comparing ?et1 ?t1 ?et2 ?t2)
	(task_priority =(fact-slot-value ?t1 action_type) ?)
	(not
		(task_priority =(fact-slot-value ?t2 action_type) ?)
	)
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?cmp ?d)
	(assert
		(PE-discarded $?discarded ?et2)
	)
)

(defrule set_task_active-search_top_priority_task-no_priority_first
	(declare (salience 9800))
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?t1 <-(task (parent ?pt1))
	?cmp <-(PE-comparing ?et1 ?t1 ?et2 ?t2)
	(not
		(task_priority =(fact-slot-value ?t1 action_type) ?)
	)
	=>
	(retract ?cmp)
	(assert
		(PE-comparing ?et1 ?pt1 ?et2 ?t2)
	)
)

(defrule set_task_active-search_top_priority_task-no_priority_second
	(declare (salience 9800))
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?t2 <-(task (parent ?pt2))
	?cmp <-(PE-comparing ?et1 ?t1 ?et2 ?t2)
	(not
		(task_priority =(fact-slot-value ?t2 action_type) ?)
	)
	=>
	(retract ?cmp)
	(assert
		(PE-comparing ?et1 ?t1 ?et2 ?pt2)
	)
)

(defrule set_task_active-search_top_priority_task-comparing_not_upgraded-wins_first
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?et1 ?t1 ?et2 ?t2)
	(not (PE-upgraded_first ?))
	(not (PE-upgraded_second ?))
	(task_priority =(fact-slot-value ?t1 action_type) ?priority1)
	(task_priority =(fact-slot-value ?t2 action_type) ?priority2)
	(test
		(> ?priority1 ?priority2)
	)
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?cmp ?d)
	(assert
		(PE-discarded $?discarded ?et2)
	)
)

(defrule set_task_active-search_top_priority_task-comparing_not_upgraded-wins_second
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?et1 ?t1 ?et2 ?t2)
	(not (PE-upgraded_first ?))
	(not (PE-upgraded_second ?))
	(task_priority =(fact-slot-value ?t1 action_type) ?priority1)
	(task_priority =(fact-slot-value ?t2 action_type) ?priority2)
	(test
		(> ?priority2 ?priority1)
	)
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?cmp ?d)
	(assert
		(PE-discarded $?discarded ?et1)
	)
)

(defrule set_task_active-search_top_priority_task-comparing_not_upgraded-draw
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?t1 <-(task (parent ?pt1))
	?cmp <-(PE-comparing ?et1 ?t1 ?et2 ?t2)
	(not (PE-upgraded_first ?))
	(not (PE-upgraded_second ?))
	(task_priority =(fact-slot-value ?t1 action_type) ?priority1)
	(task_priority =(fact-slot-value ?t2 action_type) ?priority2)
	(test
		(= ?priority2 ?priority1)
	)
	=>
	(retract ?cmp)
	(assert
		(PE-comparing ?et1 ?pt1 ?et2 ?t2)
		(PE-upgraded_first ?t1)
	)
)

(defrule set_task_active-search_top_priority_task-comparing_not_upgraded-draw-no_parent-second_parent
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?t1 <-(task (parent nil))
	?t2 <-(task (parent ?pt2))
	?cmp <-(PE-comparing ?et1 ?t1 ?et2 ?t2)
	(not (PE-upgraded_first ?))
	(not (PE-upgraded_second ?))
	(task_priority =(fact-slot-value ?t1 action_type) ?priority1)
	(task_priority =(fact-slot-value ?t2 action_type) ?priority2)
	(test
		(= ?priority2 ?priority1)
	)
	=>
	(retract ?cmp)
	(assert
		(PE-comparing ?et1 ?t1 ?et2 ?pt2)
	)
)

(defrule set_task_active-search_top_priority_task-comparing_not_upgraded-draw-no_parents
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?t1 <-(task (parent nil))
	?t2 <-(task (parent nil))
	?cmp <-(PE-comparing ?et1 ?t1 ?et2 ?t2)
	(not (PE-upgraded_first ?))
	(not (PE-upgraded_second ?))
	(task_priority =(fact-slot-value ?t1 action_type) ?priority1)
	(task_priority =(fact-slot-value ?t2 action_type) ?priority2)
	(test
		(= ?priority2 ?priority1)
	)
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?cmp ?d)
	(assert
		(PE-discarded $?discarded ?et2)
	)
)

(defrule set_task_active-search_top_priority_task-comparing_upgraded_first-wins_first
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?et1 ?pt1 ?et2 ?t2)
	?uf <-(PE-upgraded_first ?)
	(not (PE-upgraded_second ?))
	(task_priority =(fact-slot-value ?pt1 action_type) ?priority1)
	(task_priority =(fact-slot-value ?t2 action_type) ?priority2)
	(test
		(> ?priority1 ?priority2)
	)
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?cmp ?d ?uf)
	(assert
		(PE-discarded $?discarded ?et2)
	)
)

(defrule set_task_active-search_top_priority_task-comparing_upgraded_first-wins_second
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?et1 ?pt1 ?et2 ?t2)
	?uf <-(PE-upgraded_first ?)
	(not (PE-upgraded_second ?))
	(task_priority =(fact-slot-value ?pt1 action_type) ?priority1)
	(task_priority =(fact-slot-value ?t2 action_type) ?priority2)
	(test
		(> ?priority2 ?priority1)
	)
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?cmp ?d ?uf)
	(assert
		(PE-discarded $?discarded ?et1)
	)
)

(defrule set_task_active-search_top_priority_task-comparing_upgraded_first-draw
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?t2 <-(task (parent ?pt2))
	?cmp <-(PE-comparing ?et1 ?pt1 ?et2 ?t2)
	(PE-upgraded_first ?t1)
	(not (PE-upgraded_second ?))
	(task_priority =(fact-slot-value ?pt1 action_type) ?priority1)
	(task_priority =(fact-slot-value ?t2 action_type) ?priority2)
	(test
		(= ?priority2 ?priority1)
	)
	=>
	(retract ?cmp)
	(assert
		(PE-comparing ?et1 ?t1 ?et2 ?pt2)
		(PE-upgraded_second ?pt1)
	)
)

(defrule set_task_active-search_top_priority_task-comparing_upgraded_first-draw-no_second_parent-first_parent

	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?pt1 <-(task (parent ?pt3))
	?t2 <-(task (parent nil))
	?cmp <-(PE-comparing ?et1 ?pt1 ?et2 ?t2)
	?uf <-(PE-upgraded_first ?)
	(not (PE-upgraded_second ?))
	(task_priority =(fact-slot-value ?pt1 action_type) ?priority1)
	(task_priority =(fact-slot-value ?t2 action_type) ?priority2)
	(test
		(= ?priority2 ?priority1)
	)
	=>
	(retract ?cmp ?uf)
	(assert
		(PE-comparing ?et1 ?pt3 ?et2 ?t2)
		(PE-upgraded_first ?pt1)
	)
)

(defrule set_task_active-search_top_priority_task-comparing_upgraded_first-draw-no_parents

	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?pt1 <-(task (parent nil))
	?t2 <-(task (parent nil))
	?cmp <-(PE-comparing ?et1 ?pt1 ?et2 ?t2)
	?uf <-(PE-upgraded_first ?)
	(not (PE-upgraded_second ?))
	(task_priority =(fact-slot-value ?pt1 action_type) ?priority1)
	(task_priority =(fact-slot-value ?t2 action_type) ?priority2)
	(test
		(= ?priority2 ?priority1)
	)
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?cmp ?uf ?d)
	(assert
		(PE-discarded $?discarded ?et2)
	)
)

(defrule set_task_active-search_top_priority_task-comparing_upgraded_second-wins_first
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?et1 ?t1 ?et2 ?pt2)
	?uf <-(PE-upgraded_first ?t1)
	?us <-(PE-upgraded_second ?pt1)
	(task_priority =(fact-slot-value ?t1 action_type) ?priority1)
	(task_priority =(fact-slot-value ?pt2 action_type) ?priority2)
	(test
		(> ?priority1 ?priority2)
	)
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?cmp ?d ?uf ?us)
	(assert
		(PE-discarded $?discarded ?et2)
	)
)

(defrule set_task_active-search_top_priority_task-comparing_upgraded_second-wins_second
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?et1 ?t1 ?et2 ?pt2)
	?uf <-(PE-upgraded_first ?t1)
	?us <-(PE-upgraded_second ?pt1)
	(task_priority =(fact-slot-value ?t1 action_type) ?priority1)
	(task_priority =(fact-slot-value ?pt2 action_type) ?priority2)
	(test
		(> ?priority2 ?priority1)
	)
	?d <-(PE-discarded $?discarded)
	=>
	(retract ?cmp ?d ?uf ?us)
	(assert
		(PE-discarded $?discarded ?et1)
	)
)

(defrule set_task_active-search_top_priority_task-comparing_upgraded_second-draw
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not (PE-activable_task ?))
	?cmp <-(PE-comparing ?et1 ?t1 ?et2 ?pt2)
	?uf <-(PE-upgraded_first ?t1)
	?us <-(PE-upgraded_second ?pt1)
	(task_priority =(fact-slot-value ?t1 action_type) ?priority1)
	(task_priority =(fact-slot-value ?pt2 action_type) ?priority2)
	(test
		(= ?priority2 ?priority1)
	)
	=>
	(retract ?cmp ?uf ?us)
	(assert
		(PE-comparing ?et1 ?pt1 ?et2 ?pt2)
	)
)

(defrule set_task_active-search_top_priority_task-set_top_priority_task
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not
		(PE-activable_task ?)
	)
	?et <-(PE-enabled_task ?t)
	?d <-(PE-discarded $?discarded)
	(not
		(and
			(PE-enabled_task ?t2)
			(test
				(and
					(neq ?t ?t2)
					(not
						(member$ ?t2 $?discarded)
					)
				)
			)
		)
	)
	=>
	(retract ?et ?d)
	(assert
		(PE-activable_task ?t)
		(PE-activable_tasks ?t)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule set_task_active-search_parallel_tasks-discard_task
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	?et <-(PE-enabled_task ?t)
	(PE-activable_task ?at)
	(not
		(or
			(can_run_in_parallel =(fact-slot-value ?t action_type) =(fact-slot-value ?at action_type))
			(can_run_in_parallel =(fact-slot-value ?at action_type) =(fact-slot-value ?t action_type))
		)
	)
	=>
	(retract ?et)
)

(defrule set_task_active-search_parallel_tasks-add_task
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	?et <-(PE-enabled_task ?t)
	(exists (PE-activable_task ?))
	(not
		(and
			(PE-activable_task ?at)
			(not
				(or
					(can_run_in_parallel =(fact-slot-value ?t action_type) =(fact-slot-value ?at action_type))
					(can_run_in_parallel =(fact-slot-value ?at action_type) =(fact-slot-value ?t action_type))
				)
			)
		)
	)
	?ats <-(PE-activable_tasks $?tasks)
	=>
	(retract ?ats ?et)
	(assert
		(PE-activable_task ?t)
		(PE-activable_tasks $?tasks ?t)
	)
)

(defrule set_task_active-search_parallel_tasks-delete_activable_task
	(PE-allTasksEnabled)
	(PE-ready_to_plan)
	(not
		(PE-enabled_task ?)
	)
	?at <-(PE-activable_task ?)
	=>
	(retract ?at)
)

(defrule set_task_active-search_parallel_tasks-delete_activable_tasks
	(PE-allTasksEnabled)
	?rtp <-(PE-ready_to_plan)
	(not
		(PE-activable_task ?)
	)
	?ats <-(PE-activable_tasks $?tasks)
	=>
	(retract ?ats ?rtp)
	(progn$ (?at $?tasks)
		(assert (active_task ?at))
	)
)
