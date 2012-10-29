(load "parseopt.arc")
(load "test.arc")

(redef quit (x) nil)
(= stderr stdout)

(test iso (parseopt nil) (list (table) nil))
(test iso (tostring:parseopt '("-a")) "\
Usage: parseopt.t [OPTION]...

      --help            display this help and exit
      --version         output version information and exit
")

(test iso (parseopt '("foo")) (list (table) (list "foo")))

; ------------------------------------------------------------------------------

(defopts
  (a "a" nil "aaaaaa"))

(test iso (parseopt nil) (list (table) nil))
(test iso (parseopt '("-a")) (list (obj a t) nil))
(test iso (parseopt '("foo")) (list (table) '("foo")))
(test iso (parseopt '("-a" "foo")) (list (obj a t) '("foo")))
(test iso (tostring:parseopt '("--aaaa")) "\
Usage: parseopt.t [OPTION]...

  -a                    aaaaaa
      --help            display this help and exit
      --version         output version information and exit
")
(test iso (tostring:parseopt '("--help")) "\
Usage: parseopt.t [OPTION]...

  -a                    aaaaaa
      --help            display this help and exit
      --version         output version information and exit
")
(test iso (tostring:parseopt '("--version")) "parseopt.t version 0.0.1\n")
(= version* "1.0.0")
(test iso (tostring:parseopt '("--version")) "parseopt.t version 1.0.0\n")

; ------------------------------------------------------------------------------

(defopts
  (a "aaaa" nil "aaaaaa"))

(test iso (parseopt nil) (list (table) nil))
(test iso (parseopt '("--aaaa")) (list (obj a t) nil))
(test iso (parseopt '("foo")) (list (table) '("foo")))
(test iso (parseopt '("--aaaa" "foo")) (list (obj a t) '("foo")))
(test iso (tostring:parseopt '("-a")) "\
Usage: parseopt.t [OPTION]...

  --aaaa                aaaaaa
      --help            display this help and exit
      --version         output version information and exit
")

; ------------------------------------------------------------------------------

(defopts
  (a "a|aaaa" nil "aaaaaa"))

(test iso (parseopt nil) (list (table) nil))
(test iso (parseopt '("-a")) (list (obj a t) nil))
(test iso (parseopt '("--aaaa")) (list (obj a t) nil))
(test iso (parseopt '("foo")) (list (table) '("foo")))
(test iso (parseopt '("-a" "foo")) (list (obj a t) '("foo")))
(test iso (parseopt '("--aaaa" "foo")) (list (obj a t) '("foo")))
(test iso (tostring:parseopt '("-b")) "\
Usage: parseopt.t [OPTION]...

  -a, --aaaa            aaaaaa
      --help            display this help and exit
      --version         output version information and exit
")

; ------------------------------------------------------------------------------

(defopts
  (a "a|aaaa"        nil "aaaaaa")
  (b "b|bbbb=s:FILE" nil "bbbbbb"))

(test iso (parseopt nil) (list (table) nil))
(test iso (tostring:parseopt '("-b")) "\
Usage: parseopt.t [OPTION]...

  -a, --aaaa            aaaaaa
  -b FILE, --bbbb=FILE  bbbbbb
      --help            display this help and exit
      --version         output version information and exit
")
(test iso (parseopt '("-a" "-b" "foo")) (list (obj a t b "foo") nil))
(test iso (parseopt '("-a" "-b=foo")) (list (obj a t b "foo") nil))
(test iso (parseopt '("-a" "--bbbb" "foo")) (list (obj a t b "foo") nil))
(test iso (parseopt '("-a" "--bbbb=foo")) (list (obj a t b "foo") nil))
(test iso (parseopt '("-a" "-b" "foo" "bar")) (list (obj a t b "foo") '("bar")))
(test iso (parseopt '("-ab" "foo")) (list (obj a t b "foo") nil))
(test iso (tostring:parseopt '("-ba" "foo")) "\
Usage: parseopt.t [OPTION]...

  -a, --aaaa            aaaaaa
  -b FILE, --bbbb=FILE  bbbbbb
      --help            display this help and exit
      --version         output version information and exit
")
(test iso (tostring:parseopt '("-ba=foo")) "\
Usage: parseopt.t [OPTION]...

  -a, --aaaa            aaaaaa
  -b FILE, --bbbb=FILE  bbbbbb
      --help            display this help and exit
      --version         output version information and exit
")
(test iso (tostring:parseopt '("-ba")) "\
Usage: parseopt.t [OPTION]...

  -a, --aaaa            aaaaaa
  -b FILE, --bbbb=FILE  bbbbbb
      --help            display this help and exit
      --version         output version information and exit
")

; ------------------------------------------------------------------------------

(defopts
  (a "a|aaaa"        nil "aaaaaa")
  (b "b|bbbb=i:FILE" nil "bbbbbb"))

(test iso (parseopt '("-b" "1")) (list (obj b 1) nil))
(test iso (tostring:parseopt '("-b" "foo")) "\
parseopt.t: b: invalid argument
Can't coerce \"foo\" int
")

; ------------------------------------------------------------------------------

(defopts
  (a "a|aaaa"        nil "aaaaaa")
  (b "b|bbbb=i:FILE" 10  "bbbbbb"))

(test iso (parseopt '("-b" "1")) (list (obj b 1) nil))
(test iso (parseopt nil) (list (obj b 10) nil))

; ------------------------------------------------------------------------------

(defopts
  (a "a|aaaa"        nil "aaaaaa")
  (b "b|bbbb=s:FILE" nil "bbbbbb")
  (args (foo)))


(test iso (tostring:parseopt nil) "\
Usage: parseopt.t [OPTION]... FOO

  -a, --aaaa            aaaaaa
  -b FILE, --bbbb=FILE  bbbbbb
      --help            display this help and exit
      --version         output version information and exit
")
(test iso (parseopt '("foo")) (list (table) '("foo")))

; ------------------------------------------------------------------------------

(defopts
  (a "a|aaaa"        nil "aaaaaa")
  (b "b|bbbb=s:FILE" nil "bbbbbb")
  (args (foo bar)))
(test iso (tostring:parseopt nil) "\
Usage: parseopt.t [OPTION]... FOO BAR

  -a, --aaaa            aaaaaa
  -b FILE, --bbbb=FILE  bbbbbb
      --help            display this help and exit
      --version         output version information and exit
")
(test iso (tostring:parseopt '("foo")) "\
Usage: parseopt.t [OPTION]... FOO BAR

  -a, --aaaa            aaaaaa
  -b FILE, --bbbb=FILE  bbbbbb
      --help            display this help and exit
      --version         output version information and exit
")
(test iso (parseopt '("foo" "bar")) (list (table) '("foo" "bar")))

; ------------------------------------------------------------------------------

(defopts
  (a "a|aaaa"        nil "aaaaaa")
  (b "b|bbbb=s:FILE" nil "bbbbbb")
  (args (foo bar . baz)))

(test iso (tostring:parseopt nil) "\
Usage: parseopt.t [OPTION]... FOO BAR [BAZ]...

  -a, --aaaa            aaaaaa
  -b FILE, --bbbb=FILE  bbbbbb
      --help            display this help and exit
      --version         output version information and exit
")
(test iso (tostring:parseopt '("foo")) "\
Usage: parseopt.t [OPTION]... FOO BAR [BAZ]...

  -a, --aaaa            aaaaaa
  -b FILE, --bbbb=FILE  bbbbbb
      --help            display this help and exit
      --version         output version information and exit
")
(test iso (parseopt '("foo" "bar")) (list (table) '("foo" "bar")))
(test iso (parseopt '("foo" "bar" "baz")) (list (table) '("foo" "bar" "baz")))
(test iso (parseopt '("foo" "bar" "baz" "foobar")) (list (table) '("foo" "bar" "baz" "foobar")))

; ------------------------------------------------------------------------------

(defopts
  (args foo))

(test iso (parseopt nil) (list (table) nil))
(test iso (parseopt '("foo")) (list (table) '("foo")))
(parseopt '("-a"))
(test iso (tostring:parseopt '("-a")) "\
Usage: parseopt.t [OPTION]... [FOO]...

      --help            display this help and exit
      --version         output version information and exit
")

; ------------------------------------------------------------------------------

(defopts
  (a "a|aaaa=s" nil))

(test iso (tostring:parseopt '("-a")) "\
Usage: parseopt.t [OPTION]...

  -a VALUE, --aaaa=VALUE
      --help            display this help and exit
      --version         output version information and exit
")

; ------------------------------------------------------------------------------

(defopts
  (a "a|aaaa=s:LONG-VALUE" nil "foobarbaz"))

(test iso (tostring:parseopt '("-a")) "\
Usage: parseopt.t [OPTION]...

  -a LONG-VALUE, --aaaa=LONG-VALUE
                        foobarbaz
      --help            display this help and exit
      --version         output version information and exit
")

; ------------------------------------------------------------------------------

(= args* (list args*.0 "-b" "bbb" "foo" "bar" "baz" "foobar"))
(w/opts ((a "a|aaaa"        nil "aaaaaa")
         (b "b|bbbb=s:FILE" nil "bbbbbb")
         (args (foo bar . baz)))
  (test iso a nil)
  (test iso b "bbb")
  (test iso foo "foo")
  (test iso bar "bar")
  (test iso baz '("baz" "foobar"))
)

; ------------------------------------------------------------------------------

(= args* (list args*.0 "-a" "foo" "bar"))
(w/opts ((a "a|aaaa"        nil "aaaaaa")
         (b "b|bbbb=s:FILE" nil "bbbbbb")
         (args (foo bar . baz)))
  (test iso a t)
  (test iso b nil)
  (test iso foo "foo")
  (test iso bar "bar")
  (test iso baz nil)
)

(done-testing)

; vim:ft=arc
