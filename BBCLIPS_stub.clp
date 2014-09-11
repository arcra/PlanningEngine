;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;			GLOBALS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defglobal ?*outlog* = t)
(defglobal ?*logLevel* = ERROR) ; INFO | WARNING | ERROR

(defglobal ?*defaultTimeout* = 2000)
(defglobal ?*defaultAttempts* = 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		DEFTEMPLATES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(deftemplate waiting
	(slot cmd (type STRING))
	(slot id (type INTEGER))
	(slot args (type STRING))
	(slot timeout
		(type INTEGER)
		(range 0 ?VARIABLE)
	)
	(slot attempts
		(type INTEGER)
		(range 1 ?VARIABLE)
	)
	(slot symbol
		(type SYMBOL)
	)
)


(deffunction send-command
	; Receives: command, symbol identifier, cmd_params and optionally
	;timeout and number of attempts in case it times out or fails.
	; Symbol identifier is useful for tracking responses through rules.
	(?cmd ?sym ?args $?settings)
	(bind ?timeout ?*defaultTimeout*)
	(bind ?attempts ?*defaultAttempts*)
	(switch (length$ $?settings)
		(case 1 then
			(bind ?timeout (nth$ 1 $?settings))
		)
		(case 2 then
			(bind ?timeout (nth$ 1 $?settings))
			(bind ?attempts (nth$ 2 $?settings))
		)
	)
	(bind ?id (random 1 10000))
	(if (> ?timeout 0) then
		(setCmdTimer ?timeout ?cmd ?id)
	)
	(assert
		(waiting (cmd ?cmd) (id ?id) (args ?args) (timeout ?timeout) (attempts ?attempts) (symbol ?sym) )
	)
	(log-message INFO "Sent command: '" ?cmd "' - id: " ?id " - timeout: " ?timeout "ms - attempts: " ?attempts)
	(return ?id)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(deffunction log-message
	(?level ?msg1 $?msg2)

	(bind ?message ?msg1)
	(progn$ (?var $?msg2)
		(bind ?message (str-cat ?message ?var) )
	)
	(if (eq ?level DEBUG) then
		(printout ?*outlog* ?level ": " ?message crlf)
		(return)
	)
	(bind ?currentLogLevel 10)
	(bind ?lvl 10)
	(switch ?*logLevel*
		(case INFO then (bind ?currentLogLevel 0))
		(case ERROR then (bind ?currentLogLevel 20))
		(case WARNING then (bind ?currentLogLevel 10))
	)
	(switch ?level
		(case INFO then (bind ?lvl 0))
		(case ERROR then (bind ?lvl 20))
		(case WARNING then (bind ?lvl 10))
	)
	(if (>= ?lvl ?currentLogLevel) then
		(printout ?*outlog* ?level ": " ?message crlf)
	)
)

(deffunction setCmdTimer
	(?time ?cmd ?id)
	(printout t "Cmd Timer sent: " ?cmd " " ?id crlf)
;	(python-call setCmdTimer ?time ?cmd ?id)
)

(deffunction setTimer
	(?time ?sym)
;	(python-call setTimer ?time ?sym)
	(printout t "Timer sent: " ?sym crlf)
	(assert (timer_sent ?sym (time) (/ ?time 1000.0)))
)

(defrule clear_timers
	(declare (salience -1000))
	?t <-(BB_timer $?)
	=>
	(retract ?t)
)

(defrule delete_old_timers
	(declare (salience -1000))
	?t <-(timer_sent ? ?time ?duration)
	(test (> (time) (+ ?time ?duration) ) )
	=>
	(retract ?t)
)

(deffunction sleep
	(?ms)
	(bind ?sym (gensym*))
	(printout t "Sleeping..." crlf)
;	(python-call sleep ?ms ?sym)
;	(halt)
)
