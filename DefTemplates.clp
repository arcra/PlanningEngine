(deftemplate plan
    (slot task
        (type LEXEME)
        (default ?NONE)
    )
    (slot action_type
        (type SYMBOL)
        (default ?NONE)
    )
    (multislot params)
    (multislot step
        (type INTEGER)
        (default ?NONE)
    )
)

(deftemplate enabled_plan
    (slot task
        (type LEXEME)
        (default ?NONE)
    )
    (slot action_type
        (type SYMBOL)
        (default ?NONE)
    )
    (multislot params)
    (multislot step
        (type INTEGER)
        (default ?NONE)
    )
)

(deftemplate active_plan
    (slot task
        (type LEXEME)
        (default ?NONE)
    )
    (slot action_type
        (type SYMBOL)
        (default ?NONE)
    )
    (multislot params)
    (multislot step
        (type INTEGER)
        (default ?NONE)
    )
)

(deftemplate plan_status
    (slot task
        (type LEXEME)
        (default ?NONE)
    )
    (slot action_type
        (type SYMBOL)
        (default ?NONE)
    )
    (multislot params)
    (multislot step
        (type INTEGER)
        (default ?NONE)
    )
    (slot status
        (allowed-symbols
            successful
            failed
        ) 
    )
)
