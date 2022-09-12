;;; Local configuration

(advice-add 'json-parse-string :around
            (lambda (orig string &rest rest)
              (apply orig (s-replace "\\u0000" "\\000a" string) rest)))

(advice-add 'json-parse-buffer :around
            (lambda (orig &rest rest)
              (while (re-search-forward "\\u0000" nil t)
                (replace-match "\\u000a" t t))
              (apply orig rest)))
