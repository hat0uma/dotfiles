;; extends
(heredoc_body
  (heredoc_content) @content
  (heredoc_end) @lang
  (#match? @lang "^(SHELL|BASH)$")
  (#set! language "bash")
)

