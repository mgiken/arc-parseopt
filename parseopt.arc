(require "re.arc")

(= version* "0.0.1")

(with (prog_  (re-replace ".*/" args*.0 "")
       spec_  (table)
       opts_  (table)
       count_ 0
       args_  nil
       help_  nil)

(def pr-version ()
  (w/stdout (stderr)
    (prn prog_ " version " version*))
  (quit 1))

(def pr-usage ()
  (w/stdout (stderr)
    (pr "Usage: " prog_ " [OPTION]...")
    ((afn (x)
      (awhen (and (acons x) (car x))
        (pr " " upcase.it))
      (if (no x)     nil
          (~acons x) (pr " [" upcase.x "]...")
                     (self cdr.x))) args_)
    (prn #\newline)
    (map (fn ((x y))
           (pr "  " x)
           (if blank.y
               (prn)
               (if (len> x 21)
                   (prn #\newline (newstring 24 #\space) y)
                   (prn (newstring (- 22 len.x) #\space) y))))
           rev.help_)
      (prn "      --help            display this help and exit")
      (prn "      --version         output version information and exit")
    )
  (quit 1))

(def invalid-opt-err (x)
  (w/stdout (stderr)
    (if (len> x 1)
        (prn prog_ ": unrecognized option '--" x "'")
        (prn prog_ ": invalid option -- '" x "'"))
    (prn "Try `" prog_ " --help' for more information."))
  (quit 4))

(def require-arg-err (x)
  (w/stdout (stderr)
    (pr prog_ ": option requires an argument ")
    (if (len> x 1)
        (prn "'--" x "'")
        (prn "-- '" x "'"))
    (prn "Try `" prog_ " --help' for more information."))
  (quit 2))

(def missing-operand-err ()
  (w/stdout (stderr)
    (prn prog_ ": missing operand")
    (prn "Try `" prog_ " --help' for more information."))
  (quit 1))

(def parseopt-err (opt msg (o code 1))
  (w/stdout (stderr)
    (prn prog_ ": " opt ": invalid argument")
    (prn msg))
  (quit code))

(def setup-optspec ((name spec default (o help "")))
  (if (is name 'args)
      (= args_ spec)
      (withs ((k v) (tokens spec #\=)
              (v m) (only.tokens v #\:)
              (s l) (tokens k #\|)
              h     nil)
        (= opts_.name default)
        (++ count_)
        (when (len> s 1)
          (= l s
             s nil))
        (when s
          (= spec_.s (obj name name value v default default))
          (= h (+ "-" s (when v (+ " " (or m "VALUE"))))))
        (when l
          (= spec_.l (obj name name value v default default))
          (= h (string h (when s ", ") "--" l (when v (+ "=" (or m "VALUE"))))))
        (push (list h help) help_))))

(def lenargs (x (o acc 1))
  (if (~acons x)    0
      (acons cdr.x) (lenargs cdr.x (+ 1 acc))
                    acc))

(def parseopt ((o args (cdr:copy args*)))
  (if (find "--help"    args) (pr-usage)
      (find "--version" args) (pr-version)
      (with (oargs nil opts (copy opts_))
        (whilet x (pop args)
          (if (is x "--")
              (do (= oargs (join rev.args oargs))
                  (wipe args))
              (~litmatch "-" x)
              (push x oargs)
              (withs ((k v) (tokens x #\=)
                      x     (if (litmatch "--" k)
                                (list:trim k 'front #\-)
                                (map [string _] (cdr:coerce k 'cons)))
                      lasti (- len.x 1))
                (on k x
                  (aif (spec_ string.k)
                       (let val (if it!value
                                    (aif (and (is index lasti) (or v (pop args)))
                                         it
                                         (require-arg-err k))
                                    t)
                         (= (opts it!name)
                            (on-err [parseopt-err k details._ 2]
                                    (fn ()
                                      (case it!value
                                        "i" (int val)
                                            val)))))
                       (invalid-opt-err k))))))
        (if (len< oargs (lenargs args_))
            (missing-operand-err)
            (list opts rev.oargs)))))

  (mac defopts args
    (= spec_ (table) opts_ (table) count_ 0 args_ nil help_ nil)
    (each x args
      (setup-optspec x)))

  (mac w/opts (spec . body)
    (= spec_ (table) opts_ (table) count_ 0 args_ nil help_ nil)
    (w/uniq g
      (each x spec
        (setup-optspec x))
      (withs ((opts args) (parseopt)
              g (accum a (each x (map car spec)
                           (a x)
                           (a opts.x))))
      `(with (,@g ,args_ ',args)
         ,@body))))

)
