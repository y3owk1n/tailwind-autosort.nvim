(jsx_attribute
  (property_identifier) @_attribute_name
  (#any-of? @_attribute_name "class" "className")
  [
    (string
      (string_fragment) @tailwind)
    (jsx_expression
      (template_string
        (string_fragment) @tailwind))
    (jsx_expression
    (ternary_expression
      consequence: (string (string_fragment) @tailwind)
      alternative: (string (string_fragment) @tailwind)))
  ])
