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
