;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							HANDLE PLAN OUTCOMES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule delete_task_status
	(declare (salience 9500))
	?ts <-(task_status ?t)
	?at <-(active_task ?t)
	(not
		(fact-existp ?t)
	)
	=>
	(retract ?ts ?at)
	(log-message INFO "Deleted task_status.")
)

; SUCCESSFUL PLANS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; When a task was successful, the planner must delete all tasks up to some point where it can continue the execution of the plan.

(defrule successful_task-delete_successful_task ; There is a task with same hierarchy (unordered or successor) that should be executed. Delete this (successful) task so the others can be activated.
	(declare (salience -9500))
	?t <-(task (plan ?planName) (step ?step $?steps) (params $?params) (action_type ?action_type))
	?ts <-(task_status ?t successful)
	?at <-(active_task ?t)
	?t2 <-(task (plan ?planName) (step ? $?steps))
	(test
		(neq ?t ?t2)
	)
	=>
	(retract ?ts ?at ?t)
	(log-message INFO "Successful task of plan '" ?planName "' with action_type: '" ?action_type "' and params: '" $?params "' was deleted. Other tasks of same hierarchy (unordered or successors) exist.")
)

(defrule successful_task-make_parent_successful ; When there are no tasks with same hierarchy (unordered or successors), make parent task active (and successful)
	(declare (salience -9500))
	?pt <-(task (params $?params_PP) (action_type ?action_type_PP))
	?t <-(task (plan ?planName) (step ?step $?steps) (params $?params) (action_type ?action_type) (parent ?pt))
	?ts <-(task_status ?t successful)
	?at <-(active_task ?t)
	(not
		(and
			(task (plan ?planName) (step ? $?steps) (params $?params2) (action_type ?action_type2))
			(test
				(or
					(neq $?params $?params2)
					(neq ?action_type ?action_type2)
				)
			)
		)
	)
	=>
	(retract ?ts ?at ?t)
	(assert
		(task_status ?pt successful)
		(active_task ?pt)
	)
	(log-message INFO "Successful task of plan '" ?planName "' with action_type: '" ?action_type "' and params: '" $?params "' was deleted with no other tasks of same hierarchy. Parent task with action_type: '" ?action_type_PP "' and params: '" $?params_PP "' is now active (and successful).")
)

(defrule successful_task-top_level_succeeded ; Top-level task was successful
	(declare (salience -9500))
	?t <-(task (plan ?planName) (step ?step) (action_type ?action_type) (params $?params))
	?ts <-(task_status ?t successful)
	?at <-(active_task ?t)
	(not
		(and
			(task (plan ?planName) (step ?) (action_type ?action_type2) (params $?params2))
			(test
				(or
					(neq ?action_type ?action_type2)
					(neq $?params $?params2)
				)
			)
		)
	)
	=>
	(retract ?ts ?at ?t)
	(log-message INFO "Top level task of plan '" ?planName "' with action_type: '" ?action_type "' and params: '" $?params "' succeeded!")

	(task (plan ?planName) (action_type spg_say) (params "I have finished the task " ?planName) (step ?step) (parent ?t))
	(task (plan ?planName) (action_type PE-success) (params "") (step (+ ?step 1)) (parent ?t))
)

(defrule successful_task-catch_successful_task ; When a top-level task succeeeds, a task to say that it succeeded and to later delete the plan is asserted, this rule is to catch the "success" plan so it won't create a loop and error.
	?t <-(task (plan ?planName) (step ?step) (action_type PE-success))
	?at <-(active_task ?t)
	=>
	(retract ?at ?t)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; UNSUCCESSFUL PLANS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; When a leaf node was unsuccessful, the planner must delete all tasks up to some point where it can (retask and) manage to accomplish the plan.

(defrule failed_task-mark_task_without_rules_as_failed-set_failure_task ; When a task has no rules (either to assert new sub-tasks or perform an action) it is either an incomplete design or (most likely) a task set to re-plan but with no more alternatives, which should be marked as failed.
	(declare (salience -9500))
	?t <-(task (plan ?planName) (step $?steps) (action_type ?action_type&~PE-fail)) ; see next rule
	(active_task ?t)
	(not (waiting))
	(not (timer_sent $?))
	(not (task_status ?t ?))
	(not (PE-failed))
	=>
	(assert
		(task (plan ?planName) (action_type spg_say) (params "I don't know how to perform action:" ?action_type ".") (step 1 $?steps) (parent ?t))
		(task (plan ?planName) (action_type PE-fail) (params "") (step 2 $?steps) (parent ?t))
		(PE-failed)
	)
)

(defrule failed_task-mark_task_without_rules_as_failed-after_failure_task
	(declare (salience -9500))
	?t <-(task (plan ?planName) (step $?steps) (action_type ?action_type&~PE-fail)) ; see next rule
	(active_task ?t)
	(not (waiting))
	(not (timer_sent $?))
	(not (task_status ?t ?))
	?failed <-(PE-failed)
	=>
	(retract ?failed)
	(assert
		(task_status ?t failed)
	)
	(log-message WARNING "No alternatives left to perform action " ?action_type)
)

(defrule failed_task-catch_failed_task ; When a task fails, a task to say that it failed and to later fail is asserted, this rule is to catch the failure so it won't create a loop and error.
	?t <-(task (action_type PE-fail))
	(active_task ?t)
	=>
	(assert
		(task_status ?t failed)
	)
)

(defrule failed_task-delete_tasks_with_same_hierarchy ; Other tasks with same hierarchy (unordered or successors) must be cleared out.
	(declare (salience -9500))
	?t <-(task (plan ?planName) (step ?step $?steps) (params $?params) (action_type ?action_type))
	(active_task ?t)
	(task_status ?t failed)
	?t2 <-(task (plan ?planName) (step ?step2 $?steps) (params $?params2) (action_type ?action_type2))
	(test
		(neq ?t ?t2)
	)
	=>
	(retract ?t2)
	(log-message WARNING "Plan '" ?action_type "'' with steps: '" ?step " " $?steps "' failed. Deleted same hierarchy task for plan '" ?planName "' with action_type: '" ?action_type2 "' and params: '" $?params2 "'.")
)

(defrule failed_task-delete_failed_task ; After removing all other same-hierarchy tasks, remove this task and let the engine replan. (this rule applies to non-top-level tasks)
	(declare (salience -9500))
	?t <-(task (plan ?planName) (step ?step ?next_step $?steps) (params $?params) (action_type ?action_type))
	?ts <-(task_status ?t failed)
	?at <-(active_task ?t)
	(not
		(and
			(task (plan ?planName) (step ? ?next_step $?steps) (params $?params2) (action_type ?action_type2))
			(test
				(or
					(neq ?action_type ?action_type2)
					(neq $?params $?params2)
				)
			)
		)
	)
	=>
	(retract ?ts ?at ?t)
	(log-message WARNING "Failed task of plan '" ?planName "' with action_type: '" ?action_type "' and params: '" $?params "' was deleted. Parent task should be activated for replanning.")
)

(defrule failed_task-top_level_failed ; After removing all other same-hierarchy tasks, remove this task.
	(declare (salience -9500))
	?t <-(task (plan ?planName) (step ?step) (params $?params) (action_type ?action_type))
	?ts <-(task_status ?t failed)
	?at <-(active_task ?t)
	(not
		(and
			(task (plan ?planName) (step ?) (params $?params2) (action_type ?action_type2))
			(test
				(neq ?action_type ?action_type2)
				(neq $?params $?params2)
			)
		)
	)
	=>
	(retract ?ts ?at ?t)
	(log-message ERROR "Top level task failed without alternative task!")
	(send-command "spg_say" (str-cat "The task for the plan " ?planName " failed and I don't have an alternative plan. I cannot accomplish the task." 10000)
)
