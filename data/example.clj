;;; See https://github.com/howardabrams/rpn-calc for complete code

(ns rpn-calc.core
  (:gen-class)
  (:require [clojure
             [repl :as repl]
             [string :as str]]))

;; ----------------------------------------------------------------------
;;   ERROR SECTION for handling bad input and bad semantics.

(def error-list
  "A *state-ful* list of errors we've encountered."
  ;; An atom is a way to create a mutable object.  You just can't
  ;; accidentally change it, but will start with an empty list.
  (atom ()))

(defn rpn-error-store
  "Store a message, `msg` as a mini-stack of problems, where the first
  entry on the `error-list` is the latest issue we encountered."
  [msg]
  ;; The swap! is the best way to change an mutable data object.
  ;; In this case, we'll use the 'conj' function to tack something to it
  (swap! error-list conj msg))

(defn rpn-error-clear
  "Remove all errors we've encountered."
  []
  (reset! error-list ()))

(defn rpn-error
  "Deals with all exceptions in a standard manner... that is, printing
  to stdout. The optional value of results is returned, otherwise,
  returns nil."
  [e & [results]]
  (println "Error: " e)

  ;; Along with sending the error to stdout, let's also store it for
  ;; the unit tests:
  (rpn-error-store e)

  results)

;; ----------------------------------------------------------------------

(defn tokenize
  "Converts a string into a list of tokens, either a number or a
  symbol operator, e.g. '+ or 'd."
  [s]
  (when-not (str/blank? s)
    (->> (str/split s #"\s+")
         (map read-string)
         (filter (complement nil?)))))

(defn tuple-error
  "Convenience function for displaying an _operator_ error, where `op`
  is the called function, and `stack` is the value to return."
  [op return-value]
  (letfn [(fn-name [fn-object]
            ;; Warning ... here be dragons ...
            ;; I need to simply insert the operator in a string, but
            ;; Clojure, as a JVM language, translates the + function
            ;; as a PLUS method... and that ain't very readable.
            ;;
            ;; Using the REPL's `demunge` function for getting the
            ;; name of the original function, and then use a bit of
            ;; regexp magic to extract it from inside what is
            ;; returned. Hopefully, this is the only alchemy.

            (let [dem-fn (repl/demunge (str fn-object))
                  pretty (nth (re-find #"(.*?)/(.*?)@.*" dem-fn) 2)]
              (or pretty dem-fn)))]

    (rpn-error (format "insufficient input for '%s' operator" (fn-name op))
               return-value)))

(defn tuple-a-stack
  "Given a function that takes two arguments, call it with the first
  two elements in the stack, and combine it with the rest of the
  stack. Print an error, and return the stack untouched if the stack
  has less than 2 elements."
  [f stack]
  (if (> (count stack) 1)
    (cons (f (first stack) (second stack))
          (nthrest stack 2))
    (tuple-error f stack)))

(defn dup-stack
  "Duplicates the first item on the stack."
  [stack]
  (if (empty? stack)
    (rpn-error "Stack empty. Can't duplicate top entry." '())
    (cons (first stack) stack)))

(defn prn-stack
  "Prints and removes the first item on the stack"
  [stack]
  (if (empty? stack)
    (rpn-error "Stack empty. Can't print/remove top entry." '())
    (do
      (println (first stack))
      (rest stack))))

(defn process
  "Accepts the current 'stack' as the memo state, and deals with the
  next number to process. Returns the resulting stack state."
  [stack elem]
  (let [m (symbol "%")]
    (cond
      (integer? elem) (cons elem stack)
      ;; Why yes, adding expression to deal with decimals and
      ;; fractions would be trivial...

      (= elem '+)     (tuple-a-stack + stack)
      (= elem '-)     (tuple-a-stack - stack)
      (= elem '*)     (tuple-a-stack * stack)
      (= elem '/)     (tuple-a-stack quot stack)
      (= elem  m)     (tuple-a-stack rem stack)
      (= elem 'd)     (dup-stack stack)
      (= elem 'p)     (prn-stack stack)
      :else           (rpn-error (format "Couldn't parse '%s' as an integer or operator" elem) stack))))

(defn rpn
  "Processes the string as a series of numbers, operators and
  functions as a calculator that accepts reverse-polish notation."
  [s]
  (rpn-error-clear)   ;; Remove all previous errors from calling this

  (let [result-stack (reduce process [] (tokenize s))]
    (condp = (count result-stack)
      0 (rpn-error "expected an expression")
      1 (first result-stack)
      (rpn-error "ended with a stack of numbers" result-stack))))

(defn -main
  "Reads complete string from stdin and processes the tokens as RPN
  calculator input."
  [& args]
  (println (rpn (slurp *in*))))
