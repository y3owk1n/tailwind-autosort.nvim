(jsx_attribute
    (property_identifier) @_attribute_name
    (#any-of? @_attribute_name "class" "className" "classNames")
    [
        (string
            (string_fragment) @tailwind
        )
        (jsx_expression
            (template_string
            (string_fragment) @tailwind)
        )
        (jsx_expression
            ([
                (ternary_expression
                    consequence: (string (string_fragment) @tailwind)
                )
                (ternary_expression
                    alternative: (string (string_fragment) @tailwind)
                )
            ])
        )
        (jsx_expression
            (binary_expression
              right: (string (string_fragment) @tailwind)
            )
        )
    ]
)
