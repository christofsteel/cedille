module main where

open import lib
-- for parser for Cedille 
open import cedille-types

-- for parser for options files
import parse
import run
import options
import options-types
module parsem2 = parse options.gratr2-nt options-types.ptr
module options-parse = parsem2.pnoderiv options.rrs options.options-rtn
module pr2 = run options-types.ptr
module options-run = pr2.noderiv
import cedille-options

-- for parser for Cedille comments & whitespace
import cws-types

open import constants
open import general-util

dot-cedille-directory : string → string 
dot-cedille-directory dir = combineFileNames dir ".cedille"

module main-with-options (options : cedille-options.options) where

  open import ctxt
  open import process-cmd options
  open import parser
  open import spans options
  open import syntax-util
  open import to-string options
  open import toplevel-state options
  import interactive-cmds
  open import rkt options

  logFilepath : IO string
  logFilepath = getHomeDirectory >>= λ home →
                return (combineFileNames (dot-cedille-directory home) "log")

  maybeClearLogFile : IO ⊤
  maybeClearLogFile = if cedille-options.options.generate-logs options then
      logFilepath >>= clearFile
    else
      return triv

  logRope : rope → IO ⊤
  logRope s = if cedille-options.options.generate-logs options then
        (getCurrentTime >>= λ time →
        logFilepath >>= λ fn →
        withFile fn AppendMode (λ hdl →
          hPutRope hdl ([[ "([" ^ utcToString time ^ "] " ]] ⊹⊹ s ⊹⊹ [[ ")\n" ]])))
      else
        return triv

  logMsg : (message : string) → IO ⊤
  logMsg msg = logRope [[ msg ]]

  sendProgressUpdate : string → IO ⊤
  sendProgressUpdate msg = putStr "progress: " >> putStr msg >> putStr "\n" -- putStrLn ("progress: " ^ msg)

  fileBaseName : string → string
  fileBaseName fn = base-filename (takeFileName fn)

  {-------------------------------------------------------------------------------
    .cede support
  -------------------------------------------------------------------------------}

  cede-filename : (ced-path : string) → string
  cede-filename ced-path = 
    let dir = takeDirectory ced-path in
      combineFileNames (dot-cedille-directory dir) (fileBaseName ced-path ^ ".cede")

  -- .cede files are just a dump of the spans, prefixed by 'e' if there is an error
  write-cede-file : (ced-path : string) → (ie : include-elt) → IO ⊤
  write-cede-file ced-path ie = 
    let dir = takeDirectory ced-path in
    let cede = cede-filename ced-path in
      createDirectoryIfMissing ff (dot-cedille-directory dir) >>
     logMsg ("Started writing .cede file " ^ cede) >>
     writeRopeToFile cede ((if (include-elt.err ie) then [[ "e" ]] else [[]]) ⊹⊹ include-elt-spans-to-rope ie) >>
     logMsg ("Finished writing .cede file " ^ cede)

  -- we assume the cede file is known to exist at this point
  read-cede-file : (ced-path : string) → IO (𝔹 × string)
  read-cede-file ced-path =
    let cede = cede-filename ced-path in
    logMsg ("Started reading .cede file " ^ cede) >>
    get-file-contents cede >>= λ c → finish c >>≠
    logMsg ("Finished reading .cede file " ^ cede)
    where finish : maybe string → IO (𝔹 × string)
          finish nothing = return (tt , global-error-string ("Could not read the file " ^ cede-filename ced-path ^ "."))
          finish (just ss) with string-to-𝕃char ss
          finish (just ss)  | ('e' :: ss') = forceFileRead ss >> return (tt , 𝕃char-to-string ss')
          finish (just ss) | _ = forceFileRead ss >> return (ff , ss)

  add-cedille-extension : string → string
  add-cedille-extension x = x ^ "." ^ cedille-extension

  find-imported-file : (dirs : 𝕃 string) → (unit-name : string) → IO string
  find-imported-file [] unit-name = return (add-cedille-extension unit-name) -- assume the current directory if the unit is not found 
  find-imported-file (dir :: dirs) unit-name =
    let e = combineFileNames dir (add-cedille-extension unit-name) in
      doesFileExist e >>= λ b → 
      if b then
        canonicalizePath e >>= return
      else
        find-imported-file dirs unit-name

  -- return a list of pairs (i,p) where i is the import string in the file, and p is the full path for that imported file
  find-imported-files : (dirs : 𝕃 string) → (imports : 𝕃 string) → IO (𝕃 (string × string))
  find-imported-files dirs (u :: us) =
    find-imported-file dirs u >>= λ p →
    find-imported-files dirs us >>= λ ps →
      return ((u , p) :: ps)
  find-imported-files dirs [] = return []

  file-not-modified-since : string → UTC → IO 𝔹
  file-not-modified-since fn time =
    doesFileExist fn >>= λ b →
    if b then
        (getModificationTime fn >>= λ time' →
        return (time utc-after time'))
      else
        return tt

  cede-file-up-to-date : (ced-path : string) → IO 𝔹
  cede-file-up-to-date ced-path =
    let e = cede-filename ced-path in
      doesFileExist ced-path >>= λ b₁ →
      doesFileExist e >>= λ b₂ → 
      if b₁ && b₂ then
        fileIsOlder ced-path e
      else
        return ff

  {- new parser test integration -}
  reparse : toplevel-state → (filename : string) → IO toplevel-state
  reparse st filename = 
     doesFileExist filename >>= λ b → 
       (if b then
           (readFiniteFile filename >>= λ s → getCurrentTime >>= λ time → processText s >>= λ ie → return (set-last-parse-time-include-elt ie time))
        else return (error-include-elt ("The file " ^ filename ^ " could not be opened for reading."))) >>= λ ie →
          return (set-include-elt st filename ie)
    where processText : string → IO include-elt
          processText x with parseStart x
          processText x | Left (Left cs)  = return (error-span-include-elt ("Error in file " ^ filename ^ ".") "Lexical error." cs)
          processText x | Left (Right cs) = return (error-span-include-elt ("Error in file " ^ filename ^ ".") "Parsing error." cs)        
          processText x | Right t  with cws-types.scanComments x 
          processText x | Right t | t2 = find-imported-files (takeDirectory filename :: trie-strings (toplevel-state.include-path st))
                                                             (get-imports t) >>= λ deps →
                                         return (new-include-elt filename deps t t2 nothing)

  reparse-file : string → toplevel-state → IO toplevel-state
  reparse-file filename s =
    reparse s filename >>= λ s →
    return (set-include-elt s filename
            (set-cede-file-up-to-date-include-elt
             (set-do-type-check-include-elt
              (get-include-elt s filename) tt) ff))

  rkt-up-to-date : (filename : string) → toplevel-state → IO toplevel-state
  rkt-up-to-date filename s with cedille-options.options.make-rkt-files options
  ...| ff = return s
  ...| tt = 
    let rkt = rkt-filename filename in
    let ret = λ b → return (set-include-elt s filename (set-rkt-file-up-to-date-include-elt (get-include-elt s filename) b)) in
    doesFileExist rkt >>= λ where
      ff → ret ff
      tt → fileIsOlder filename rkt >>= ret

  ie-up-to-date : string → include-elt → IO 𝔹
  ie-up-to-date filename ie =
    getModificationTime filename >>= λ mt →
    return (maybe-else ff (λ lpt → lpt utc-after mt) (include-elt.last-parse-time ie))    

  ensure-ast-depsh : string → toplevel-state → IO toplevel-state
  ensure-ast-depsh filename s with get-include-elt-if s filename
  ...| just ie = ie-up-to-date filename ie >>= λ where
    ff → reparse-file filename s
    tt → return s
  ...| nothing = case cedille-options.options.use-cede-files options of λ where
    ff → reparse-file filename s
    tt →
      let cede = cede-filename filename in
      doesFileExist cede >>= λ where
        ff → reparse-file filename s
        tt → fileIsOlder filename cede >>= λ where
          ff → reparse-file filename s
          tt → reparse s filename >>= λ s →
               read-cede-file filename >>= λ where
                 (err , ss) → return
                   (set-include-elt s filename
                   (set-do-type-check-include-elt
                   (set-need-to-add-symbols-to-context-include-elt
                   (set-spans-string-include-elt
                   (get-include-elt s filename) err ss) tt) ff))

  import-changed : toplevel-state → (filename : string) → (import-file : string) → IO 𝔹
  import-changed s filename import-file =
    let dtc = include-elt.do-type-check (get-include-elt s import-file) in
    let cede = cede-filename filename in
    let cede' = cede-filename import-file in
    case cedille-options.options.use-cede-files options of λ where
      ff → return dtc
      tt → doesFileExist cede >>= λ where
        ff → return ff
        tt → doesFileExist cede' >>= λ where
          ff → return ff
          tt → fileIsOlder cede cede' >>= λ fio → return (dtc || fio)
   
  any-imports-changed : toplevel-state → (filename : string) → (imports : 𝕃 string) → IO 𝔹
  any-imports-changed s filename [] = return ff
  any-imports-changed s filename (h :: t) = import-changed s filename h >>= λ where
    tt → return tt
    ff → any-imports-changed s filename t

  {- helper function for update-asts, which keeps track of the files we have seen so
     we avoid importing the same file twice, and also avoid following cycles in the import
     graph. -}
  {-# TERMINATING #-}
  update-astsh : stringset {- seen already -} → toplevel-state → (filename : string) →
                 IO (stringset {- seen already -} × toplevel-state)
  update-astsh seen s filename = 
    if stringset-contains seen filename then return (seen , s)
    else (ensure-ast-depsh filename s >>= rkt-up-to-date filename >>= cont (stringset-insert seen filename))
    where cont : stringset → toplevel-state → IO (stringset × toplevel-state)
          cont seen s with get-include-elt s filename
          cont seen s | ie with include-elt.deps ie
          cont seen s | ie | ds = 
            proc seen s ds 
            where proc : stringset → toplevel-state → 𝕃 string → IO (stringset × toplevel-state)
                  proc seen s [] = any-imports-changed s filename ds >>= λ changed →
                    let dtc = include-elt.do-type-check ie || changed in
                    return (seen , set-include-elt s filename (set-do-type-check-include-elt ie dtc))
                  proc seen s (d :: ds) = update-astsh seen s d >>= λ p → 
                                          proc (fst p) (snd p) ds

  {- this function updates the ast associated with the given filename in the toplevel state.
     So if we do not have an up-to-date .cede file (i.e., there is no such file at all,
     or it is older than the given file), reparse the file.  We do this recursively for all
     dependencies (i.e., imports) of the file. -}
  update-asts : toplevel-state → (filename : string) → IO toplevel-state
  update-asts s filename = update-astsh empty-stringset s filename >>= λ p → 
    return (snd p)

  log-files-to-check : toplevel-state → IO ⊤
  log-files-to-check s = logRope ([[ "\n" ]] ⊹⊹ (h (trie-mappings (toplevel-state.is s)))) where
    h : 𝕃 (string × include-elt) → rope
    h [] = [[]]
    h ((fn , ie) :: t) = [[ "file: " ]] ⊹⊹ [[ fn ]] ⊹⊹ [[ "\nadd-symbols: " ]] ⊹⊹ [[ 𝔹-to-string (include-elt.need-to-add-symbols-to-context ie) ]] ⊹⊹ [[ "\ndo-type-check: " ]] ⊹⊹ [[ 𝔹-to-string (include-elt.do-type-check ie) ]] ⊹⊹ [[ "\n\n" ]] ⊹⊹ h t

  {- this function checks the given file (if necessary), updates .cede and .rkt files (again, if necessary), and replies on stdout if appropriate -}
  checkFile : toplevel-state → (filename : string) → (should-print-spans : 𝔹) → IO toplevel-state
  checkFile s filename should-print-spans = 
    update-asts s filename >>= λ s →
    log-files-to-check s >>
    -- let msg = if include-elt.do-type-check (get-include-elt s filename) then "Checking " else "Skipping " in
    -- sendProgressUpdate (msg ^ filename) >>
    finish (process-file s filename) -- ignore-errors s filename)
    where
          reply : toplevel-state → IO ⊤
          reply s with get-include-elt-if s filename
          reply s | nothing = putStrLn (global-error-string ("Internal error looking up information for file " ^ filename ^ "."))
          reply s | just ie =
             if should-print-spans then
               putRopeLn (include-elt-spans-to-rope ie)
             else return triv
          finish : toplevel-state × mod-info → IO toplevel-state
          finish (s , m) with s
          finish (s , m) | mk-toplevel-state ip mod is Γ =
            logMsg ("Started reply for file " ^ filename) >> -- Lazy, so checking has not been calculated yet?
            reply s >>
            logMsg ("Finished reply for file " ^ filename) >>
            logMsg ("Files with updated spans:\n" ^ 𝕃-to-string (λ x → x) "\n" mod) >>
            writeo mod >> -- Should process-file now always add files to the list of modified ones because now the cede-/rkt-up-to-date fields take care of whether to rewrite them?
            return (mk-toplevel-state ip [] is (ctxt-set-current-mod Γ m))
              where
                writeo : 𝕃 string → IO ⊤
                writeo [] = return triv
                writeo (f :: us) =
                  writeo us >>
                  let ie = get-include-elt s f in
                    (if cedille-options.options.use-cede-files options && ~ include-elt.cede-up-to-date ie then (write-cede-file f ie) else return triv) >>
                    (if cedille-options.options.make-rkt-files options && ~ include-elt.rkt-up-to-date ie then (write-rkt-file f (toplevel-state.Γ s) ie) else return triv)

  -- this is the function that handles requests (from the frontend) on standard input
  {-# TERMINATING #-}
  readCommandsFromFrontend : toplevel-state → IO ⊤
  readCommandsFromFrontend s =
      getLine >>= λ input →
      logMsg ("Frontend input: " ^ input) >>
      let input-list : 𝕃 string 
          input-list = (string-split (undo-escape-string input) delimiter) 
              in (handleCommands input-list s) >>= λ s →
          readCommandsFromFrontend s
          where
              delimiter : char
              delimiter = '§'

              errorCommand : 𝕃 string → toplevel-state → IO toplevel-state
              errorCommand ls s = putStrLn (global-error-string "Invalid command sequence \"" ^ (𝕃-to-string (λ x → x) ", " ls) ^ "\".") >>= λ x → return s

              debugCommand : toplevel-state → IO toplevel-state
              debugCommand s = putStrLn (escape-string (toplevel-state-to-string s)) >>= λ x → return s

              checkCommand : 𝕃 string → toplevel-state → IO toplevel-state
              checkCommand (input :: []) s = canonicalizePath input >>= λ input-filename →
                          checkFile (set-include-path s (stringset-insert (toplevel-state.include-path s) (takeDirectory input-filename)))
                          input-filename tt {- should-print-spans -}
              checkCommand ls s = errorCommand ls s

    {-          findCommand : 𝕃 string → toplevel-state → IO toplevel-state
              findCommand (symbol :: []) s = putStrLn (find-symbols-to-JSON symbol (toplevel-state-lookup-occurrences symbol s)) >>= λ x → return s
              findCommand _ s = errorCommand s -}

              handleCommands : 𝕃 string → toplevel-state → IO toplevel-state
              handleCommands ("check" :: xs) = checkCommand xs
              handleCommands ("debug" :: []) = debugCommand
              handleCommands ("interactive" :: xs) = interactive-cmds.interactive-cmd options xs
  --            handleCommands ("find" :: xs) s = findCommand xs s
              handleCommands = errorCommand


  -- function to process command-line arguments
  processArgs : 𝕃 string → IO ⊤ 

  -- this is the case for when we are called with a single command-line argument, the name of the file to process
  processArgs (input-filename :: []) =
    canonicalizePath input-filename >>= λ input-filename → 
    checkFile (new-toplevel-state (stringset-insert (cedille-options.options.include-path options) (takeDirectory input-filename)))
      input-filename ff {- should-print-spans -} >>= finish input-filename
    where finish : string → toplevel-state → IO ⊤
          finish input-filename s = return triv
{-            let ie = get-include-elt s input-filename in
            if include-elt.err ie then (putRopeLn (include-elt-spans-to-rope ie)) else return triv
-}
  -- this is the case where we will go into a loop reading commands from stdin, from the fronted
  processArgs [] = readCommandsFromFrontend (new-toplevel-state (cedille-options.options.include-path options))

  -- all other cases are errors
  processArgs xs = putStrLn ("Run with the name of one file to process, or run with no command-line arguments and enter the\n"
                           ^ "names of files one at a time followed by newlines (this is for the emacs mode).")
  
  main' : IO ⊤
  main' =
    maybeClearLogFile >>
    logMsg "Started Cedille process" >>
    getArgs >>=
    processArgs

createOptionsFile : (options-filepath : string) → IO ⊤
createOptionsFile ops-fp = withFile ops-fp WriteMode (λ hdl →
  hPutRope hdl (cedille-options.options-to-rope cedille-options.default-options))


opts-to-options : options.opts → cedille-options.options
opts-to-options (options.OptsCons (options.Lib fps) ops) =
  record (opts-to-options ops) { include-path = paths-to-stringset fps }
  where paths-to-stringset : options.paths → stringset
        paths-to-stringset (options.PathsCons fp fps) =
          stringset-insert (paths-to-stringset fps) fp
        paths-to-stringset options.PathsNil = empty-stringset
opts-to-options (options.OptsCons (options.UseCedeFiles b) ops) =
  record (opts-to-options ops) { use-cede-files = cedille-options.str-bool-to-𝔹 b }
opts-to-options (options.OptsCons (options.MakeRktFiles b) ops) =
  record (opts-to-options ops) { make-rkt-files = cedille-options.str-bool-to-𝔹 b }
opts-to-options (options.OptsCons (options.GenerateLogs b) ops) =
  record (opts-to-options ops) { generate-logs = cedille-options.str-bool-to-𝔹 b }
opts-to-options (options.OptsCons (options.ShowQualifiedVars b) ops) =
  record (opts-to-options ops) { show-qualified-vars = cedille-options.str-bool-to-𝔹 b }
opts-to-options options.OptsNil = cedille-options.default-options

-- helper function to try to parse the options file
processOptions : string → string → (string ⊎ cedille-options.options)
processOptions filename s with string-to-𝕃char s
...                       | i with options-parse.runRtn i
...                           | inj₁ cs =
                                     inj₁ ("Parse error in file " ^ filename ^ " at position " ^ (ℕ-to-string (length i ∸ length cs)) ^ ".")
...                           | inj₂ r with options-parse.rewriteRun r
...                                    | options-run.ParseTree (options-types.parsed-start (options-types.File oo)) :: [] = inj₂ (opts-to-options oo)
...                                    | _ =  inj₁ ("Parse error in file " ^ filename ^ ". ")

-- read the ~/.cedille/options file
readOptions : IO cedille-options.options
readOptions =
  getHomeDirectory >>= λ homedir →
    let homecedir = dot-cedille-directory homedir in
    let optsfile = combineFileNames homecedir options-file-name in
      createDirectoryIfMissing ff homecedir >>
      doesFileExist optsfile >>= λ b → 
       if b then
         (readFiniteFile optsfile >>= λ f →
         case (processOptions optsfile f) of λ where
           (inj₁ err) → putStrLn (global-error-string err) >>
                        return cedille-options.default-options
           (inj₂ ops) → return ops)
       else
         (createOptionsFile optsfile >>
         return cedille-options.default-options)

postulate
  initializeStdinToUTF8 : IO ⊤
  setStdinNewlineMode : IO ⊤
{-# COMPILED initializeStdinToUTF8  System.IO.hSetEncoding System.IO.stdin System.IO.utf8 #-}
{-# COMPILED setStdinNewlineMode System.IO.hSetNewlineMode System.IO.stdin System.IO.universalNewlineMode #-}

-- main entrypoint for the backend
main : IO ⊤
main = initializeStdoutToUTF8 >>
       initializeStdinToUTF8 >>
       setStdoutNewlineMode >>
       setStdinNewlineMode >>
       readOptions >>=
       main-with-options.main'
