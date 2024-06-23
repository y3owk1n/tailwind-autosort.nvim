(call_expression
    (identifier) @function_name
    (#any-of? @function_name "cn" "clsx" "twMerge")
    (arguments
        ([
            (string (string_fragment) @tailwind)
            (ternary_expression
                consequence: (string (string_fragment) @tailwind)
            )
            (ternary_expression
                alternative: (string (string_fragment) @tailwind)
            )
            (binary_expression
                right: (string (string_fragment) @tailwind)
            )
        ])
    )
)
